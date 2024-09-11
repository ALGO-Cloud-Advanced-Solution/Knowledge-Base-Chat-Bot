import os

import streamlit as st
import base64
import json
import requests
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest
from botocore.credentials import Credentials

from dotenv import load_dotenv

load_dotenv()


# AWS Credentials
aws_access_key = os.getenv("aws_access_key")
aws_secret_key = os.getenv("aws_secret_key")
aws_region = os.getenv("aws_region")
service = 'lambda'

# API Gateway URL
api_url = 'https://d4x5ohieab.execute-api.us-east-1.amazonaws.com/dev'

if 'lang' not in st.session_state:
    st.session_state.lang = ''


def create_signed_request(method, url, headers, payload):
    # Set up AWS credentials and request details
    credentials = Credentials(aws_access_key, aws_secret_key)
    request = AWSRequest(method=method, url=url, headers=headers, data=payload)

    # Use botocore to sign the request
    auth = SigV4Auth(credentials, service, aws_region)
    auth.add_auth(request)

    # Extract headers with signature
    signed_headers = dict(request.headers)

    return signed_headers


# TODO: check if en changes actually

def handle_response(response_json):
    # check language thing

    if "detected_language" in response_json:
        # if frist msg then store the detectd langauage in it
        if st.session_state.lang == "":
            st.session_state.lang = response_json.get("detected_language", st.session_state.lang)

        msg = response_json["body"]

        # check if change language has been requested
        change_lang = True if (msg[-4:] == "done" or msg[-4:] == "تمام") else False

        if (change_lang):
            st.session_state.lang = ""

        return msg if not change_lang else msg[:-4]
    else:
        #TODO: Handle file name
        msg = response_json["body"]
        return msg


def invoke_lambda(payload):
    headers = {
        'Content-Type': 'application/json',
    }
    signed_headers = create_signed_request('POST', api_url, headers, json.dumps(payload))
    try:
        response = requests.post(api_url, headers=signed_headers, json=payload)
        response.raise_for_status()  # Raise an error for bad HTTP status codes
        return handle_response(response.json())
    except requests.exceptions.RequestException as e:
        st.error(f"Error invoking Lambda function: {e}")
        return None


def main():
    # Initialize session state for chat history
    if 'chat_history' not in st.session_state:
        st.session_state.chat_history = []

    st.title("ACC Chatbot")
    st.write("### Chat with the Bot:")

    if st.session_state.chat_history:
        for chat in st.session_state.chat_history:
            st.chat_message("user").markdown(chat['user'])
            st.chat_message("bot").markdown(chat['bot'])

    # Sidebar for file upload and phone number input
    st.sidebar.header("Upload File and Enter Phone Number")
    phone_number = st.sidebar.text_input("Enter your phone number:")
    uploaded_file = st.sidebar.file_uploader("Choose a file", type=["mp3", "m4a", "opus", "jpeg", "jpg", "png"])


    #upload file things
    if st.sidebar.button("Upload File"):
        if phone_number and uploaded_file:
            file_content = uploaded_file.read()
            encoded_file_content = base64.b64encode(file_content).decode('utf-8')
            data = {
                "object_data": encoded_file_content,
                "object_name": uploaded_file.name,
                "client_number": phone_number,
                "data_type": "obj"
            }
            result = invoke_lambda(data)
            st.sidebar.write(result)
        else:
            st.sidebar.write("Please enter a phone number and upload a file.")

    # Main chat area
    chat_input = st.chat_input("Type your message:")

    if phone_number and chat_input:
        data = {
            "object_data": chat_input,
            "client_number": phone_number,
            "data_type": "text",
            "language": st.session_state.lang
        }

        st.chat_message("user").markdown(chat_input)
        bot_response = invoke_lambda(data)
        st.chat_message("bot").markdown(bot_response)

        # Update chat history
        st.session_state.chat_history.append({"user": chat_input, "bot": bot_response})

        # Clear the input box
        st.session_state.chat_input = ""
    # else:
    # if not chat_input :   st.error("Please enter a phone number and a message.")


if __name__ == "__main__":
    main()


# Base image
FROM python:3.8-slim

# Set the working directory
WORKDIR /app

# Copy requirements.txt to the container
COPY requirements.txt requirements.txt

# Install dependencies
RUN pip3 install -r requirements.txt

# Copy the application files
COPY app.py /app/app.py

ENV aws_access_key=$ORDERLYACCESSKEY
ENV aws_secret_key=$ORDERLYSECRETACCESSKEY
ENV aws_region=us-east-1

# Run the application
CMD ["streamlit","run", "app.py"]


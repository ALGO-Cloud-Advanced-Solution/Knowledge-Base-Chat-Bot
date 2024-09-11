FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 inatsall -r requirements.txt

COPY app.py /app/app.py

EXPOSE 8501

ENTRYPOINT ["streamlit", "run", "app.py",]


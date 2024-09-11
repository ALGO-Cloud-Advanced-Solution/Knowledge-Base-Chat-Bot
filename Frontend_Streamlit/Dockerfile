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

# Run the application
CMD ["python3", "/app/app.py"]


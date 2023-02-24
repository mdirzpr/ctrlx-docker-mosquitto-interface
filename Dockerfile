# Specify the parent image from which we build
FROM ubuntu:20.04

# Set the working directory
WORKDIR /app

# Copy source code to image
COPY ctrlx-datalayer-mqtt-plc/ .

# Install required packages
RUN echo 'Installing requirements in image' &&\
    apt-get update &&\
    apt-get install -y libzmq5 &&\
    apt-get install -y pip &&\
    pip3 install -r /app/requirements.txt &&\
    apt-get install /app/ctrlx-datalayer-1.9.1.deb

# Run the application
CMD ["python3", "/app/main.py"]
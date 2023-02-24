# Specify the parent image from which we build
FROM ubuntu:20.04
# Set the working directory
WORKDIR /app

RUN apt-get update
RUN apt-get install -y binutils
RUN apt-get install -y libzmq5
RUN apt-get install -y python3
RUN apt-get install -y pip

# Install Python requirements
RUN echo 'Installing requirements in image'
COPY ctrlx-datalayer-mqtt-plc/requirements.txt requirements.txt
RUN pip install --upgrade pip
RUN pip3 install -r requirements.txt

# Copy source code to image
RUN echo 'Copying source code to image'
COPY ctrlx-datalayer-mqtt-plc/ .

# Install ctrlx-datalayer Debian package
RUN apt-get install /app/ctrlx-datalayer-1.9.1.deb

# Check dependencies
# RUN strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 | grep GLIBCXX

# Run the application
RUN chmod +x /app/main.py
CMD ["python3", "/app/main.py"]
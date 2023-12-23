# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set the maintainer information
LABEL maintainer="sudipta"

# Update package lists
RUN apt-get update -y

# Install required packages
RUN apt-get install -y python3-pip build-essential

# Copy the application code to the /app directory in the container
COPY . /app

# Set the working directory to /app
WORKDIR /app

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Expose port 8888
EXPOSE 8888

# Set the entry point for the container
ENTRYPOINT ["python3"]

# Specify the default command to run when the container starts
CMD ["app.py"]

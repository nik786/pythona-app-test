FROM ubuntu:latest
MAINTAINER sudipta
RUN apt-get update -y
RUN apt-get install python-pip  build-essential -y
RUN apt-get install python3-pip -y
COPY . /app
WORKDIR /app
RUN pip3 install -r requirements.txt
EXPOSE 8888
ENTRYPOINT ["python"]
CMD ["app.py"]

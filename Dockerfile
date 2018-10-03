FROM ubuntu:18.04

RUN apt-get update

RUN apt-get install -y build-essential libssl-dev libcurl4-openssl-dev libffi-dev python3-dev python3-pip python3-venv git wget cmake autoconf automake libtool pkg-config libpng-dev libjpeg8-dev libtiff5-dev zlib1g-dev

RUN apt-get install -y libleptonica-dev

RUN wget https://github.com/tesseract-ocr/tesseract/archive/3.04.01.tar.gz && tar -zxf 3.04.01.tar.gz && cd tesseract-3.04.01 && ./autogen.sh && ./configure && make && make install && cd ../..

RUN pip3 install --upgrade pip
RUN pip3 install --upgrade setuptools
RUN pip3 install wheel
RUN pip3 install grpcio
RUN pip3 install grpcio-tools googleapis-common-protos
RUN pip3 install mypy-protobuf
RUN pip3 install tensorflow

COPY requirements.txt ./requirements.txt

RUN pip3 install -r requirements.txt --process-dependency-links

COPY pipelinerunner ./pipelinerunner
COPY proto ./proto

RUN python3 -m grpc_tools.protoc -I./proto --python_out=./pipelinerunner --grpc_python_out=./pipelinerunner --mypy_out=./pipelinerunner ./proto/*.proto

ENV D3MOUTPUTDIR=/usr/local/d3m/output
ENV STATIC_RESOURCE_PATH=/usr/local/d3m/static_resources
ENV PYTHONUNBUFFERED 1

EXPOSE 50051

CMD [ "python3", "./pipelinerunner/server.py" ]
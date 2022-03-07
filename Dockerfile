FROM datamechanics/spark:3.1-latest

WORKDIR /opt/app

RUN mkdir /tmp/data
COPY foor.jar .

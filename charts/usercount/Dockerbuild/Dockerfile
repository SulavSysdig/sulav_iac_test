FROM alpine:latest
RUN apk update
RUN apk add py-pip curl
RUN pip install flask
COPY promclient.py /
CMD ["python","/promclient.py"]

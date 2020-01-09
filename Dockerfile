FROM python:3.8.0-buster



WORKDIR /app

COPY ./app.py /app/app.py

CMD python3 app.py

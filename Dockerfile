FROM python:3.8.0-buster



WORKDIR /app

COPY ./app.py /app/app.py

RUN apt-get install libpq-dev && pip3 install -r requierements.txt

CMD python3 app.py

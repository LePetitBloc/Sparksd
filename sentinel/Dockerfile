FROM debian:jessie

RUN apt-get update -y \
	&& apt-get install -y \
	build-essential \
	virtualenv \
	python \
	python-dev \
	python-virtualenv \
	git

RUN cd / \
	&& mkdir /sentinel \
	&& git clone https://github.com/sparkscrypto/sentinel.git sentinel \
	&& cd sentinel \
	&& export LC_ALL=C \
	&& virtualenv ./venv \
	&& ./venv/bin/pip install -r requirements.txt

COPY ./sentinel.conf /sentinel/sentinel.conf

ENV SENTINEL_DEBUG 1

WORKDIR /sentinel

CMD ["./venv/bin/python", "bin/sentinel.py"]

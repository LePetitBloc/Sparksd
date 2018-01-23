FROM debian:jessie

RUN apt-get update -y \
	&& apt-get install -y \
	virtualenv \
	python \
	python-dev \
	python-virtualenv

RUN cd / \
	&& mkdir /sentinel \
	&& git clone https://github.com/sparkscrypto/sentinel.git sentinel \
	&& cd sentinel \
	&& export LC_ALL=C \
	&& virtualenv ./venv \
	&& ./venv/bin/pip install -r requirements.txt

COPY ./sentinel/sentinel.conf /sentinel/sentinel.conf

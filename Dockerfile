FROM debian:jessie
RUN Deps='libevent-dev libssl-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libminiupnpc-dev libzmq3-dev libdb4.8 libdb++-dev' \
    buildDeps='ca-certificates build-essential libtool autotools-dev automake pkg-config bsdmainutils wget git' \
    DB4DIR="/usr/local/db4" \
    DB4VERSION="db-4.8.30.NC" \
    DB4FILE=$DB4VERSION".tar.gz" \
    DB4URL="http://download.oracle.com/berkeley-db/"$DB4FILE \
    DB4HASH=12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef \
    && set -xe \
    && apt-get update -y && apt-get install -y $buildDeps $Deps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && wget $DB4URL \
    && echo "$DB4HASH $DB4FILE" | sha256sum -c - \
    && tar -xzvf $DB4FILE \
    && cd $DB4VERSION"/build_unix/" \
    && ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$DB4DIR \
    && mkdir -p $DB4DIR \
    && make install \
    && cd ../../ \
    && rm $DB4FILE \
    && rm -rf $DB4VERSION

RUN USE_UPNP=1 \
    && git clone https://github.com/sparkscrypto/Sparks.git Sparks \
    && cd Sparks \
    && chmod +x autogen.sh share/genbuild.sh src/leveldb/build_detect_platform \
    && ./autogen.sh \
    && export BDB_INCLUDE_PATH="/usr/local/db4/include" \
    && export BDB_LIB_PATH="/usr/local/db4/lib" \
    && ln -s /usr/local/db4/lib/libdb-4.8.so /usr/lib/libdb-4.8.so \
    && ./configure  CPPFLAGS="-I/usr/local/db4/include -O2" LDFLAGS="-L/usr/local/db4/lib" \
    && make

RUN mkdir /sparks_data /sparks_backup /sparks_log

COPY ./src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Sentinel
RUN apt-get update -y \ 
	&& apt-get install -y virtualenv \
	&& apt-get install -y python \
	&& apt-get -y install python-virtualenv

RUN cd / \
	&& mkdir /sentinel \
	&& git clone https://github.com/sparkscrypto/sentinel.git sentinel \
	&& cd sentinel \
	&& export LC_ALL=C \
	&& virtualenv ./venv \
	&& ./venv/bin/pip install -r requirements.txt

COPY ./sentinel.conf /sentinel/sentinel.conf
	
# Install rsyslog 
RUN apt-get install -y -qq --no-install-recommends rsyslog

# Install Cron 
RUN apt-get install -y -qq --no-install-recommends cron	

# Add crontab file
COPY ./src/crontab /etc/cron.d/sentinel

# Give execution rights on the cron job
RUN chmod 644 /etc/cron.d/sentinel

# Fix crontab crash caused by FS Overlay
# http://stackoverflow.com/questions/21926465/issues-running-cron-in-docker-on-different-hosts
# Comment "session    required   pam_loginuid.so"
RUN sed -i '/session    required     pam_loginuid.so/c\#session    required     pam_loginuid.so' /etc/pam.d/cron

# Define working directory
WORKDIR /Sparks/src

CMD /entrypoint.sh 
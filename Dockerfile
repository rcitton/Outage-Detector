FROM python:3.11.5-slim-bookworm
ARG BUILD_DATE
LABEL \
  maintainer="Ruggero Citton <rcitton@gmail.com>" \
  authors="Ruggero Citton <rcitton@gmail.com>" \
  title="outage_detector" \
  description="Module to notify user if a power outage has occured or if the internet has been dow" \
  created=$BUILD_DATE

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Rome

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set prompt
RUN echo 'export PS1="[⚡ \e[0;34m\h\e[0m \w]# "' >> /root/.bashrc

# Install dependencies
RUN apt-get update
RUN apt-get -q -y install --no-install-recommends apt-utils cron vim tzdata

# Clean up
RUN apt-get -q -y autoremove && apt-get -q -y clean
RUN rm -rf /var/lib/apt/lists/*

# Install python requirements
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy and final setup
COPY README.md README.md
COPY setup.py setup.py
COPY outagedetector outagedetector
RUN python setup.py install

ADD start.sh /
RUN chmod +x /start.sh

# Execution
ENTRYPOINT ["/start.sh"]

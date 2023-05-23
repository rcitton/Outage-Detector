FROM python:3.11.3-slim-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update 
#RUN apt-get -q -y install --no-install-recommends apt-utils gnupg1 apt-transport-https dirmngr curl

# Clean up
RUN apt-get -q -y autoremove && apt-get -q -y clean 
RUN rm -rf /var/lib/apt/lists/*


# Copy and final setup
ADD . /app
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install --no-cache -r requirements.txt 
COPY . .

# Excetution
CMD ["python", "setup.py"]

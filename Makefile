# -------------------------------------------------------------------------------
# Author: Ruggero Citton
# Date: September 18 , 2023
# Purpose: A module helping you find out when internet and power outages happen
# Tested on: Ubuntu 23.04 - Raspberry PI 4
#
#
# Licensed under The MIT License (MIT).
# See included LICENSE file or the notice below.
#
# Copyright (c) 2023 Ruggero Cittons
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# -------------------------------------------------------------------------------


###############################################################################
#  SET ENV VARIABLES                                                          #
###############################################################################
include ./env.mk


###########################
CONTAINER=outage-detector
IMGNME=outage-detector
IMGVRS=1.0.0
DOCKER=/usr/bin/docker
PODMAN=/usr/bin/podman
RUNTIMECT=$(DOCKER)


###############################################################################
#                             DOCKER/PODMAN SECTION                           #
###############################################################################

all: build \
	create \
	start

build:
	@echo "Make CONTAINER $(CONTAINER)"
	$(RUNTIMECT) build --force-rm=true \
	--no-cache=true -t $(IMGNME):$(IMGVRS) -f Dockerfile .

create:
	@echo "Create CONTAINER $(CONTAINER)"
    ifeq ($(RUNTIMECT),/usr/bin/docker)
		$(RUNTIMECT) create -t -i \
			--hostname $(CONTAINER) \
			--volume /etc/localtime:/etc/localtime:ro \
			--restart=always \
			--name $(CONTAINER) \
            --env NOTIFICATION_TYPE=$(NOTIFICATION_TYPE) \
            --env SENDER_MAIL_ADDRESS=$(SENDER_MAIL_ADDRESS) \
            --env RECEIVER_MAIL_ADDRESSES=$(RECEIVER_MAIL_ADDRESSES) \
            --env MAIL_PASSWORD=$(MAIL_PASSWORD) \
            --env NOTIFICATION_PASSWORD=$(NOTIFICATION_PASSWORD) \
            --env NOTIFICATION_TYPE=$(NOTIFICATION_TYPE) \
            --env NOTIFICATION_PASSWORD=$(NOTIFICATION_PASSWORD) \
            --env HOUSE_ADDRESS=$(HOUSE_ADDRESS) \
            --env TZ=$(HOUSE_ADDRESS) \
			$(IMGNME):$(IMGVRS)
    else
		$(RUNTIMECT) create -t -i \
			--hostname $(CONTAINER) \
			--volume /etc/localtime:/etc/localtime:ro \
			--restart=always \
			--name $(CONTAINER) \
            --env NOTIFICATION_TYPE=$(NOTIFICATION_TYPE) \
            --env SENDER_MAIL_ADDRESS=$(SENDER_MAIL_ADDRESS) \
            --env RECEIVER_MAIL_ADDRESSES=$(RECEIVER_MAIL_ADDRESSES) \
            --env MAIL_PASSWORD=$(MAIL_PASSWORD) \
            --env NOTIFICATION_PASSWORD=$(NOTIFICATION_PASSWORD) \
            --env NOTIFICATION_TYPE=$(NOTIFICATION_TYPE) \
            --env NOTIFICATION_PASSWORD=$(NOTIFICATION_PASSWORD) \
            --env HOUSE_ADDRESS=$(HOUSE_ADDRESS) \
            --env TZ=$(HOUSE_ADDRESS) \
			$(IMGNME):$(IMGVRS)
    endif

start:
	@echo "STARTING UP CONTAINER $(CONTAINER)"
	$(RUNTIMECT) start $(CONTAINER)

stop:
	@echo "STOPPING CONTAINER $(CONTAINER)"
	$(RUNTIMECT) stop $(CONTAINER)

clean:
	@echo "Cleanup CONTAINER $(CONTAINER)"
	-$(RUNTIMECT) stop $(CONTAINER)
	-$(RUNTIMECT) rm $(CONTAINER)
	$(RUNTIMECT) rmi $(IMGNME):$(IMGVRS)

connect:
	$(RUNTIMECT) exec -it $(CONTAINER) bash

none:
	$(RUNTIMECT) exec -it $(CONTAINER) \
		/usr/local/bin/python /usr/local/bin/outage_detector \
		--run boot \
		--notify none
		
pushbullet:
	$(RUNTIMECT) exec -it $(CONTAINER) \
		/usr/local/bin/python /usr/local/bin/outage_detector \
		--run boot \
		--notify pushbullet

ifttt:
	$(RUNTIMECT) exec -it $(CONTAINER) \
		/usr/local/bin/python /usr/local/bin/outage_detector \
		--run boot \
		--notify ifttt

###############################################################################
#                                                                             #
###############################################################################

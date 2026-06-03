#!/usr/bin/env bash

docker run -it -d \
	--name invisibot_c \
	--restart unless-stopped \
	-p 8080:8080 \
	-v ./robots.json:/invisibot_ws/robots.json \
invisibot:latest bash -c "python3 -m invisibot"

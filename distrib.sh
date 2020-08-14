#!/bin/bash
sudo docker build -t jelass .
cat ~/.DH_TOKEN | sudo docker login --username sfproductlabs --password-stdin
sudo docker tag $(sudo docker images -q | head -1) sfproductlabs/jelass:latest
sudo docker push sfproductlabs/jelass:latest
#!/bin/bash
sudo docker build -t elassandra .
cat ~/.DH_TOKEN | sudo docker login --username sfproductlabs --password-stdin
sudo docker tag $(sudo docker images -q | head -1) sfproductlabs/elassandra:latest
sudo docker push sfproductlabs/elassandra:latest
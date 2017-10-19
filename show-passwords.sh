#!/bin/bash

while ! docker exec -ti projector_tuleap_1 cat /data/root/.tuleap_passwd; do
    sleep 1
done

#!/bin/bash

docker-compose down && docker-compose up --force-recreate --build

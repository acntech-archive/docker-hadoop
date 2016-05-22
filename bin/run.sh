#!/bin/bash

docker run --name acntech-hadoop-core -h acntech-hadoop-core -p 8088:8088 -p 50070:50070 -p 50080:50080 -p 50090:50090 -it acntech/hadoop-core:2.7.2
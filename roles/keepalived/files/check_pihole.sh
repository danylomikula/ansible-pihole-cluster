#!/bin/bash

STATUS=$(ps ax | grep -v grep | grep pihole-FTL)

if [ "$STATUS" != "" ]
then
    exit 0
else
    exit 1
fi
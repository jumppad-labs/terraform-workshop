#!/bin/bash

until curl -s -o /dev/null --fail localhost; do
  echo "waiting for docs to start"
  sleep 1
done
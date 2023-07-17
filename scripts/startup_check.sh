#!/bin/bash

until curl -s -o /dev/null --fail localhost/_next/data/development/terraform_basics/introduction/introduction.json; do
  echo "waiting for docs to start"
  sleep 1
done
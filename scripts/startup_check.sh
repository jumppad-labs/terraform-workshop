#!/bin/bash

until curl -s -o /dev/null --fail localhost/docs/terraform_basics/introduction/what_is_terraform; do
  echo "waiting for docs to start"
  sleep 1
done
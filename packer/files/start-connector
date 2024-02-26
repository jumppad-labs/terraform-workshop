#!/bin/bash -e

HOSTNAME=$(hostname)

# Generate CA certificates for the Jumppad connector
/usr/local/bin/jumppad connector generate-certs \
  --non-interactive \
  --ca \
  --dns-name \
  /root/.jumppad/certs/

# Generate leaf certificates for the Jumppad connector
/usr/local/bin/jumppad connector generate-certs \
  --non-interactive \
  --root-ca /root/.jumppad/certs/root.cert \
  --root-key /root/.jumppad/certs/root.key \
  --leaf \
  --dns-name ${HOSTNAME},localhost,*.jumppad.dev,localhost:30001,localhost:30002 \
  --ip-address 127.0.0.1,::1 \
  /root/.jumppad/certs/

# Start the Jumppad connector
jumppad connector run \
  --non-interactive \
  --grpc-bind=:30001 \
  --http-bind=:30002 \
  --api-bind=:30003 \
  --root-cert-path=/root/.jumppad/certs/root.cert \
  --server-cert-path=/root/.jumppad/certs/leaf.cert \
  --server-key-path=/root/.jumppad/certs/leaf.key \
  --log-level=debug
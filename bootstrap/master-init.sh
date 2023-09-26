#!/bin/bash
sudo kubeadm init \
--control-plane-endpoint kubernetes.shiron-system.net \
--upload-certs \
--pod-network-cidr 10.10.0.0/16 \
--service-cidr 10.96.0.0/12
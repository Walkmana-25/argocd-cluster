#!/bin/bash


sudo kubeadm init \
--control-plane-endpoint kubernetes.shiron-system.net \
--upload-certs \
--pod-network-cidr 10.244.0.0/16

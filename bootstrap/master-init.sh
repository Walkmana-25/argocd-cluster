#!/bin/bash


sudo kubeadm init \
--control-plane-endpoint=kubernetes.shiron-system.net \
--upload-certs \
--pod-network-cidr=192.168.0.0/16


kubeadm token create --print-join-command
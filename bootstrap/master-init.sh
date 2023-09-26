#!/bin/bash


sudo kubeadm init \
--control-plane-endpoint=192.168.0.210 \
--upload-certs \
--pod-network-cidr=10.200.0.0/16 \
--service-cidr=172.16.0.0/16

kubeadm token create --print-join-command
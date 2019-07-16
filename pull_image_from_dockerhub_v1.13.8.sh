#!/bin/bash

gcr_name=k8s.gcr.io
myhub_name=zhaojiedi1992
# define images 
images=(
        kubernetes-dashboard-amd64:v1.10.0
	kube-apiserver:v1.13.8
 kube-controller-manager:v1.13.8
 kube-scheduler:v1.13.8
 kube-proxy:v1.13.8
 pause:3.1
 etcd:3.2.24
 coredns:1.3.1
)

for image in ${images[@]}; do 
	docker pull $myhub_name/$image
	docker tag  $myhub_name/$image $gcr_name/$image
	docker rmi $myhub_name/$image
done

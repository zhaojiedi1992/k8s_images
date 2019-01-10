#!/bin/bash

urls=(
    https://raw.githubusercontent.com/kubernetes/kubernetes/master/CHANGELOG-1.10.md
    https://raw.githubusercontent.com/kubernetes/kubernetes/master/CHANGELOG-1.11.md
    https://raw.githubusercontent.com/kubernetes/kubernetes/master/CHANGELOG-1.12.md
    https://raw.githubusercontent.com/kubernetes/kubernetes/master/CHANGELOG-1.13.md
    #https://raw.githubusercontent.com/kubernetes/kubernetes/master/CHANGELOG-1.9.md
    #https://raw.githubusercontent.com/kubernetes/kubernetes/master/CHANGELOG-1.9.md
)

for url in ${urls[@]}; do
	curl $url >tmp.txt
	tags=$(cat tmp.txt |egrep '\[v[0-9\.]{2,8}\]' -o  |sed -r 's@\[(.*)\]@\1@g') 
	for tag in $tags; do 
		# create dir
		#mkdir $tag -pv 
		# create sub dir
         	images=$(kubeadm config  images list  --kubernetes-version=$tag)
		if [ -z "$images" ] ; then 
			continue
		fi
		for image in $images; do 
			version=$(echo $image |awk -F ":" '{print $NF}')
			subdir=$(echo $image |sed -r 's@.*/(.*):.*@\1@g')
			mkdir  $tag/$subdir -pv
			echo "From $image " >$tag/$subdir/Dockerfile
			echo "MAINTAINER zhaojiedi1992@outlook.com" >> $tag/$subdir/Dockerfile
		done
		# create sh file 
		images2=$(echo $images | sed 's@k8s.gcr.io/@@g' |sed 's@ @\\\n @g')
		cat pull_image_from_dockerhub.template |sed -r "s@<images>@$images2@g" >pull_image_from_dockerhub_${tag}.sh
		chmod a+x pull_image_from_dockerhub_${tag}.sh
				
	done
done


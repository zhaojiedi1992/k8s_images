# k8s镜像拉取方案
我们安装官方文档安装kubenetes的时候，在执行到kubeadm init 这个步骤的时候，发现拉取镜像这一步无法进行下去，因为google在大陆无法
访问的问题，本文就是为解决大陆无法下载镜像的问题的。

我在博客园写了一篇k8s的安装博客，可以直接参考博客。
[完成安装参考](https://www.cnblogs.com/zhaojiedi1992/p/zhaojiedi_liunx_53_k8s.html)

## 目录说明

```
    pc-zhaojiedi:k8s_images zhaojiedi$ tree
    .
    |-- README.md                                    # readme 文件
    |-- create_script.sh                             # 创建拉取镜像脚本的脚本
    |-- pull_image_from_dockerhub.template           # 拉取镜像的脚本模板
    |-- pull_image_from_dockerhub_v1.10.0.sh         # 根据上面2个生成的脚本
    |-- v1.10.0                                      # create_script.sh为特定k8s版本生产的dockerfile,用于dockerhub的自动构建的
    |   |-- coredns
    |   |   `-- Dockerfile                           # 特定k8s版本，需要的特定组件的对应dockerfile文件
    |   |-- etcd-amd64
    |   |   `-- Dockerfile
    |   |-- kube-apiserver-amd64
    |   |   `-- Dockerfile
    |   |-- kube-controller-manager-amd64
    |   |   `-- Dockerfile
    |   |-- kube-proxy-amd64
    |   |   `-- Dockerfile
    |   |-- kube-scheduler-amd64
    |   |   `-- Dockerfile
    |   `-- pause
    |       `-- Dockerfile
```

## 主要文件说明
- **create_script.sh**: 根据k8s的changlog文件，提取到tag号，使用kubeadm config  images list  --kubernetes-version=$tag 来获取到安装特定k8s版本需要的
                    组件版本信息，创建对应的版本目录，并根据组件信息，创建各个组件的dockerfile文件和pull_image_from_dockerhub_$tag的脚本。
- **pull_image_from_dockerhub_$tag.sh**: 这个脚本完成从dockerhub上面的zhaojiedi1992账户下的k8s组件下载和重新tag成google的。

## 使用说明

```bash
    [root@master ~]# cd /root
    [root@master ~]# mkdir git
    [root@master ~]# cd git/
    [root@master git]# git clone https://github.com/zhaojiedi1992/k8s_images.git
    [root@master git]# cd k8s_images/
    [root@master k8s_images]# ls
    create_script.sh                      pull_image_from_dockerhub_v1.10.6.sh  README.md  v1.10.6
    pull_image_from_dockerhub.template    pull_image_from_dockerhub_v1.10.7.sh  tmp.txt    v1.10.7
    pull_image_from_dockerhub_v1.10.0.sh  pull_image_from_dockerhub_v1.10.8.sh  v1.10.0    v1.10.8
    pull_image_from_dockerhub_v1.10.1.sh  pull_image_from_dockerhub_v1.11.0.sh  v1.10.1    v1.11
    pull_image_from_dockerhub_v1.10.2.sh  pull_image_from_dockerhub_v1.11.1.sh  v1.10.2    v1.11.0
    pull_image_from_dockerhub_v1.10.3.sh  pull_image_from_dockerhub_v1.11.2.sh  v1.10.3    v1.11.1
    pull_image_from_dockerhub_v1.10.4.sh  pull_image_from_dockerhub_v1.11.3.sh  v1.10.4    v1.11.2
    pull_image_from_dockerhub_v1.10.5.sh  pull_image_from_dockerhub_v1.11.sh    v1.10.5    v1.11.3
    [root@master k8s_images]# chmod a+x *.sh

    # 查看安装的k8s版本对应需要的镜像,需要你已经安装了kubeadm这个命令的。
    [root@master k8s_images]# kubeadm config images list --kubernetes-version=v1.11.3
    k8s.gcr.io/kube-apiserver-amd64:v1.11.3
    k8s.gcr.io/kube-controller-manager-amd64:v1.11.3
    k8s.gcr.io/kube-scheduler-amd64:v1.11.3
    k8s.gcr.io/kube-proxy-amd64:v1.11.3
    k8s.gcr.io/pause:3.1
    k8s.gcr.io/etcd-amd64:3.2.18
    k8s.gcr.io/coredns:1.1.3

    # 查看脚本的镜像和需要拉去的是否一致。
    [root@master k8s_images]# cat ./pull_image_from_dockerhub_v1.11.3.sh 
    #!/bin/bash
    gcr_name=k8s.gcr.io
    myhub_name=zhaojiedi1992
    # define images 
    images=(
        kube-apiserver-amd64:v1.11.3
        kube-controller-manager-amd64:v1.11.3
        kube-scheduler-amd64:v1.11.3
        kube-proxy-amd64:v1.11.3
        pause:3.1
        etcd-amd64:3.2.18
        coredns:1.1.3
    )
    for image in ${images[@]}; do 
        docker pull $myhub_name/$image
        docker tag $myhub_name/$image $gcr_name/$image
        docker rmi $myhub_name/$image
    done

    # 确认上面的无错误，开始下载。
    [root@master k8s_images]# ./pull_image_from_dockerhub_v1.11.3.sh 
    [root@master k8s_images]# docker image ls 
    REPOSITORY TAG IMAGE ID CREATED SIZE
    k8s.gcr.io/pause 3.1 24440bb35d05 About an hour ago 742 kB
    k8s.gcr.io/kube-proxy-amd64 v1.11.3 763b3c45ccd2 4 hours ago 97.8 MB
    k8s.gcr.io/kube-scheduler-amd64 v1.11.3 8434ffab1549 5 hours ago 56.8 MB
    k8s.gcr.io/kube-controller-manager-amd64 v1.11.3 3b0d0349c534 5 hours ago 155 MB
    k8s.gcr.io/kube-apiserver-amd64 v1.11.3 306b76250de9 6 hours ago 187 MB
    k8s.gcr.io/coredns 1.1.3 6b777875393d 6 hours ago 45.6 MB
    k8s.gcr.io/etcd-amd64 3.2.18 7dc1bb5c1af1 6 hours ago 219 MB

    # 这样主节点就有了特定版本的所有组件了，可以开始初始化工作了。
    kubeadm  init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.11.3
```

注意： 上面的只是主节点的镜像拉取，从节点也是需要拉取镜像的，只是部分镜像，可以同样执行拉取命令，然后删除多余的。

## 其他

上面使用的pull_image脚本会去dockerhub的[zhaojiedi1992](https://hub.docker.com/r/zhaojiedi1992/)这个仓库去拉取，我已经配置组件的好多tag了，如果没有你需要的版本，可以联系我或者fork后自己配置下。这里提供一下dockerhub的自动构建截图，具体的详细配置自行百度下。

![etcd dockerhub自动构建图](/kube-apiserver-amd64.jpg)






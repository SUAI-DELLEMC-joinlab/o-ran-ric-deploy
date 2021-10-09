#!/bin/bash
if [ "$1" == "install" ]
    apt-get upadate
    apt-get upgrade -y
	apt-get install git -y
    git clone http://gerrit.o-ran-sc.org/r/it/dep
    cd dep
    git submodule update --init --recursive --remote
    
    sed -i 's/"repository: kong-docker-kubernetes-ingress-controller.bintray.io/kong-ingress-controller"/""image: kong/kubernetes-ingress-controller:0.7.0""/g' /ric-dep/helm/infrastructure/subcharts/kong/values.yaml

    
    ric-dep/helm/infrastructure/subcharts/kong/values.yaml
    cd tools/k8s/bin
    ./gen-cloud-init.sh

    curl -L https://git.io/get_helm.sh | bash

    helm init --client-only --skip-re
    helm repo rm stable
    helm repo add stable https://charts.helm.sh/stable



fi

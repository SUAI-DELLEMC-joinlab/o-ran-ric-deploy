#!/bin/bash
if [ "$1" == "install" ]
    then
    apt-get update
    apt-get upgrade -y
	apt-get install git -y
    git clone http://gerrit.o-ran-sc.org/r/it/dep
    cd dep
    git submodule update --init --recursive --remote


    cd tools/k8s/bin
    ./gen-cloud-init.sh

    curl -L https://git.io/get_helm.sh | bash


    tmp1="repository: kong-docker-kubernetes-ingress-controller.bintray.io/kong-ingress-controller"
    tmp2="repository: kong/kubernetes-ingress-controller"
    
    sed -i "s#${tmp1}#${tmp2}#g" ../../../ric-dep/helm/infrastructure/subcharts/kong/values.yaml
    sed -i "s#${tmp1}#${tmp2}#g" ../../../ric-aux/helm/infrastructure/subcharts/kong/values.yaml

    oldRepositoryOfTiller="name: kubernetes-helm/tiller"
    newRepositoryOfTiller="name: helm/tiller"
    
    sed -i "s#${oldRepositoryOfTiller}#${newRepositoryOfTiller}#g" ../../../ric-dep/helm/infrastructure/values.yaml
    
    oldTillerVesion="tag: v2.12.3"
    tillerVesion="2.17.0"
    newTillerVesion="tag: ${tillerVesion}"
    sed -i "s#${oldTillerVesion}#${newTillerVesion}#g" ../../../ric-dep/helm/infrastructure/values.yaml
    oldRep="gcr.io"
    newRep="ghcr.io"
    sed -i "s#${oldRep}#${newRep}#g" ../../../ric-dep/helm/infrastructure/values.yaml
    
    
    ./k8s-1node-cloud-init-k_1_16-h_2_17-d_cur.sh 

fi

if [ "$1" == "deploy" ]
    then

    helm init --client-only
    helm repo rm stable
    helm repo add stable https://charts.helm.sh/stable
    
    sleep 10
    
    kubectl create ns ricinfra
    helm install stable/nfs-server-provisioner --namespace ricinfra --name nfs-release-1
    kubectl patch storageclass nfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    apt install -y nfs-common

    sleep 10
    
    cd dep

    ./bin/deploy-ric-platform -f ~/o-ran-ric/dep/RECIPE_EXAMPLE/PLATFORM/example_recipe.yaml

    kubectl get pods -n ricplt


fi



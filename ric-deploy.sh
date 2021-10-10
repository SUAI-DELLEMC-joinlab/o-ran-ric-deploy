#!/bin/bash
if [ "$1" == "install" ]
    then
    apt-get upadate
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

    ./k8s-1node-cloud-init-k_1_16-h_2_17-d_cur.sh 

fi

if [ "$1" == "deploy" ]
    then

    helm init --client-only
    helm repo rm stable
    helm repo add stable https://charts.helm.sh/stable

    cd dep

    ./bin/deploy-ric-platform -f /bin/RECIPE_EXAMPLE/PLATFORM/example_recipe.yaml

    kubectl get pods -n ricplt


fi



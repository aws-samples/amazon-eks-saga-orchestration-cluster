#!/bin/bash

set -e

e_setup() {
  ACCOUNT_ID=$1

  eksctl create iamserviceaccount \
  --cluster=eks-saga-orchestration \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/eks-saga-elb-policy \
  --override-existing-serviceaccounts \
  --approve

  helm repo add eks https://aws.github.io/eks-charts
  helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=eks-saga-orchestration --set nodeSelector.role=web -n kube-system
}

if [[ $# -ne 1 ]] ; then
  echo 'USAGE: ./elb.sh accountId'
  exit 1
fi

ACCOUNT_ID=$1

e_setup ${ACCOUNT_ID}

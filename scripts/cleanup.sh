#!/bin/bash

set -ex

remove_objects() {
  echo 'Removing trail microservice'
  kubectl -n eks-saga delete ing/eks-saga-trail svc/eks-saga-trail deployment/eks-saga-trail configmap/eks-saga-trail
  echo 'Removing audit microservice'
  kubectl -n eks-saga delete deployment/eks-saga-audit configmap/eks-saga-audit
  echo 'Removing inventory microservice'
  kubectl -n eks-saga delete deployment/eks-saga-inventory configmap/eks-saga-inventory
  echo 'Removing order microservice'
  kubectl -n eks-saga delete ing/eks-saga-orders svc/eks-saga-orders deployment/eks-saga-orders configmap/eks-saga-orders
  echo 'Removing orchestrator microservice'
  kubectl -n eks-saga delete deployment/eks-saga-orchestrator configmap/eks-saga-orchestrator
  echo 'Removing orders rollback microservice'
  kubectl -n eks-saga delete deployment/eks-saga-orders-rb configmap/eks-saga-orders-rb
  echo 'Removing eks-saga namespace'
  kubectl delete namespace eks-saga
}

remove_cluster() {
  EKS_CLUSTER=$1
  echo 'Removing cluster eks-saga-orchestration'
  eksctl delete cluster --name ${EKS_CLUSTER}
}

if [[ $# -ne 6 ]] ; then
  echo 'USAGE: ./cleanup.sh stackName accountId rdsDb eksVpc rdsVpc clusterName'
  exit 1
fi

STACK_NAME=$1
ACCOUNT_ID=$2
RDS_DB_ID=$3
EKS_VPC=$4
RDS_VPC=$5
EKS_CLUSTER=$6

remove_objects
remove_cluster ${EKS_CLUSTER}

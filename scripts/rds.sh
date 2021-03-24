#!/bin/bash

set -e

r_setup() {
  echo 'Updating RDS security group'
  STACK_NAME=$1
  EKS_VPC=$2
  RDS_VPC=$3
  RDS_DB_ID=$4

  RDS_SG=`aws rds describe-db-instances --db-instance-identifier ${RDS_DB_ID} --query 'DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId' --output text`
  SUBNETS=(`aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select((.ResourceType=="AWS::EC2::Subnet") and (.LogicalResourceId | startswith("SubnetPrivate"))) | .PhysicalResourceId'`)
  
  for s in "${SUBNETS[@]}"
  do
    CIDR_BLOCK=`aws ec2 describe-subnets --subnet-ids ${s} --query 'Subnets[0].CidrBlock' --output text`
    aws ec2 authorize-security-group-ingress --group-id ${RDS_SG} --protocol tcp --port 3306 --cidr ${CIDR_BLOCK}
  done

  echo "${RDS_SG} in RDS VPC ${RDS_VPC} updated to allow MySQL traffic from EKS VPC ${EKS_VPC}"
}

if [[ $# -ne 4 ]] ; then
  echo 'USAGE: ./rds.sh stackName eksVpc rdsVpc rdsDbId'
  exit 1
fi

STACK_NAME=$1
EKS_VPC=$2
RDS_VPC=$3
RDS_DB_ID=$4

r_setup ${STACK_NAME} ${EKS_VPC} ${RDS_VPC} ${RDS_DB_ID}
#!/bin/bash
secGroup="sg-1a79946d"
ami="ami-09e3dc7d"
keyName="namics"
keyLocation="/Users/phagedorn/.ssh/namics.pem"
region=EU-WEST-1

instance_id=$(ec2-run-instances --region=$region -k $keyName -g $secGroup -t m1.large $ami | awk '/INSTANCE/{print $2}')
echo $instance_id

sleep 50

name=$(ec2-describe-instances --region=$region $instance_id | awk '/INSTANCE/{print $4}')
echo $name


echo $name >> ec2hosts.txt
#ssh -i $keyLocation ubuntu@$name

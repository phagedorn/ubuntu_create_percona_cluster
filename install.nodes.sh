#!/bin/bash
KEYFILE=/Users/phagedorn/.ssh/namics.pem
REMOTEUSER=ubuntu
instance_count=1
rm ec2hosts.txt

for (( c=1; c<=instance_count; c++ ))
do
	echo Create Instance Number $c ...
	bash create_instance.sh	
done

node=0

for h in `cat ec2hosts.txt`
do
# ssh -n -i $KEYFILE $SSHOPT $REMOTEUSER@$h "sudo mysqladmin shutdown"
 let "node+=1"
 if [ $node == 1 ]; then
   IPNODE=$(ssh -i $KEYFILE $SSHOPT $REMOTEUSER@$h "/sbin/ifconfig eth0 " | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
 fi
 scp -i $KEYFILE $SSHOPT install_debs.sh $REMOTEUSER@$h:/tmp
 ssh -n -i $KEYFILE $SSHOPT $REMOTEUSER@$h bash /tmp/install_debs.sh $node $IPNODE
done


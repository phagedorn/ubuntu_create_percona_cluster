#!/bin/bash
KEYFILE="/Users/phagedorn/.ssh/namics.pem"
REMOTEUSER="ubuntu"
instance_count=1
SSH_PORT=22
secGroup="sg-1a79946d"
ami="ami-09e3dc7d"
keyName="namics"
keyLocation=$KEYFILE
region=EU-WEST-1
debug="test"

if [ "$debug" = "test" ]; then
    echo DEBUG MODE
    echo we will use preconfigured virtualbox instance
    TEST_HOST="localhost"        
    SSH_PORT="2222"
    echo SET HOST AND PORT to $TEST_HOST : $SSH_PORT
else
    rm ec2hosts.txt
    for (( c=1; c<=instance_count; c++ ))
    do
            echo Create Instance Number $c ...
            instance_id=$(ec2-run-instances --region=$region -k $keyName -g $secGroup -t m1.large $ami | awk '/INSTANCE/{print $2}')
            echo $instance_id
            sleep 50
            name=$(ec2-describe-instances --region=$region $instance_id | awk '/INSTANCE/{print $4}')
            echo $name
            echo $name >> ec2hosts.txt
    done
fi

node=0
if [ "$debug" = "test" ]; then
    echo DEBUG MODE
     scp -P $SSH_PORT install_debs.sh $REMOTEUSER@$TEST_HOST:/tmp
     ssh -p $SSH_PORT $REMOTEUSER@$TEST_HOST bash /tmp/install_debs.sh $node $IPNODE $DEBUG
else    
    for host in `cat ec2hosts.txt`
    do
     let "node+=1"
     if [ $node == 1 ]; then
       IPNODE=$(ssh -p $SSH_PORT -i $KEYFILE $SSHOPT $REMOTEUSER@$host "/sbin/ifconfig eth0 " | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
     fi
     scp -P $SSH_PORT $KEYFILE $SSHOPT install_debs.sh $REMOTEUSER@$host:/tmp
     ssh -n -i $KEYFILE $SSHOPT $REMOTEUSER@$host bash /tmp/install_debs.sh $node $IPNODE
    done
fi





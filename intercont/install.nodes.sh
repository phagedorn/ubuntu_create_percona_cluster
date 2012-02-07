REMOTEUSER=root
SSHOPT="-o StrictHostKeyChecking=no"

HOSTS="ec2-176-34-218-180.eu-west-1.compute.amazonaws.com \
ec2-50-18-26-27.us-west-1.compute.amazonaws.com"



KEYS[1]=EU-host.pem
KEYS[2]=US-host.pem
KEYS[3]=ASIA-JP-host.pem

node=0

for h in $HOSTS
do
 let "node+=1"
 ssh -n -i ${KEYS[node]} $SSHOPT $REMOTEUSER@$h mysqladmin shutdown
 if [ $node == 1 ]; then
   IPNODE=$h
 fi
 scp -i ${KEYS[$node]} $SSHOPT install_rpm.sh $REMOTEUSER@$h:/tmp
 ssh -n -i ${KEYS[$node]} $SSHOPT $REMOTEUSER@$h bash /tmp/install_rpm.sh $node $IPNODE $h
done


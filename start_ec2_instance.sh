#ec2-run-instances ami-250e5060 -k test-cluster  --region us-west-1 -t m1.xlarge
# get hostnames
#ec2-describe-instances --region us-west-1 | grep us-west-1.compute.amazonaws.com | awk ' { print $4 } ' > ec2hosts.txt

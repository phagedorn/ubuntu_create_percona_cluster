#!/bin/bash
############
###########

# hybris download path
hdownload=""

#hybris path
$hpath="/home/ubuntu/hybris"

wget http://s3.amazonaws.com/doc/s3-example-code/s3-curl.zip
unzip s3-curl.zip

#write s3 secret .s3curl file
cat >.s3curl <<DELIM
%awsSecretAccessKeys = (
    # personal account
    personal => {
        id => 'AKIAINIALX4WDHP5QGPA',
        key => 'haRaZ9VE0L+wP7FqudC4+ruvDvtIiTbF2gV/d3Hz',
    }
);
DELIM

apt-get install libdigest-hmac-perl


# hybris base properties
db.url="db.url=jdbc:mysql://localhost/hybris?useConfigs=maxPerformance" 
db.driver="db.driver=com.mysql.jdbc.Driver"
db.username="db.username="
db.password="db.password="



# write hybris config 
cat > $hpath/config/local.properties <<DELIM
$db.url
$db.driver
$db.username
$db.password
DELIM


cd $hpath
ant clean all
./hybrisserver start

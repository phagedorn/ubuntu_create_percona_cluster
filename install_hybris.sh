#!/bin/bash
############
###########

#hybris path
$hpath="/home/ubuntu/hybris"


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

#!/bin/bash
#debug=$3

debug="test"


# add percona apt keys
sudo gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
sudo gpg -a --export CD2EFD2A | sudo apt-key add -

# add percona repo 
sudo bash -c "cp /etc/apt/sources.list /etc/apt/sources.list_backup"
sudo bash -c "grep -v percona /etc/apt/sources.list_backup > /etc/apt/sources.list"
sudo bash -c "echo 'deb http://repo.percona.com/apt lenny main' >>/etc/apt/sources.list"
sudo apt-get update

# install percona-server from repo
#yes|sudo apt-get -f install
#sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install percona-server-server

if [ "$debug" = "test" ]; then
    echo entering debug modus...
    cd /tmp
else
    #WGET_PATH="https://s3-eu-west-1.amazonaws.com/static-hybris/percona-cluster"
    WGET_PATH="http://www.percona.com/downloads/Percona-XtraDB-Cluster/5.5.17-alpha22.1/deb/squeeze"
    #WGET_OPTIONS="--quiet"

    # get percona alpha debs
    cd /tmp
    wget $WGET_OPTIONS $WGET_PATH/libmysqlclient18_5.5.17-22.1-3691.squeeze_amd64.deb
    wget $WGET_OPTIONS $WGET_PATH/percona-xtradb-cluster-client-5.5_5.5.17-22.1-3691.squeeze_amd64.deb
    wget $WGET_OPTIONS $WGET_PATH/percona-xtradb-cluster-common-5.5_5.5.17-22.1-3691.squeeze_all.deb
    wget $WGET_OPTIONS $WGET_PATH/percona-xtradb-cluster-galera_0.1-1_amd64.deb
    wget $WGET_OPTIONS $WGET_PATH/percona-xtradb-cluster-server-5.5_5.5.17-22.1-3691.squeeze_amd64.deb
fi


# install percona server & cluster from debs
yes|sudo DEBIAN_FRONTEND=noninteractive dpkg -i *.deb
sudo DEBIAN_FRONTEND=noninteractive apt-get -f -q -y --force-yes install

sudo mkdir -p /etc/mysql/
sudo chown -R ubuntu:ubuntu /etc/mysql

sudo /etc/init.d/mysql stop

NODE=$1
if [ $NODE == 1 ]; then
 JOINIP=
else
 JOINIP=$2
fi

sudo bash -c "cat > /etc/mysql/my.cnf <<DELIM
[mysqld]
datadir=/mnt/data/mysql
user=mysql

log_error=error.log

binlog_format=ROW

wsrep_provider=/usr/lib64/libgalera_smm.so

wsrep_cluster_address=gcomm://$JOINIP

wsrep_slave_threads=2
wsrep_cluster_name=trimethylxanthine
wsrep_sst_method=rsync
wsrep_node_name=node$NODE

innodb_locks_unsafe_for_binlog=1
innodb_autoinc_lock_mode=2

innodb_log_file_size=64M
DELIM"

sudo /etc/init.d/mysql restart

#sudo mkdir -p /mnt/data/mysql
#sudo mysql_install_db --datadir=/mnt/data/mysql
#sudo /usr/bin/mysqld_safe </dev/null > /tmp/mysql.out 2>&1 &


rpm -Uhv http://repo.percona.com/testing/centos/6/os/noarch/percona-testing-0.0-1.noarch.rpm
rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
yes | yum -y install Percona-XtraDB-Cluster-server Percona-XtraDB-Cluster-client

NODE=$1
if [ $NODE == 1 ]; then
 JOINIP=
else
 JOINIP=$2
fi

MEIP=$3

cat > /etc/my.cnf <<ENDOFCNF
[mysqld]
datadir=/mnt/data/mysql
user=mysql

log_error=error.log
slow_query_log
slow_query_log_file=slow.log
long_query_time=0

binlog_format=ROW

wsrep_provider=/usr/lib64/libgalera_smm.so

wsrep_cluster_address=gcomm://$JOINIP

wsrep_sst_receive_address=$MEIP:4444
wsrep_provider_options = "gmcast.listen_addr=tcp://0.0.0.0:4567; ist.recv_addr=$MEIP; evs.keepalive_period = PT3S; evs.inactive_check_period = PT10S; evs.suspect_timeout = PT30S; evs.inactive_timeout = PT1M; evs.consensus_timeout = PT1M; evs.send_window=1024; evs.user_send_window=512;"


wsrep_slave_threads=2
wsrep_cluster_name=trimethylxanthine
wsrep_sst_method=rsync
wsrep_node_name=node$NODE

innodb_locks_unsafe_for_binlog=1
innodb_autoinc_lock_mode=2

innodb_log_file_size=64M

ENDOFCNF

mkdir -p /mnt/data/mysql
rm -fr /mnt/data/mysql/*
mysql_install_db --datadir=/mnt/data/mysql


service iptables stop

/usr/bin/mysqld_safe </dev/null > /tmp/mysql.out 2>&1 &


#!/bin/sh

chk_hdfs=`hadoop fsck / | grep 'filesystem under path'`

case $chk_hdfs in
	*HEALTHY*)
		echo "OK - HDFS is healthy"
		exit 0
	;;
	*)
		echo "CRITICAL - HDFS is corrupt!"
		exit 2
	;;
esac


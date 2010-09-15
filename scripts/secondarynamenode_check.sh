#!/bin/sh

CHECK_POINT="/var/lib/hadoop-0.20/cache/hadoop/dfs/namesecondary/previous.checkpoint"

chk_files=`find $CHECK_POINT -cmin +120`

case $chk_files in
	*fsimage*)
		echo "CRITICAL - checkpoint is not operating!>"
		exit 2
	;;
	*)
		echo "OK - checkpoint is healthy"
		exit 0
	;;
esac


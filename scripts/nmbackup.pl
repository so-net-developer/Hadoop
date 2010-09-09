#!/usr/bin/perl

# バックアップ対象ファイルが存在しない場合はリトライする。
# editsのサイズが4バイトでない場合は、エラー中止する。
# その他ファイルのサイズが0バイトならエラー中止する。
# バックアップ前とバックアップ後でファイルサイズが違う場合はリトライ。

use strict;
use warnings;
use File::Copy;

my $MAX_RETRY = 5;		#リトライ回数
my $RETRY_INTERVAL = 120;	#リトライインターバル(秒)

# バックアップ対象ディレクトリ
my $BACKUP_SRC_DIR = "/var/lib/hadoop-0.20/cache/hadoop/dfs/namesecondary/previous.checkpoint";
# バックアップ先ディレクトリ
my $BACKUP_DST_DIR = "/data/hdfs1/namenode_back";

my @BACKUP_FILES = ("VERSION","edits","fsimage","fstime");
my $file;
my $path;
my $file_size;
my %file_info = ();	# ファイル名とサイズ

$SIG{ALRM} = \&timeout;	# タイマコールバック

my $wait = 0;
my $retry = 0;
my $files_ng = 0;	# ファイルが存在しない場合1になる

while(1){

	my $ret;

	foreach $file (@BACKUP_FILES) {
		$path = $BACKUP_SRC_DIR . "/" . $file;
		if (-f $path) {		# ファイルの存在確認
			$file_size = -s $path;
			if ( $file eq "edits" ){
				if ( $file_size != 4 ){
					print "size error!\n";
					exit 1;
				}
			}else{
				if ( $file_size == 0 ){
					print "size error!\n";
					exit 1;
				}
			}
			# バックアップ前のファイルサイズを退避
			$file_info{$file} = $file_size;

		}else{
			$files_ng = 1;	# ファイルが存在しない
			next;
		}
	}
		
	if ( $files_ng != 1 ){
		# ファイルが揃っていて、サイズも問題ないのでバックアップ開始
		if ( &do_backup() eq "OK"){
			exit 0;
		}
	}

	# ここからリトライ開始処理(インターバルタイマ開始)
	print "retry!\n";
	$files_ng = 0;
	alarm $RETRY_INTERVAL;
	$wait = 1;

	$retry = $retry + 1;

	if ( $retry == $MAX_RETRY ){	#リトライ回数に達したのでエラー終了
		alarm 0;
		exit 3;
	}

	while($wait){}; 	#待ちループ

	alarm 0;
};

# タイマクリア
sub timeout {
	$wait = 0;
}

# バックアップ実行部
sub do_backup{

	my $dst_path;
	my $dst_file;

	$dst_path = $BACKUP_DST_DIR . "/" . get_yyyymmddhhmm();

	if ( !mkdir( $dst_path, 0755) ){
		print "mkdir error!\n";
		exit 2;
	};
	foreach $file (@BACKUP_FILES) {
		$path = $BACKUP_SRC_DIR . "/" . $file;
		$dst_file = $dst_path . "/" . $file;
		copy($path, $dst_file);
		$file_size = -s $dst_file;
		if ( $file_size != $file_info{$file} ){
			print "backupfile size error\n";
			return "NG";
		}
	}
	return "OK";
}

sub get_yyyymmddhhmm{

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900;
	$mon += 1;

	return sprintf("%4d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min);
}

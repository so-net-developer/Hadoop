# Hadoopの設定ファイルを同期する。
class hadoop-settings {
	$path = '/etc/hadoop-0.20/conf.cluster'
	file { $path:
		source	=> 'puppet://host1.domain.com/hadoop/conf.cluster',
		recurse	=> true,
	}
}
# Hadoopの設定ファイルを同期後に再起動する。
class hadoop-settings-restart {
	$path = '/etc/hadoop-0.20/conf.cluster'
	file { $path:
		source	=> 'puppet://host1.domain.com/hadoop/conf.cluster',
		recurse	=> true,
	}

	exec { '/etc/init.d/hadoop-0.20-datanode restart':
		subscribe => File[$path],
		refreshonly => true
	}
	exec { '/etc/init.d/hadoop-0.20-tasktracker restart':
		subscribe => File[$path],
		refreshonly => true
	}
}
# Puppetの設定の同期 
class puppet-init {

	file { '/etc/sysconfig/puppet':
		source => 'puppet://host1.domain.com/files/puppet',
		replace => 'true'
	}

	file { '/etc/puppet/namespaceauth.conf':
		source => 'puppet://host1.domain.com/files/namespaceauth.conf',
		replace => 'true'
	}
}
# Hadoopのインストール。注：JDKだけは前もって入れておくこと
class hadoop-install {


	file { '/etc/cron.daily/hadoop':
		source => 'puppet://host1.domain.com/cron/hadoop',
	}	

	file { '/etc/yum.repos.d/cloudera-cdh2.repo':
		source	=> 'puppet://host1.domain.com/cdh2/cloudera-cdh2.repo',
	}

	package { 'hadoop-0.20':
		name => 'hadoop-0.20',
		ensure => installed,
		require => File['/etc/yum.repos.d/cloudera-cdh2.repo']
	}

	package { 'hadoop-0.20-conf-pseudo':
		name => 'hadoop-0.20-conf-pseudo',
		ensure => installed,
		require => Package['hadoop-0.20']
	}

	file { '/etc/hadoop-0.20/conf.cluster':
		source	=> 'puppet://host1.domain.com/hadoop/conf.cluster',
		recurse	=> true,
		require => Package['hadoop-0.20']
	}

	exec { 'alternatives --install /etc/hadoop-0.20/conf hadoop-0.20-conf /etc/hadoop-0.20/conf.cluster 50':
		path => '/usr/sbin',
		onlyif => '/usr/bin/test -d /etc/hadoop-0.20/conf.cluster'
	}
}
# Gangliaのインストールと設定
class ganglia {

	package { 'libconfuse':
		name => 'libconfuse',
		ensure => installed,
	}

	package { 'rrdtool':
		name => 'rrdtool',
		ensure => installed
	}

	file { '/etc/init.d/gmond':
		source => 'puppet://host1.domain.com/files/gmond',
	}

	file { '/tmp/ganglia-3.1.7-1.i386.rpm':
               source => 'puppet://host1.domain.com/files/ganglia-3.1.7-1.i386.rpm',
	}

	exec { 'install ganglia':
		command => 'rpm -i /tmp/ganglia-3.1.7-1.i386.rpm',
		path => '/bin:/usr/bin',
		require => File['/tmp/ganglia-3.1.7-1.i386.rpm']
	}

	file { '/etc/ganglia/gmond.conf':
		source => 'puppet://host1.domain.com/files/gmond.conf',
		require => Exec['install ganglia']
	}
}

class install-all {
	include hadoop-install
	include puppet-init
	include ganglia
}

# 通常運用は、'hadoop-settings-restart'
# Hadoopのリ再起動をしない設定変更は、'hadoop-settings'
# ノードの追加をする場合は、新しいホスト名を付けて、'install-all'
node 'host2.domain.com' { include 'hadoop-settings-restart' }
node 'host3.domain.com' { include 'hadoop-settings-restart' }
node 'host4.domain.com' { include 'hadoop-settings-restart' }
node 'host5.domain.com' { include 'hadoop-settings-restart' }

node 'host6.domain.com' { include 'hadoop-settings' }
node 'host7.domain.com' { include 'hadoop-settings' }

#node 'host8.domain.com' { include install-all}

Name: ganglia-conf
Version: 1.0
Release: 0
Group: Configs
Source: ganglia-conf-1.0.tar.gz
Summary: ganglia config files
License: ganglia
BuildRoot: /var/tmp/ganglia-conf
BuildArch: noarch

%description
Ganglia Config Files and init scripts.


%prep
%setup

/bin/rm -rf $RPM_BUILD_ROOT/etc/ganglia
/bin/rm -rf $RPM_BUILD_ROOT/etc/init.d
/bin/rm -rf $RPM_BUILD_ROOT/etc
/bin/mkdir -p $RPM_BUILD_ROOT/etc
/bin/mkdir -p $RPM_BUILD_ROOT/etc/ganglia
/bin/mkdir -p $RPM_BUILD_ROOT/etc/init.d
/bin/mkdir -p $RPM_BUILD_ROOT/var/www/html/ganglia

%install
/bin/cp etc/ganglia/gmond.conf $RPM_BUILD_ROOT/etc/ganglia/
/bin/cp etc/init.d/gmond $RPM_BUILD_ROOT/etc/init.d/
/bin/cp etc/init.d/gmetad $RPM_BUILD_ROOT/etc/init.d/
/bin/cp -R var/www/html/ganglia/* $RPM_BUILD_ROOT/var/www/html/ganglia/


%post
/sbin/chkconfig --add gmetad
/sbin/chkconfig --add gmond
/bin/mkdir -p /var/lib/ganglia/rrds
/bin/chown nobody:nobody /var/lib/ganglia/rrds

%clean
/bin/rm -rf $RPM_BUILD_ROOT

%preun
/sbin/service gmetad stop > /dev/null 2>&1
/sbin/chkconfig --del gmetad
/sbin/service gmond stop > /dev/null 2>&1
/sbin/chkconfig --del gmond


%files
/etc/ganglia/gmond.conf
/etc/init.d/gmond
/etc/init.d/gmetad
/var/www/html/ganglia

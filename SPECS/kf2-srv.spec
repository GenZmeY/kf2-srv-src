%global steamuser steam

Name:      kf2-srv
Version:   0.9.0
Release:   1%{dist}
Summary:   Killing Floor 2 server
Group:     Amusements/Games
License:   GNU GPLv3
BuildArch: noarch

Source1:   %{name}
Source2:   %{name}-beta
Source3:   %{name}.xml
Source4:   %{name}@.service
Source5:   %{name}-update.service
Source6:   %{name}-update.timer
Source7:   main.conf.template
Source8:   %{name}-beta@.service
Source9:   %{name}-beta-update.service
Source10:  %{name}-beta-update.timer
Source11:  %{name}.conf

Requires:  systemd >= 219
Requires:  steamcmd
Requires:  libxml2
Requires:  dos2unix
Requires:  curl
Requires:  grep
Requires:  coreutils
Requires:  sed
Requires:  util-linux
Requires:  sudo
Requires:  psmisc
Requires:  gawk
Requires:  multini >= 0.2.3

Provides:  %{name}

%description
Command line tool for managing a set of Killing Floor 2 servers.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT

install -m 755 -d %{buildroot}/%{_bindir}
install -m 755 -d %{buildroot}/%{_prefix}/lib/systemd/system
install -m 755 -d %{buildroot}/%{_prefix}/lib/firewalld/services
install -m 755 -d %{buildroot}/%{_sysconfdir}/%{name}/instances
install -m 755 -d %{buildroot}/%{_sysconfdir}/%{name}/instances-beta
install -m 644 -d %{buildroot}/%{_prefix}/games/%{name}
install -m 644 -d %{buildroot}/%{_prefix}/games/%{name}-beta

install -m 755 %{SOURCE1}  %{buildroot}/%{_bindir}
install -m 644 %{SOURCE2}  %{buildroot}/%{_bindir}
install -m 644 %{SOURCE3}  %{buildroot}/%{_prefix}/lib/firewalld/services
install -m 644 %{SOURCE4}  %{buildroot}/%{_prefix}/lib/systemd/system
install -m 644 %{SOURCE5}  %{buildroot}/%{_prefix}/lib/systemd/system
install -m 644 %{SOURCE6}  %{buildroot}/%{_prefix}/lib/systemd/system
install -m 644 %{SOURCE7}  %{buildroot}/%{_sysconfdir}/%{name}
install -m 644 %{SOURCE8}  %{buildroot}/%{_prefix}/lib/systemd/system
install -m 644 %{SOURCE9}  %{buildroot}/%{_prefix}/lib/systemd/system
install -m 644 %{SOURCE10} %{buildroot}/%{_prefix}/lib/systemd/system
install -m 644 %{SOURCE11} %{buildroot}/%{_sysconfdir}/%{name}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%attr(775,root,%{steamuser}) %dir               %{_prefix}/games/%{name}
%attr(775,root,%{steamuser}) %dir               %{_prefix}/games/%{name}-beta
%attr(775,root,%{steamuser}) %dir               %{_sysconfdir}/%{name}
%attr(775,root,%{steamuser}) %dir               %{_sysconfdir}/%{name}/instances
%attr(775,root,%{steamuser}) %dir               %{_sysconfdir}/%{name}/instances-beta
%attr(644,root,%{steamuser}) %config(noreplace) %{_sysconfdir}/%{name}/main.conf.template
%attr(640,root,%{steamuser}) %config(noreplace) %{_sysconfdir}/%{name}/%{name}.conf
%attr(644,root,root)         %config(noreplace) %{_prefix}/lib/firewalld/services/%{name}.xml
%attr(755,root,root)                            %{_bindir}/%{name}
%attr(755,root,root)                            %{_bindir}/%{name}-beta
%attr(644,root,root)                            %{_prefix}/lib/systemd/system/*

%preun
if [[ $1 -eq 0 ]] ; then # Uninstall
	%{_bindir}/%{name} --stop
	%{_bindir}/%{name} --disable
	rm -rf %{_prefix}/games/%{name}/*
	rm -rf %{_prefix}/games/%{name}-beta/*
	rm -rf %{_sysconfdir}/%{name}/instances/default
	rm -rf %{_sysconfdir}/%{name}/instances-beta/default
fi

%changelog
* Wed May 27 2020 GenZmeY <genzmey@gmail.com> - 0.9.0-1
- new main.conf format;
- multiple WebAdmin and http auth by default;
- online actions;
- chat-bot;
- set password;
- refactoring.

* Mon Apr 27 2020 GenZmeY <genzmey@gmail.com> - 0.8.0-1
- use multini for ini edit;
- add mutators support;
- refactoring;
- returned "reboot-updates".

* Sat Mar 7 2020 GenZmeY <genzmey@gmail.com> - 0.7.0-1
- dual versions support;
- check updates;
- bugfixes.

* Sat Jan 18 2020 GenZmeY <genzmey@gmail.com> - 0.6.0-1
- versions;
- instance conf tweaks;
- extended map list;
- clear cache on delete map;
- removed useless messages.

* Sun Jan 12 2020 GenZmeY <genzmey@gmail.com> - 0.5.0-1
- ban admin;
- map admin;
- multiple args support.

* Sun Sep 29 2019 GenZmeY <genzmey@gmail.com> - 0.4.0-1
- Reworked main.template and kf2-srv@.service;
- Add --restart option;
- --status option shows more info;
- --list option removed.

* Fri Sep 20 2019 GenZmeY <genzmey@gmail.com> - 0.3.0-1
- validate option;
- auto validate on change active branch;
- port info on --status.

* Mon Sep 16 2019 GenZmeY <genzmey@gmail.com> - 0.2.1-1
- --map-sync bugfixes.

* Mon Sep 16 2019 GenZmeY <genzmey@gmail.com> - 0.2.0-1
- Add --map-sync implementation to kf2-srv.

* Sat Sep 14 2019 GenZmeY <genzmey@gmail.com> - 0.1.0-1
- First version of spec.

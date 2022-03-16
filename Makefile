# kf2-srv is a command line tool for managing a set of Killing Floor 2 servers.
# Copyright (C) 2019-2022 GenZmeY
# mailto: genzmey@gmail.com
# 
# This file is part of kf2-srv.
#
# kf2-srv is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

NAME            := kf2-srv

SOURCEDIR       := .
RELEASEDIR      := $(SOURCEDIR)/release
DESTDIR          =
PREFIX           = /usr/local

SOURCE_MAIN      = $(SOURCEDIR)/main
SOURCE_SYSTEMD   = $(SOURCEDIR)/systemd
SOURCE_BASHCOMP  = $(SOURCEDIR)/bash_completion
SOURCE_CONFIG    = $(SOURCEDIR)/config
SOURCE_FIREWALLD = $(SOURCEDIR)/firewalld
SOURCE_LOGROTATE = $(SOURCEDIR)/logrotate
SOURCE_RSYSLOG   = $(SOURCEDIR)/rsyslog

MAINLOGDIR       = $(DESTDIR)/var/log/$(NAME)
BETALOGDIR       = $(DESTDIR)/var/log/$(NAME)-beta
CONFDIR          = $(DESTDIR)/etc/$(NAME)
BASHCOMPDIR      = $(DESTDIR)/etc/bash_completion.d
INSTMAINDIR      = $(CONFDIR)/instances
INSTBETADIR      = $(CONFDIR)/instances-beta
MAPCYCLEDIR      = $(CONFDIR)/mapcycles
CACHEDIR         = $(DESTDIR)/var/cache/$(NAME)
LOGROTATEDIR     = $(DESTDIR)/etc/logrotate.d
RSYSLOGDIR       = $(DESTDIR)/etc/rsyslog.d
UNITDIR          = $(if $(DESTDIR),$(DESTDIR)/usr/lib/systemd/system,/etc/systemd/system)
FIREWALLDDIR     = $(if $(DESTDIR),$(DESTDIR)/usr/lib/firewalld/services,/etc/firewalld/services)
BINDIR           = $(DESTDIR)$(PREFIX)/bin
GAMEDIR          = $(DESTDIR)$(PREFIX)/games
DATADIR          = $(DESTDIR)$(PREFIX)/share
SCRIPTDIR        = $(DATADIR)/$(NAME)
SCRIPTGRPDIR     = $(SCRIPTDIR)/cmdgrp
SCRIPTLIBDIR     = $(SCRIPTDIR)/lib
SCRIPTPATCHDIR   = $(SCRIPTDIR)/patch
LICENSEDIR       = $(DATADIR)/licenses/$(NAME)
KF2MAINDIR       = $(GAMEDIR)/$(NAME)
KF2BETADIR       = $(GAMEDIR)/$(NAME)-beta

BASHCHECK       := bash -n
SHELLCHECK      := shellcheck -x
SYSTEMDCHECK    := systemd-analyze verify
XMLCHECK        := xmllint --noout

.PHONY: all build build-finalize build-finalize-test filesystem install uninstall test-xml test-bash test-shellcheck test-systemd test clean

all: install

build:
	mkdir $(RELEASEDIR)
	
	cp -r $(SOURCE_MAIN)            $(RELEASEDIR)
	cp -r $(SOURCE_CONFIG)          $(RELEASEDIR)
	cp -r $(SOURCE_BASHCOMP)        $(RELEASEDIR)
	cp -r $(SOURCE_FIREWALLD)       $(RELEASEDIR)
	cp -r $(SOURCE_LOGROTATE)       $(RELEASEDIR)
	cp -r $(SOURCE_RSYSLOG)         $(RELEASEDIR)
	cp -r $(SOURCE_SYSTEMD)         $(RELEASEDIR)
	
build-finalize:
	find $(RELEASEDIR) -type f -exec sed -i 's|:DEFINE_PREFIX:|$(PREFIX)|g;' {} \;

build-finalize-test:
	find $(SOURCE_SYSTEMD)       -type f -name '*.service' -exec cp -f {} $(RELEASEDIR)/{} \;
	find $(RELEASEDIR)           -type f -exec sed -i  's|:DEFINE_PREFIX:|$(DESTDIR)$(PREFIX)|g;' {} \;
	find $(RELEASEDIR)           -type f -exec sed -i -r 's|ExecStart=.+KFGameSteamServer.bin.x86_64.*|ExecStart=/bin/bash|g;' {} \;

filesystem:
	test -d '$(CONFDIR)'        || install -m 775 -d '$(CONFDIR)'
	test -d '$(INSTMAINDIR)'    || install -m 775 -d '$(INSTMAINDIR)'
	test -d '$(INSTBETADIR)'    || install -m 775 -d '$(INSTBETADIR)'
	test -d '$(MAPCYCLEDIR)'    || install -m 775 -d '$(MAPCYCLEDIR)'
	test -d '$(CACHEDIR)'       || install -m 775 -d '$(CACHEDIR)'
	test -d '$(BINDIR)'         || install -m 755 -d '$(BINDIR)'
	test -d '$(KF2MAINDIR)'     || install -m 775 -d '$(KF2MAINDIR)'
	test -d '$(KF2BETADIR)'     || install -m 775 -d '$(KF2BETADIR)'
	test -d '$(LICENSEDIR)'     || install -m 755 -d '$(LICENSEDIR)'
	test -d '$(MAINLOGDIR)'     || install -m 770 -d '$(MAINLOGDIR)'
	test -d '$(BETALOGDIR)'     || install -m 770 -d '$(BETALOGDIR)'
	test -d '$(UNITDIR)'        || install -m 755 -d '$(UNITDIR)'
	test -d '$(FIREWALLDDIR)'   || install -m 755 -d '$(FIREWALLDDIR)'
	test -d '$(LOGROTATEDIR)'   || install -m 755 -d '$(LOGROTATEDIR)'
	test -d '$(RSYSLOGDIR)'     || install -m 755 -d '$(RSYSLOGDIR)'
	test -d '$(SCRIPTGRPDIR)'   || install -m 755 -d '$(SCRIPTGRPDIR)'
	test -d '$(SCRIPTLIBDIR)'   || install -m 755 -d '$(SCRIPTLIBDIR)'
	test -d '$(SCRIPTPATCHDIR)' || install -m 755 -d '$(SCRIPTPATCHDIR)'
	test -d '$(BASHCOMPDIR)'    || install -m 755 -d '$(BASHCOMPDIR)'

install: clean filesystem build build-finalize
	install -m 755 $(RELEASEDIR)/main/$(NAME)                             $(BINDIR)
	install -m 755 $(RELEASEDIR)/main/$(NAME)-beta                        $(BINDIR)
	
	# ugly, but works
	find $(RELEASEDIR)/main/cmdgrp                    \
		-mindepth 1                                   \
		-maxdepth 1                                   \
		-type d                                       \
		-printf "%f\n" |                              \
	while read CmdGrp;                                \
	do                                                \
		pushd   $(RELEASEDIR)/main/cmdgrp/$$CmdGrp;   \
		install -m 755 -d $(SCRIPTGRPDIR)/$$CmdGrp;   \
		install -m 644  * $(SCRIPTGRPDIR)/$$CmdGrp;   \
		popd;                                         \
	done
	
	install -m 644 $(RELEASEDIR)/main/lib/*                               $(SCRIPTLIBDIR)
	
	install -m 644 $(RELEASEDIR)/systemd/*.service                        $(UNITDIR)
	install -m 644 $(RELEASEDIR)/systemd/*.timer                          $(UNITDIR)
	
	install -m 644 $(RELEASEDIR)/firewalld/$(NAME).xml                    $(FIREWALLDDIR)
	install -m 644 $(RELEASEDIR)/logrotate/$(NAME)                        $(LOGROTATEDIR)
	install -m 644 $(RELEASEDIR)/rsyslog/$(NAME).conf                     $(RSYSLOGDIR)
	
	install -m 640 $(RELEASEDIR)/config/bot.conf                          $(CONFDIR)
	install -m 644 $(RELEASEDIR)/config/instance.conf.template            $(CONFDIR)
	install -m 644 $(RELEASEDIR)/config/$(NAME).conf                      $(CONFDIR)
	
	install -m 644 $(SOURCEDIR)/LICENSE                                   $(LICENSEDIR)/COPYING
	
	install -m 644 $(RELEASEDIR)/bash_completion/$(NAME)                  $(BASHCOMPDIR)

uninstall:
	rm -f  $(BINDIR)/$(NAME)
	rm -f  $(BINDIR)/$(NAME)-beta
	
	rm -f  $(UNITDIR)/$(NAME)@.service
	rm -f  $(UNITDIR)/$(NAME)-orig@.service
	rm -f  $(UNITDIR)/$(NAME)-beta@.service
	rm -f  $(UNITDIR)/$(NAME)-beta-orig@.service
	rm -f  $(UNITDIR)/$(NAME)-beta-update.service
	rm -f  $(UNITDIR)/$(NAME)-beta-update.timer
	rm -f  $(UNITDIR)/$(NAME)-update.service
	rm -f  $(UNITDIR)/$(NAME)-update.timer
	
	rm -f  $(FIREWALLDDIR)/$(NAME).xml
	rm -f  $(LOGROTATEDIR)/$(NAME)
	rm -f  $(RSYSLOGDIR)/$(NAME).conf
	
	rm -rf $(LICENSEDIR)
	rm -rf $(KF2MAINDIR)
	rm -rf $(KF2BETADIR)
	rm -rf $(CACHEDIR)

test-xml:
	$(XMLCHECK)        $(RELEASEDIR)/firewalld/$(NAME).xml

test-bash:
	cd $(RELEASEDIR) && grep -rlF '#!/bin/bash' . | xargs -I {} $(BASHCHECK) {}

test-shellcheck:
	cd $(RELEASEDIR) && grep -rlF '#!/bin/bash' . | xargs -I {} $(SHELLCHECK) {}

test-systemd:
	$(SYSTEMDCHECK)    $(RELEASEDIR)/systemd/$(NAME)@.service
	$(SYSTEMDCHECK)    $(RELEASEDIR)/systemd/$(NAME)-orig@.service
	$(SYSTEMDCHECK)    $(RELEASEDIR)/systemd/$(NAME)-beta@.service
	$(SYSTEMDCHECK)    $(RELEASEDIR)/systemd/$(NAME)-beta-orig@.service
	$(SYSTEMDCHECK)    $(RELEASEDIR)/systemd/$(NAME)-beta-update.service
	$(SYSTEMDCHECK)    $(RELEASEDIR)/systemd/$(NAME)-beta-update.timer
	$(SYSTEMDCHECK)    $(RELEASEDIR)/systemd/$(NAME)-update.service
	$(SYSTEMDCHECK)    $(RELEASEDIR)/systemd/$(NAME)-update.timer

test: clean build build-finalize-test test-systemd test-xml test-bash test-shellcheck

clean:
	rm -rf $(RELEASEDIR)


#!/usr/bin/make -f

rootprefix ?= /usr
rootlibexecdir ?= $(rootprefix)/lib/systemd
systemshutdowndir ?= $(rootlibexecdir)/system-shutdown

all:

clean:

install:
	install -d $(DESTDIR)$(systemshutdowndir)
	install -m 644 hdstandby.sh $(DESTDIR)$(systemshutdowndir)

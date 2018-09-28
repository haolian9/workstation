.PHONY: build daemon atatch all

all: build daemon

build: scripts/build.sh
	@ scripts/build.sh

daemon: scripts/startup.sh
	@ scripts/startup.sh

attach: scripts/attach.sh
	@ scripts/attach.sh

clean: scripts/clean.sh
	@ scripts/clean.sh

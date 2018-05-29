.PHONY: build all
.DEFAULT_GOAL: all

build: build.sh
	@ ./build.sh

daemon: startup.sh
	@ ./startup.sh

attatch: attatch.sh
	@ ./attatch.sh

all: build daemon

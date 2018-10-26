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

local_rofi_plugin_dir := ${HOME}/.local/rofi/plugins
plugin_filename := workstation_tmux_session_attacher.sh
install-rofi-plugin:
	@ if [ ! -d ${local_rofi_plugin_dir} ]; then mkdir -p ${local_rofi_plugin_dir}; fi
	@ if [ ! -f ${local_rofi_plugin_dir}/${plugin_filename} ]; then \
		ln -s ${PWD}/scripts/rofi/${plugin_filename} ${local_rofi_plugin_dir}/${plugin_filename}; fi

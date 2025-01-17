# Public, configurable variables
debootstrap_mirror	:= http://httpredir.debian.org/debian/
debootstrap_suite	:= stretch
default_image_class	:= allinone
image_dir		:= /srv/puavo-os-images
images_urlbase		:= https://images.puavo.org
mirror_dir		:= $(image_dir)/mirror
release_name            :=
rootfs_dir		:= /var/tmp/puavo-os/rootfs
target_arch             := amd64
upload_codename         := $(debootstrap_suite)
upload_dir              :=
upload_login            :=
upload_pkgregex         :=
upload_server           :=

include defaults.mk

_adm_user	:= puavo-os
_adm_group	:= puavo-os
_adm_uid	:= 1000
_adm_gid	:= 1000

ifeq "$(image_class)" ""
  image_class := $(shell cat "$(rootfs_dir)/etc/puavo-image/class" 2>/dev/null)
endif
ifeq "$(image_class)" ""
  image_class := $(shell cat /etc/puavo-image/class 2>/dev/null)
endif
ifeq "$(image_class)" ""
  image_class := $(default_image_class)
endif
ifeq "$(image_class)" ""
  $(error can not determine image class)
endif

_repo_name   := $(shell basename $(shell git rev-parse --show-toplevel))
_image_file  := $(image_dir)/$(_repo_name)-$(image_class)-$(debootstrap_suite)-$(shell date -u +%Y-%m-%d-%H%M%S)-${target_arch}.img

# Some basic dependencies for our build system.  "python3" is on this list,
# because installing "devscripts" fails if "python3" has not been installed
# earlier, working around some bug in Debian (on 2016-11-18).
_debootstrap_packages := python3,devscripts,equivs,git,jq,locales,lsb-release,\
			 make,puppet-common,sudo

_cache_configured := $(shell grep -qs puavo-os /etc/squid/squid.conf \
			 && echo true || echo false)
ifdef PUAVO_CACHE_PROXY
  _proxy_address := ${PUAVO_CACHE_PROXY}
else ifeq ($(_cache_configured),true)
  _proxy_address := localhost:3128
endif
ifdef _proxy_address
_proxywrap_cmd := $(CURDIR)/.aux/proxywrap --with-proxy $(_proxy_address)
else
_proxywrap_cmd := $(CURDIR)/.aux/proxywrap
endif

_chroot_cmd := sudo env 'PUAVO_CACHE_PROXY=$(_proxy_address)' .aux/chroot-cmd \
                    '$(rootfs_dir)'

_sudo := sudo $(_proxywrap_cmd)
export _sudo

.PHONY: build
build: build-debs-ports build-debs-parts

.PHONY: build-debs-builddeps
build-debs-builddeps:
	$(MAKE) -C debs builddeps

.PHONY: build-debs-cloud
build-debs-cloud: build-debs-builddeps
	$(MAKE) -C debs cloud

.PHONY: build-debs-parts
build-debs-parts: build-debs-builddeps
	$(MAKE) -C debs parts

.PHONY: build-debs-ports
build-debs-ports: build-debs-builddeps
	$(MAKE) -C debs ports

# mainly for development use
.PHONY: build-parts
build-parts:
	$(MAKE) -C parts

.PHONY: install
install: install-parts
	$(MAKE) apply-rules

# mainly for development use
.PHONY: install-parts
install-parts: /puavo-os
	$(_sudo) $(MAKE) -C parts install prefix=/usr sysconfdir=/etc

.PHONY: help
help:
	@echo 'Puavo OS Build System'
	@echo
	@echo 'Targets:'
	@echo '    [build]              build all'
	@echo '    apply-rules          apply all Puppet rules'
	@echo '    build-debs-cloud     build Puavo OS (cloud) Debian packages'
	@echo '    build-debs-parts     build Puavo OS Debian packages'
	@echo '    build-debs-ports     build all external Debian packages'
	@echo '    build-parts          build all parts'
	@echo '    clean                clean debs and parts'
	@echo '    help                 display this help and exit'
	@echo '    install              install all'
	@echo '    install-parts        install all parts'
	@echo '    rdiffs               make rdiffs for images (uses "rdiff_targets"-variable)'
	@echo '    rootfs-debootstrap   build Puavo OS rootfs from scratch'
	@echo '    rootfs-image         pack rootfs to a squashfs image'
	@echo '    rootfs-shell         spawn shell from Puavo OS rootfs'
	@echo '    rootfs-sync-repo     sync Puavo OS rootfs repo with the current repo'
	@echo '    rootfs-update        update Puavo OS rootfs'
	@echo '    setup-buildhost      some optional setup for buildhost'
	@echo '    update               update Puavo OS localhost'
	@echo '    upload-debs          upload debs to remote archive'
	@echo
	@echo 'Variables:'
	@echo '    debootstrap_mirror   debootstrap mirror [$(debootstrap_mirror)]'
	@echo '    image_dir            directory where images are built [$(image_dir)]'
	@echo '    images_urlbase       Prefix for image urls (https://...)'
	@echo '    mirror_dir           Mirror directory (for images and rdiffs)'
	@echo '    rootfs_dir           Puavo OS rootfs directory [$(rootfs_dir)]'

$(rootfs_dir):
	@echo ERROR: rootfs does not exist, make rootfs-debootstrap first >&2
	@false

.PHONY: rootfs-debootstrap
rootfs-debootstrap:
	@[ ! -e '$(rootfs_dir)' ] || \
		{ echo ERROR: rootfs directory '$(rootfs_dir)' already exists >&2; false; }
	$(_sudo) debootstrap					\
		--arch='$(target_arch)'				\
		--include='$(_debootstrap_packages)'	        \
		--components=main,contrib,non-free		\
		'$(debootstrap_suite)'				\
		'$(rootfs_dir).tmp' '$(debootstrap_mirror)'

	$(_sudo) git clone . '$(rootfs_dir).tmp/puavo-os'

	$(_sudo) ln -s '/puavo-os/.aux/policy-rc.d' \
		'$(rootfs_dir).tmp/usr/sbin/policy-rc.d'

	$(_sudo) mv '$(rootfs_dir).tmp' '$(rootfs_dir)'
	$(_sudo) mkdir -p '$(rootfs_dir)/etc/puavo-image'
	$(_sudo) sh -c \
	  'printf "%s\n" "$(image_class)" > $(rootfs_dir)/etc/puavo-image/class'

$(image_dir):
	$(_sudo) mkdir -p '$(image_dir)'

.PHONY: make-release-logos
make-release-logos:
	$(_sudo) /usr/lib/puavo-ltsp-client/make-release-logos

.PHONY: update-mime-database
update-mime-database:
	$(_sudo) /usr/lib/puavo-ltsp-client/update-mime-database

# Using -comp lzo instead of gzip, because we prefer to optimize decompression
# speed for faster boots, even though image sizes are slightly bigger than with
# gzip.  Especially on some hosts the decompression stage of kernel/initrd is
# very slow when gzip is used, apparently because CPUs are not in normal
# performance mode quite yet.
# Using -no-sparse to workaround bug
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=869771.
# May be removed only when sure that grub has been updated on all hosts
# updating to images made with this.
.PHONY: rootfs-image
rootfs-image: $(rootfs_dir) $(image_dir)
	$(_sudo) rsync -a '$(rootfs_dir)/var/cache/' \
	    '$(rootfs_dir).var_cache_backup/'
	$(_sudo) .aux/set-image-release '$(rootfs_dir)' \
	    '$(notdir $(_image_file))' '$(release_name)'
	$(_chroot_cmd) $(MAKE) -C '/puavo-os' make-release-logos
	$(_chroot_cmd) $(MAKE) -C '/puavo-os' update-mime-database
	$(_sudo) mksquashfs '$(rootfs_dir)' '$(_image_file).tmp'	\
		-noappend -no-recovery -no-sparse -wildcards -comp lzo	\
		-ef 'config/excludes/$(image_class)'		        \
		|| { rm -f '$(_image_file).tmp'; false; }
	$(_sudo) mv '$(_image_file).tmp' '$(_image_file)'
	@echo Built '$(_image_file)' successfully.

.PHONY: rootfs-shell
rootfs-shell: $(rootfs_dir)
	$(_chroot_cmd) '/puavo-os/.aux/proxywrap' sh -c 'cd ~ && exec bash'

.PHONY: rootfs-sync-repo
rootfs-sync-repo: $(rootfs_dir)
	$(_sudo) .aux/create-adm-user '$(rootfs_dir)' '/puavo-os' \
	    '$(_adm_user)' '$(_adm_group)' '$(_adm_uid)' '$(_adm_gid)'
	$(_sudo) rsync "--chown=$(_adm_uid):$(_adm_gid)" --chmod=Dg+s,ug+w \
	    -glopr --exclude debs/.archive --exclude debs/.workdir \
	    . '$(rootfs_dir)/puavo-os/'

.PHONY: rootfs-update
rootfs-update: rootfs-sync-repo
	$(_chroot_cmd) $(MAKE) -C '/puavo-os' update

.PHONY: setup-buildhost
setup-buildhost:
	.aux/setup-buildhost

/etc/puavo-conf/image.json: config/puavo_conf.json
	$(_sudo) mkdir -p $(@D)
	$(_sudo) cp $< $@

/etc/puavo-conf/rootca.pem: config/rootca
	$(_sudo) mkdir -p $(@D)
	@if $(_sudo) sh -c 'cat $</*.pem > $@' 2>/dev/null; then \
	  echo 'Created/updated $@'; \
        else \
	  echo 'Could not create $@, do you have any certificates in $< ?' >&2; \
          $(_sudo) rm -f $@; \
	  exit 1; \
	fi

.PHONY: update
update: prepare /etc/puavo-conf/image.json /etc/puavo-conf/rootca.pem
	$(MAKE) build

	$(_sudo) apt-get update
	$(_sudo) apt-get dist-upgrade -V -y			\
		-o Dpkg::Options::="--force-confdef"	\
		-o Dpkg::Options::="--force-confold"

	$(MAKE) apply-rules

	$(_sudo) update-initramfs -u -k all
	$(_sudo) updatedb

.PHONY: prepare
prepare:
	$(MAKE) -C debs prepare
	$(_sudo) env 'FACTER_localmirror=$(CURDIR)/debs/.archive' \
	    FACTER_puavoruleset=prepare .aux/apply-rules

.PHONY: upload-debs
upload-debs:
	dput puavo debs/.archive/pool/*.changes

.PHONY: apply-rules
apply-rules: /puavo-os
	$(_sudo) .aux/setup-debconf
	$(_sudo) env 'FACTER_localmirror=$(CURDIR)/debs/.archive' \
	    'FACTER_puavoruleset=$(image_class)' .aux/apply-rules

.PHONY: rdiffs
rdiffs: $(image_dir) $(mirror_dir)
	$(_sudo) .aux/make-rdiffs image_dir="$(image_dir)" \
		images_urlbase="$(images_urlbase)" \
		mirror_dir="$(mirror_dir)" $(rdiff_targets)

.PHONY: clean
clean:
	$(MAKE) -C debs clean
	$(MAKE) -C parts clean

$(mirror_dir):
	$(_sudo) mkdir -p '$(mirror_dir)'

/puavo-os:
	@echo ERROR: localhost is not Puavo OS system >&2
	@false

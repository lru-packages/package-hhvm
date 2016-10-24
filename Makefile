NAME=hhvm
VERSION=3.15.2
EPOCH=1
ITERATION=1
PREFIX=/usr/local
LICENSE=PHP
VENDOR="Facebook"
MAINTAINER="Ryan Parman"
DESCRIPTION="HHVM is an alternative PHP runtime developed by Facebook which aims to speed-up runtime performance, and implements a few new features."
URL=https://hhvm.com
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)
COMMIT=$(shell echo "HHVM-$(VERSION)")

# https://docs.hhvm.com/hhvm/installation/building-from-source
# https://github.com/facebook/hhvm/wiki/Building-and-installing-hhvm-on-CentOS-7.x
# https://github.com/facebook/hhvm/wiki/Building-and-installing-HHVM-on-RHEL-7
# https://github.com/facebook/hhvm/wiki/Building-and-installing-HHVM-on-Amazon-Linux-2014.03


#-------------------------------------------------------------------------------

all: info install-deps compile install-tmp package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "EPOCH:       $(EPOCH)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* hhvm*

#-------------------------------------------------------------------------------

.PHONY: install-deps
install-deps:
	yum install -y \
		binutils-devel \
		boost-devel \
		bzip2-devel \
		cmake3 \
		cpp \
		double-conversion-devel \
		elfutils-libelf-devel \
		enca \
		expat-devel \
		fastlz-devel \
		fribidi-devel \
		gcc-c++ \
		git \
		glib2-devel \
		glog-devel \
		gmp-devel \
		gperf \
		ImageMagick-devel \
		jemalloc-devel \
		libc-client-devel \
		libcap-devel \
		libcurl-devel \
		libdwarf-devel \
		libedit-devel \
		libevent-devel \
		libicu-devel \
		libjpeg-turbo-devel \
		libmcrypt-devel \
		libmemcached-devel \
		libpng-devel \
		libunwind-devel \
		libvpx-devel \
		libxml2-devel \
		libxslt-devel \
		libyaml-devel \
		libzip-devel \
		lz4-devel \
		make \
		mariadb \
		mariadb-devel \
		mariadb-server \
		numactl-devel \
		ocaml \
		oniguruma-devel \
		openldap-devel \
		openssl-devel \
		pcre-devel \
		psmisc \
		re2-devel \
		readline-devel \
		sqlite-devel \
		tbb-devel \
		unixODBC-devel \
	;

#-------------------------------------------------------------------------------

.PHONY: compile
compile:
	git clone -q -b $(COMMIT) https://github.com/facebook/hhvm.git --depth=1
	cd hhvm && \
		git submodule update --init --recursive && \
		cmake -DMYSQL_UNIX_SOCK_ADDR=/var/run/mysqld/mysqld.sock . && \
		make -j $(shell nproc --all) \
	;

	git clone -q https://github.com/skyfms/hhvm-ext_dbase.git --depth=1
	cd hhvm-ext_dbase && \
		./build.sh \
	;

#-------------------------------------------------------------------------------

.PHONY: install-tmp
install-tmp:
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION);
	cd hhvm && \
		make install DESTDIR=/tmp/installdir-$(NAME)-$(VERSION);

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-f \
		-d "ocaml" \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--epoch $(EPOCH) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG.txt \
		--rpm-dist el$(RHEL) \
		--rpm-auto-add-directories \
		usr/local/bin \
		usr/local/include \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo/

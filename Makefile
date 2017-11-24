NAME=hhvm
VERSION=3.23.2
ITERATION=1.lru
PREFIX=/usr/local
LICENSE=PHP
VENDOR="Facebook"
MAINTAINER="Ryan Parman"
DESCRIPTION="HHVM is a runtime for Hacklang and PHP 5, developed by Facebook, which aims to speed-up runtime performance, and implements a few new features."
URL=https://hhvm.com
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)
COMMIT=$(shell echo "HHVM-$(VERSION)")

# https://docs.hhvm.com/hhvm/installation/building-from-source
# https://github.com/facebook/hhvm/wiki/Building-and-installing-hhvm-on-CentOS-7.x
# https://github.com/facebook/hhvm/wiki/Building-and-installing-HHVM-on-RHEL-7
# https://github.com/facebook/hhvm/wiki/Building-and-installing-HHVM-on-Amazon-Linux-2014.03


#-------------------------------------------------------------------------------

all: info install-deps compile-hhvm compile-ext-dbase compile-ext-msgpack compile-ext-uuid package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
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
	rm -Rf /tmp/installdir* hhvm* mongo* msgpack*

#-------------------------------------------------------------------------------

.PHONY: install-deps
install-deps:
	yum install -y \
		binutils-devel \
		boost-devel \
		bzip2-devel \
		cmake \
		cmake3 \
		cpp \
		double-conversion-devel \
		elfutils-libelf-devel \
		enca \
		expat-devel \
		fastlz-devel \
		fribidi-devel \
		gcc6 \
		gdal-devel \
		geoip-devel \
		gflags-devel \
		git \
		glib2-devel \
		glog-devel \
		gmp-devel \
		gperf \
		hdf5-1.8.12* \
		ImageMagick-devel \
		inotify-tools-devel \
		jemalloc-devel \
		libbson-devel \
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
		libticonv \
		libunwind-devel \
		libuuid-devel \
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
		postgresql-devel \
		psmisc \
		re2-devel \
		readline-devel \
		shapelib-devel \
		shapelib-tools \
		sqlite-devel \
		ssdeep-devel \
		tbb-devel \
		unixODBC-devel \
	;

	ldconfig
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION);

#-------------------------------------------------------------------------------

.PHONY: compile-hhvm
compile-hhvm:
	if [ ! -d "./hhvm" ]; then git clone -q -b $(COMMIT) https://github.com/facebook/hhvm.git --depth=1; fi;
	cd hhvm && \
		export HPHP_HOME=$(shell echo "$$(pwd)/hhvm") && \
		git submodule update --init --recursive && \
		cmake -DCMAKE_CXX_COMPILER=$$(which g++) -DCMAKE_C_COMPILER=$$(which gcc) -DCMAKE_C_COMPILER=$$(which gcc) -DMYSQL_UNIX_SOCK_ADDR=/var/run/mysqld/mysqld.sock . && \
		make install && \
		make install DESTDIR=/tmp/installdir-$(NAME)-$(VERSION) && \
		chmod +x $$(pwd)/hphp/tools/hphpize/hphpize \
	;

.PHONY: compile-ext-dbase
compile-ext-dbase:
	if [ ! -d "./hhvm-ext_dbase" ]; then git clone -q https://github.com/skyfms/hhvm-ext_dbase.git --depth=1; fi;
	cd hhvm-ext_dbase && \
		export HPHP_HOME=$(shell echo "$$(pwd)/hhvm") && \
		./build.sh && \
		make install DESTDIR=/tmp/installdir-$(NAME)-$(VERSION) \
	;

.PHONY: compile-ext-geoip
compile-ext-geoip:
	if [ ! -d "./hhvm-ext-geoip" ]; then git clone -q https://github.com/vipsoft/hhvm-ext-geoip.git --depth=1; fi;
	cd hhvm-ext-geoip && \
		export HPHP_HOME=$(shell echo "$$(pwd)/hhvm") && \
		./build.sh && \
		make install DESTDIR=/tmp/installdir-$(NAME)-$(VERSION) \
	;

.PHONY: compile-ext-uuid
compile-ext-uuid:
	if [ ! -d "./hhvm-ext-uuid" ]; then git clone -q https://github.com/vipsoft/hhvm-ext-uuid.git --depth=1; fi;
	cd hhvm-ext-uuid && \
		export HPHP_HOME=$(shell echo "$$(pwd)/hhvm") && \
		./build.sh && \
		make install DESTDIR=/tmp/installdir-$(NAME)-$(VERSION) \
	;

.PHONY: compile-ext-msgpack
compile-ext-msgpack:
	if [ ! -d "./msgpack-hhvm" ]; then git clone -q https://github.com/reeze/msgpack-hhvm.git --depth=1; fi;
	cd msgpack-hhvm && \
		export HPHP_HOME=$(shell echo "$$(pwd)/hhvm") && \
		hphpize && \
		cmake . && \
		make && \
		make install DESTDIR=/tmp/installdir-$(NAME)-$(VERSION) \
	;

# .PHONY: compile-ext-mongodb
# compile-ext-mongodb:
# 	if [ ! -d "./mongo-hhvm-driver" ]; then git clone -q https://github.com/mongodb/mongo-hhvm-driver.git --recursive --depth=1; fi;
# 	cd mongo-hhvm-driver && \
#		export HPHP_HOME=$(shell echo "$$(pwd)/hhvm") && \
# 		hphpize && \
# 		cmake . && \
# 		make configlib && \
# 		make -j $(shell nproc --all) && \
# 		make install DESTDIR=/tmp/installdir-$(NAME)-$(VERSION) \
# 	;

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-f \
		-d "boost" \
		-d "double-conversion" \
		-d "fastlz" \
		-d "fribidi" \
		-d "glog" \
		-d "ImageMagick" \
		-d "jemalloc" \
		-d "libc-client" \
		-d "libjpeg-turbo" \
		-d "libmcrypt" \
		-d "libmemcached" \
		-d "libpng" \
		-d "libpqxx" \
		-d "libvpx" \
		-d "libxslt" \
		-d "lz4" \
		-d "ocaml" \
		-d "oniguruma" \
		-d "re2" \
		-d "tbb" \
		-d "unixODBC" \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
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
		usr/local/lib64 \
		usr/local/share \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo/

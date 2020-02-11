GOEXEC ?= go
# Dragonboat is known to work on -
# Linux AMD64, Linux ARM64, MacOS, Windows/MinGW and FreeBSD AMD64
# only Linux AMD64 is officially supported
OS := $(shell uname)
# the location of this Makefile
PKGROOT=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ROCKSDB_SO_FILE=librocksdb.so
# RocksDB version 5 or 6 are required
ROCKSDB_INC_PATH ?=
ROCKSDB_LIB_PATH ?=
# figure out where is the rocksdb installation
# supported gorocksdb version in ./build/lib?
ifeq ($(ROCKSDB_LIB_PATH),)
ifeq ($(ROCKSDB_INC_PATH),)
ifneq ($(wildcard $(PKGROOT)/build/lib/$(ROCKSDB_SO_FILE)),)
ifneq ($(wildcard $(PKGROOT)/build/include/rocksdb/c.h),)
$(info rocksdb lib found at $(PKGROOT)/build/lib/$(ROCKSDB_SO_FILE))
ROCKSDB_LIB_PATH=$(PKGROOT)/build/lib
ROCKSDB_INC_PATH=$(PKGROOT)/build/include
endif
endif
endif
endif

# in /usr/local/lib?
ifeq ($(ROCKSDB_LIB_PATH),)
ifeq ($(ROCKSDB_INC_PATH),)
ifneq ($(wildcard /usr/local/lib/$(ROCKSDB_SO_FILE)),)
ifneq ($(wildcard /usr/local/include/rocksdb/c.h),)
$(info rocksdb lib found at /usr/local/lib/$(ROCKSDB_SO_FILE))
ROCKSDB_LIB_PATH=/usr/local/lib
ROCKSDB_INC_PATH=/usr/local/include
endif
endif
endif
endif

ifeq ($(OS),Linux)
ROCKSDB_LIB_FLAG=-lrocksdb -ldl
else
ROCKSDB_LIB_FLAG=-lrocksdb
endif

###############################################################################
# download and install rocksdb
###############################################################################
LIBCONF_PATH=/etc/ld.so.conf.d/usr_local_lib.conf
# set the variables below to tell the Makefile which version of rocksdb you
# want to install. rocksdb v5.13.4 is the version we used in production, it is
# used here as the default, feel free to change to the version number you like
#
# rocksdb 6.3.x or 6.4.x is required
ROCKSDB_MAJOR_VER=6
ROCKSDB_MINOR_VER=4
ROCKSDB_PATCH_VER=6
ROCKSDB_VER ?= $(ROCKSDB_MAJOR_VER).$(ROCKSDB_MINOR_VER).$(ROCKSDB_PATCH_VER)

RDBDIR=$(PKGROOT)/rocksdb
RDBTMPDIR=$(RDBDIR)/build

RDBURL=https://github.com/facebook/rocksdb/archive/v$(ROCKSDB_VER).tar.gz
build-rocksdb: get-rocksdb make-rocksdb
build-rocksdb-static: get-rocksdb make-rocksdb-static
build-original-rocksdb : get-rocksdb make-rocksdb
get-rocksdb:
		@{ \
				set -e; \
				if [ ! -d $(RDBDIR) ]; \
					then mkdir -p $(RDBDIR); \
				fi; \
				if [ ! -f $(RDBDIR)/v$(ROCKSDB_VER).tar.gz ]; \
					then wget $(RDBURL) -P $(RDBDIR); \
				fi; \
				rm -rf $(RDBTMPDIR); \
				mkdir -p $(RDBTMPDIR); \
				tar xzvf $(RDBDIR)/v$(ROCKSDB_VER).tar.gz -C $(RDBTMPDIR); \
		}
make-rocksdb:
		@EXTRA_CXXFLAGS=-DROCKSDB_NO_DYNAMIC_EXTENSION make -C $(RDBTMPDIR)/rocksdb-$(ROCKSDB_VER) -j8 shared_lib
make-rocksdb-static:
		@EXTRA_CXXFLAGS=-DROCKSDB_NO_DYNAMIC_EXTENSION make -C $(RDBTMPDIR)/rocksdb-$(ROCKSDB_VER) -j8 static_lib
ldconfig-rocksdb-lib-ull:
		if [ $(OS) = Linux ]; then \
				sudo sh -c "if [ ! -f $(LIBCONF_PATH) ]; \
						then touch $(LIBCONF_PATH); \
						fi"; \
				sudo sh -c "if ! egrep -q '/usr/local/lib' $(LIBCONF_PATH); \
						then echo '/usr/local/lib' >> $(LIBCONF_PATH); \
						fi"; \
				sudo ldconfig; \
		fi
install-rocksdb-lib-ull:
		@{ \
				set -e; \
				sudo INSTALL_PATH=/usr/local make -C \
						$(RDBTMPDIR)/rocksdb-$(ROCKSDB_VER) install-shared; \
				rm -rf $(RDBTMPDIR); \
		}
install-rocksdb-lib-ull-static:
		@{ \
				set -e; \
				sudo INSTALL_PATH=/usr/local make -C \
				$(RDBTMPDIR)/rocksdb-$(ROCKSDB_VER) install-static; \
				rm -rf $(RDBTMPDIR); \
  		}
do-install-rocksdb-ull: install-rocksdb-lib-ull ldconfig-rocksdb-lib-ull
do-install-rocksdb:
		@(INSTALL_PATH=$(PKGROOT)/build make -C \
				$(RDBTMPDIR)/rocksdb-$(ROCKSDB_VER) install-shared && rm -rf $(RDBTMPDIR))

install-rocksdb-ull-darwin: build-rocksdb install-rocksdb-ull
install-rocksdb-ull: build-rocksdb do-install-rocksdb-ull
install-rocksdb-ull-static: build-rocksdb-static install-rocksdb-lib-ull-static
install-rocksdb: build-rocksdb do-install-rocksdb
install-original-rocksdb-ull: build-original-rocksdb do-install-rocksdb-ull
install-original-rocksdb: build-original-rocksdb do-install-rocksdb

###############################################################################
# download and install mcl
###############################################################################

MCLDIR=$(PKGROOT)/mcl
MCLTMPDIR=$(PKGROOT)/mcl/build

build-mcl: get-mcl make-mcl
get-mcl:
		@{ \
				set -e; \
				if [ ! -d $(MCLDIR) ]; \
					then git clone https://github.com/herumi/mcl.git; \
				fi;\
		}
make-mcl:
		@{ \
				set -e; \
				if [ ! -d $(MCLTMPDIR) ]; \
					then mkdir -p $(MCLTMPDIR); \
				fi; \
				cd $(MCLTMPDIR); \
				cmake ..;  \
				make;  \
		}
do-install-mcl-ull:
		@{ \
				set -e; \
				cd $(MCLTMPDIR); \
				sudo make install; \
				ldconfig;  \
		}
install-mcl-ull: build-mcl do-install-mcl-ull

all: install-mcl-ull install-rocksdb
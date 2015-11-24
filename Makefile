PROJNAME=github.com/hlandau/acme/cmd/acmetool
BINARIES=$(PROJNAME)

###############################################################################
# v1.5  NNSC:github.com/hlandau/degoutils/_stdenv/Makefile.ref
# This is a standard Makefile for building Go code designed to be copied into
# other projects. Code below this line is not intended to be modified.

-include Makefile.extra
-include Makefile.assets

## Paths
ifeq ($(GOPATH),)
# for some reason export is necessary for FreeBSD's gmake
export GOPATH := $(shell pwd)
endif
ifeq ($(GOBIN),)
export GOBIN := $(GOPATH)/bin
endif
ifeq ($(PREFIX),)
export PREFIX := /usr/local
endif

DIRS=src bin public

## Quieting
Q=@
QI=@echo -e "\t[$(1)]\t  $(2)";
ifeq ($(V),1)
	Q=
	QI=
endif

## Buildinfo
BUILDINFO=$(shell (echo built `date -u "+%Y%m%d%H%M%S"` on `hostname -f`; go list -f '{{range $$imp := .Deps}}{{printf "%s\n" $$imp}}{{end}}' $(1) | sort -u | xargs go list -f '{{if not .Standard}}{{.ImportPath}}{{end}}' | awk "{print \"$$GOPATH/src/\" \$$0}" | (while read line; do x="$$line"; while [ ! -e "$$x/.git" -a ! -e "$$x/.hg" ]; do x=$${x%/*}; if [ "$$x" = "" ]; then break; fi; done; echo "$$x"; done) | sort -u | (while read line; do echo git $${line\#$$GOPATH/src/} $$(git -C "$$line" rev-parse HEAD) $$(git -C "$$line" describe --all --dirty=+ --abbrev=99 --always); done)) | base64 -w 0)
BUILDINFO_FLAG=

ifeq ($(USE_BUILDINFO),1)
	BUILDINFO_FLAG= -ldflags "-X github.com/hlandau/degoutils/buildinfo.RawBuildInfo=$(call BUILDINFO,$(1))"
endif

## Standard Rules
all: $(DIRS)
	$(call QI,GO-INSTALL,$(BINARIES))go install $(BUILDFLAGS) $(call BUILDINFO_FLAG,$(BINARIES)) $(BINARIES)

$(DIRS): | .gotten
	$(call QI,DIRS)mkdir -p $(GOPATH)/src $(GOBIN); \
	if [ ! -e "src" ]; then \
	  ln -s $(GOPATH)/src src; \
	fi; \
	if [ ! -e "bin" ]; then \
		ln -s $(GOBIN) bin; \
	fi

.gotten:
	$(call QI,GO-GET,$(PROJNAME))go get $(PROJNAME)
	$(Q)touch .gotten

.NOTPARALLEL: $(DIRS)

test:
	$(call QI,GO-TEST,$(PROJNAME))for x in $(PROJNAME); do go test -cover -v $$x/...; done

install: all
	$(call QI,INSTALL,acmetool)install -Dp $(GOBIN)/acmetool $(DESTDIR)$(PREFIX)/bin

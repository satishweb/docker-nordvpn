IMAGE=satishweb/nordvpn
PLATFORMS=linux/amd64,linux/arm64,linux/arm/v7,linux/ppc64le
WORKDIR=$(shell pwd)
TAGNAME?=devel
ifdef PUSH
	EXTRA_BUILD_PARAMS = --push-images --push-git-tags
endif

ifdef LATEST
	EXTRA_BUILD_PARAMS += --mark-latest
endif

ifdef NO-CACHE
	EXTRA_BUILD_PARAMS += --no-cache
endif

all:
	TAGNAME=$$(set -x && \
	docker run --rm --entrypoint=bash ubuntu:18.04 -c \
		"set -x; \
		apt update -yqq>/dev/null 2>&1 && \
		apt-get install -yqq wget >/dev/null 2>&1 && \
		wget -q https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb -O /tmp/nordrepo.deb >/dev/null 2>&1 && \
		apt-get install -yqq /tmp/nordrepo.deb >/dev/null 2>&1 && \
		apt-get update -yqq >/dev/null 2>&1 && \
		apt-cache madison nordvpn \
		|head -1 \
		|cut -d \| -f 2 \
		|sed 's/ //g'" \
	) ;\
	${MAKE} build TAGNAME=$$TAGNAME

build:
	./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${PLATFORMS}" \
	  --work-dir "${WORKDIR}" \
	  --git-tag "${TAGNAME}" \
	  ${EXTRA_BUILD_PARAMS}

test:
	docker build -t ${IMAGE}:${TAGNAME} .

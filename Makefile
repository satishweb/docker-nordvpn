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
	docker run --rm --entrypoint=bash ubuntu:20.04 -c \
		"set -x; \
		apt update -yqq>/dev/null 2>&1 && \
		apt-get install -yqq wget >/dev/null 2>&1 && \
		wget -q https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/ -O - \
		|sed 's|</b>|-|g' | sed 's|<[^>]*>||g'|grep arm64.deb|tail -1|cut -d '_' -f 2" \
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

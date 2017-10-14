.DEFAULT_GOAL := build

VERSION := 1.0.1
BUILDNUMBER := 1

# fpm settings
NAME := postforward
ARCH := x86_64
MAINTAINER := Nick Groenen <nick@groenen.me>
DESCRIPTION := Postfix SRS forwarding agent
EXTRA_ARGS :=


.PHONY: build
build:
	go build -ldflags="-s -w" *.go


.PHONY: debian
debian:
	mkdir -p usr/bin
	GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o usr/bin/postforward *.go

	fpm -f -t deb -s dir \
		--name "$(NAME)" \
		--version "$(VERSION)-$(BUILDNUMBER)" \
		--architecture "$(ARCH)" \
		--maintainer "$(MAINTAINER)" \
		--description "$(DESCRIPTION)" \
		$(EXTRA_ARGS) \
		usr/


.PHONY: freebsd
freebsd:
	mkdir -p usr/local/bin
	GOOS=freebsd GOARCH=amd64 go build -ldflags="-s -w" -o usr/local/bin/postforward *.go

	fpm -f -t freebsd -s dir \
		--name "$(NAME)" \
		--version "$(VERSION)-$(BUILDNUMBER)" \
		--architecture "$(ARCH)" \
		--maintainer "$(MAINTAINER)" \
		--description "$(DESCRIPTION)" \
		$(EXTRA_ARGS) \
		usr/

.PHONY: clean
clean:
	rm -rf postforward usr/ *.txz *.deb

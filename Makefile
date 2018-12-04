name ?= goldpinger
version ?= 1.0.1
bin ?= goldpinger
pkg ?= "github.com/bloomberg/goldpinger.git"
tag = $(name):$(version)
namespace ?= ""
files = $(shell find . -iname "*.go")

clean:
	rm -rf ./vendor
	rm -f ./bin/$(bin)

vendor:
	rm -rf ./vendor
	dep ensure -v

swagger:
	swagger generate server -t pkg -f ./swagger.yml --exclude-main -A goldpinger && \
	swagger generate client -t pkg -f ./swagger.yml -A goldpinger

bin/$(bin): $(files)
	PKG=${pkg} ARCH=amd64 VERSION=${version} BIN=${bin} ./build/build.sh

build: bin/$(bin)
	sudo docker build -t $(tag) -f ./build/Dockerfile .

tag:
	sudo docker tag $(tag) $(namespace)$(tag)

push:
	sudo docker push $(namespace)$(tag)

run:
	go run ./cmd/goldpinger/main.go

.PHONY: clean vendor build-swagger build tag push run
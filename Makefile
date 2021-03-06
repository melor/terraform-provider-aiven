ci: lint bins
.PHONY: ci

#################################################
# Bootstrapping for base golang package deps
#################################################
BOOTSTRAP=\
	github.com/golang/dep/cmd/dep \
	github.com/alecthomas/gometalinter \
	github.com/gobuffalo/packr/...

$(BOOTSTRAP):
	go get -u $@

bootstrap: $(BOOTSTRAP)
	gometalinter --install

vendor: Gopkg.lock
	dep ensure -v -vendor-only

update-vendor:

.PHONY: $(BOOTSTRAP)

#################################################
# Building
#################################################

bins: vendor
	GOOS=linux GOARCH=amd64 packr build -o terraform-provider-aiven-linux_amd64 .
	GOOS=darwin GOARCH=amd64 packr build -o terraform-provider-aiven-darwin_amd64 .

#################################################
# Testing and linting
#################################################
LINTERS=\
	gofmt \
	golint \
	gosimple \
	vet \
	misspell \
	ineffassign \
	deadcode
METALINT=gometalinter --tests --disable-all --vendor --deadline=5m -e "zz_.*\.go" \
	 ./... --enable

test: vendor
	CGO_ENABLED=0 go test -v ./...

lint: $(LINTERS)

$(LINTERS): vendor
	$(METALINT) $@

.PHONY: $(LINTERS) test lint

#!/bin/bash

SERVICE_NAME=$1
RELEASE_VERSION=$2

sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Create golang directory if it doesn't exist
mkdir -p golang

protoc --go_out=./golang --go_opt=paths=source_relative \
 --go-grpc_out=./golang --go-grpc_opt=paths=source_relative \
 ./${SERVICE_NAME}/*.proto

# Check if the service directory was created
if [ -d "golang/${SERVICE_NAME}" ]; then
    cd golang/${SERVICE_NAME}
    go mod init github.com/MHS-20/Order-Proto/golang/${SERVICE_NAME} ||true
    go mod tidy
    cd ../../
else
    echo "Warning: golang/${SERVICE_NAME} directory not created. Skipping Go module initialization."
fi

git add . && git commit -am "proto update" || true
git tag -fa golang/${SERVICE_NAME}/${RELEASE_VERSION} \
 -m "golang/${SERVICE_NAME}/${RELEASE_VERSION}"
git push origin refs/tags/golang/${SERVICE_NAME}/${RELEASE_VERSION}
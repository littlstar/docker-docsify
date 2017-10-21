## Container base
from node:alpine
maintainer "Joseph Werle <werle@littlstar.com>"

## Container labels
label docker_docsify_version_major="1"
label docker_docsify_version_minor="0"
label docker_docsify_version_patch="0"
label docker_docsify_version_revision="1"
label docker_docsify_version="1.0.0.1"

## Container setup
run npm install -g docsify-cli@latest
run mkdir -p /usr/local/docsify

## Container dnvironment variables
env DEBUG 0
env PORT 3000
env DOCSIFY_VERSION latest
env NODE_VERSION alpine

## Container runtime configuration
expose 3000
workdir /usr/local/docsify

## Container entry point
entrypoint [ "docsify", "serve", "--port", "3000" ]

## Container entry point default arguments
cmd [ "." ]

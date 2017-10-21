docker-docsify
==============

[docsify][docsify] as a [docker](https://www.docker.com/)
([moby](https://github.com/moby/moby)) container.


## Usage

`docker-docsify` can be used in several ways.

### As an executable

You can invoke the container as an executable directly:

```sh
$ docker run \
  --port 3000:3000 \
  --volume /path/to/docs:/usr/local/docsify \
  littlstar/docsify
```

`docker-docsify` set the working directory to `/usr/local/docsify` in
the container. This makes it easy to bind a local path on disk to the
container. By default the container executes `docsify serve --port 3000 .`.

### From a Dockerfile

You can use the image as a base in a `Dockerfile`:

```Dockerfile
FROM littlstar/docsify
ADD /path/to/docs .
```

An image can be built and then executed.

```sh
$ docker build -t mydocs .
$ docker run -p 3000:3000 mydocs # server running on localhost:3000
```

## Building a custom docker-docsify

`docker-docsify` can be built with custom settings. This is useful for
things like enabling [ssr](https://docsify.now.sh/ssr). The `./configure`
script in this repository generates a `Dockerfile` and `Makefile`.

Clone this repository before continuing.

### Configuring a build

You should have the `docker` command available in your `$PATH` before
you can generate a `Dockerfile` or `Makefile`.

`docker-docsify` can be configured by executing the `./configure` script
in the familiar way. It accepts several flags that allow you to
configure the way `docker-docsify` is built and used.

#### Configure flags

Below is a list of flags and options that can be given to the `./configure`
script used to generate the `Dockerfile` and `Makefile` suitable to build the image.

```sh
  -h, --help                    Print this message
  -V, --version                 Output version

  --debug=[DEBUG]               Configures the DEBUG environment variable for the Docker container
  --prefix=PREFIX               Docsify docker working directory path (default: /usr/local/docsify)
  --port=PORT                   Server port exposed by Docker and the Docsify server should listen on (default: 3000)
  --ssr                         Enable SSR server

  --docsify-default-path=PATH   The default docsify path when starting the server (defualt: .)
  --docsify-version=VERSION     Docsify (CLI) version to use (default: latest)
  --docsify-module=NAME         The module name to install from name (default: docsify-cli)

  --docker-base=IMAGE           The base docker image to base the docker build from (default: node)
  --docker-bin=PATH             The path to the docker binary (default: /usr/bin/docker)
  --docker-tag=TAG              The Docker tag to use when building the container (default: littlstar/docsify)
  --docker-file=PATH            The Dockerfile path (default: Dockerfile)
  --docker-flags=" ...FLAGS"    A space separated list of flags to pass to `docker build'

  --node-version=VERSION        Node.js version to use (default: latest)

```

#### Configure files

The `./configure` script generates template files from any file found in the
same directory with a `.in` extension. This could be useful for generating
intermediate files that leverage the same configuration information given to
all template files like `Dockerfile.in` and `Makefile.in`.

#### Configure template variables

Below are the available template variables in the `./configure` script.
THey can be accessed in a template (`.in`) file with the syntax
`@VARIABLE_NAME@`.

```sh
OS "Operating System"
DEBUG "An optional DEBUG environment variable"
PREFIX "Default installation prefix"
SERVER_PORT "The server port to listen on"
NODE_VERSION "The base Node.js container version"

DOCKER "Docker binary path"
DOCKER_TAG "Docker build tag"
DOCKER_BASE "Docker base image"
DOCKER_FILE "Dockerfile path"
DOCKER_FLAGS "Docker build flags"

VERSION_MAJOR "The major version of the docker container"
VERSION_MINOR "The minor version of the docker container"
VERSION_PATCH "The patch version of the docker container"
VERSION_REVISION "The revision version of the docker container"

DOCSIFY_VERSION "The docsify-cli version to use"
DOCSIFY_CLI_NAME "The command line program name to invoke"
DOCSIFY_CLI_COMMAND "The docsify-cli command to use"
DOCSIFY_CLI_MODULE_NAME "The module name to install from npm"
DOCSIFY_CLI_DEFAULT_PATH "The default path for the docsify-cli command"
```

### Building

The container can be built with `make`. You may need to invoke with
`sudo`

```sh
$ make build
```

The container can be removed with the `clean` target.

```sh
$ make clean
```

## Docker container

The docker container outlined by the `Dockerfile` contains labels, defines
environment variables, exposes ports, sets a working directory, and has
an entry point with default arguments.

### Labels

The following labels are exposed in the docker container:

#### docker_docsify_version_major

The major version of the docker container.

```Dockerfile
label docker_docsify_version_major="@VERSION_MAJOR@"
```

#### docker_docsify_version_minor

The minor version of the docker container.

```Dockerfile
label docker_docsify_version_minor="@VERSION_MINOR@"
```

#### docker_docsify_version_patch

The patch version of the docker container.

```Dockerfile
label docker_docsify_version_patch="@VERSION_PATCH@"
```

#### docker_docsify_version_revision

The revision version of the docker container.

```Dockerfile
label docker_docsify_version_revision="@VERSION_REVISION@"
```

#### docker_docsify_version

The major, minor, patch, and revision versions concatenated with `.`.

```Dockerfile
label docker_docsify_version="@VERSION_MAJOR@.@VERSION_MINOR@.@VERSION_PATCH@.@VERSION_REVISION@"
```

### Exposed ports

The HTTP server port docsify listens on.

```Dockerile
EXPOSE @SERVER_PORT@ # default: 3000
```

### Working directory

The working directory of the container.

```Dockerile
workdir @PREFIX@
```

### Entry point

The entry point of the image can be changed if configured with `--ssr`
enabling SSR mode (see below).

#### Static server

Entry point to start a static server from generated documentation.

```Dockerile
entrypoint [ "@DOCSIFY_CLI_NAME@", "serve", "--port", "@SERVER_PORT@" ]
```

#### Server side renderer server (SSR)

Entry point to start a SSR server.

```Dockerile
entrypoint [ "@DOCSIFY_CLI_NAME@", "start", "--port", "@SERVER_PORT@" ]
```

### Environment variables

The following environment variables are defined in the container.

#### DEBUG

An environment variable that is intended for modules like
[debug][debug].

This can be configured with the `--debug=DEBUG` flag for the `./configure`
script.

```Dockerile
env DEBUG @DEBUG@ # default: DEBUG=docsify:*
```

#### PORT

The HTTP server port docsify listens on.

This can be configured with the `--port=PORT` flag for the `./configure`
script.

```Dockerile
env PORT @SERVER_PORT@ # default: PORT=3000
```

#### DOCSIFY_VERSION

The version of [docsify-cli][docsify-cli] to use.

This can be configured with the `--docsify-version=VERSION` flag for the
`./configure` script.

```Dockerile
env DOCSIFY_VERSION @DOCSIFY_VERSION@ # default: DOCSIFY_VERSION=latest
```

#### NODE_VERSION

The version of [node](https://nodejs.org/en/download/releases/) to use.

This can be configured with the `--node-version=VERSION` flag for the
`./configure` script.

```Dockerile
env NODE_VERSION @NODE_VERSION@ # default: NODE_VERSION=latest
```

## License

MIT


[docsify-cli]: https://www.npmjs.com/package/docsify-cli
[docsify]: https://docsify.js.org
[debug]: https://www.npmjs.com/package/debug

# t-rex docker image

[![GitHub license](https://img.shields.io/github/license/PDOK/trex-docker)](https://github.com/PDOK/trex-docker/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/PDOK/trex-docker.svg)](https://github.com/PDOK/trex-docker/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/pdok/trex-server.svg)](https://hub.docker.com/r/pdok/trex-server)

Docker image containing [t-rex tileserver](https://t-rex.tileserver.ch/) in a multiprocess setup behind a [lighttpd reverse proxy](https://github.com/PDOK/lighttpd-docker). 
Since it's a multiprocess setup we use [supervisor](http://supervisord.org/) for process management. The multiprocess setup
is required for performance reasons due to [this issue in t-rex](https://github.com/t-rex-tileserver/t-rex/issues/286#issuecomment-1598818987).

## Build

```
docker build -t pdok/trex-server .
```

## Configure

The Docker images requires the following environment variables:

- `TREX_TMS1` name of the tile matrix set to serve, should match the `tileset.name` configured in the trex TOML config.
- `TREX_CONFIG1` filename of the trex TOML config file available in the volume mount (see example below).
- `TREX_COUNT1` number of trex instances/processes to start with the given trex config file.

Note that you can repeat these environment variables by incrementing the trailing digits (e.g `TREX_CONFIG1`, 
`TREX_CONFIG2`, `TREX_CONFIG3`, etc). This allows one to serve multiple tilesets from a single Docker container. 
This is especially useful if you want to serve multiple geospatial projections of the same dataset, for example 
in WebMercator and ETRS89:

```
docker run \
  -e TREX_TMS1=ETRS89 \
  -e TREX_CONFIG1=my_etrs_config.toml \
  -e TREX_COUNT1=2 \
  -e TREX_TMS2=WebMercator \
  -e TREX_CONFIG2=my_webmercator_config.toml \
  -e TREX_COUNT2=4 \
  <more config options>
  -it pdok/trex-server:<version>
```

This will spin up 2 trex processes serving the ETRS89 tileset and 4 trex processes serving the 'WebMercator' tileset.
Supervisor will make sure all processes keep running, and lighttpd will load balance requests among these processes.

## Run

Run the example in the `examples` dir as:

```
cd examples/
docker run --rm -p 80:80 -v $PWD:/var/data/in:ro -e TREX_TMS1=bgt TREX_CONFIG1=bgt.toml TREX_COUNT1=5 -it pdok/trex-server:<version>
```

Now call http://localhost/bgt/2/1/1.pbf

<sub>Note: the `bgt.gpkg` GeoPackage serves just as an example, it's a heavily slimmed down 
and out-of-date version of the actual [BGT](https://www.pdok.nl/introductie/-/article/basisregistratie-grootschalige-topografie-bgt-).</sub>

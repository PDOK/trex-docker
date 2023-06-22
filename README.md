# t-rex docker image

Docker image containing [t-rex tileserver](https://t-rex.tileserver.ch/) in a multiprocess setup behind a [lighttpd reverse proxy](https://github.com/PDOK/lighttpd-docker). 
Since it's a multiprocess setup we use [supervisor](http://supervisord.org/) for process management. The multiprocess setup
is required for performance reasons due to [this issue in t-rex](https://github.com/t-rex-tileserver/t-rex/issues/286#issuecomment-1598818987).

# Build

```
docker build -t pdok/lighttpd-trex .
```

# Run 

Run the example as:

```
cd examples/
docker run --rm -p 80:80 -v $PWD:/var/data/in:ro -e TREX_INSTANCES=5 -e GPKG_PATH=/var/data/in/bgt.gpkg -it pdok/lighttpd-trex
```

At startup time you can specify the number of t-rex instances you want to run. Supervisor will make sure the processes keep running,
and lighttpd will load balance requests among these instances.

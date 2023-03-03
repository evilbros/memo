
## start your server for the first time

* ./run.sh
* that's it! it's done. just follow the instructions

## daily routines

* enable/disable servers in LIST file. use '#' to disable the servers
* use ./run.sh to run servers according to LIST file
* use ./stop.sh to stop some servers
* use ./restart.sh to restart some servers
* use ./sync.sh to change the version of specific server

## you can still use docker-compose for customizations
e.g:
```
docker-compose up -d
docker-compose down
docker-compose restart [service...]
```


# stationeers-server

Run Stationeers dedicated server in a container. Optionally includes helm chart for running in Kubernetes.

**Disclaimer:** This is not an official image. No support, implied or otherwise is offered to any end user by the author or anyone else. Feel free to do what you please with the contents of this repo.

## Usage

The processes within the container do **NOT** run as root. Everything runs as the user steam (gid:10000/uid:10000 by default). If you exec into the container, you will drop into `/home/steam` as the steam user. Stationeers will be installed to `/home/steam/stationeers`. Any persistent volumes should be mounted to `/home/steam/stationeers` and be owned by 10000:10000. If you need to run as a different GID/UID you can build your own image and set the build arguments for CONTAINER_GID and CONTAINER_UID to specify to new values.

Once your server is running, to configure it further you need to add it to your server manager in game.

### Requirements

- 16 or more Gigabytes of RAM. The server will load with less, but will run out of RAM quickly, potentially leading to instability or crashes.
- 6-8 CPU cores. The server will run with less, but it is strongly recommended to give it at least 6 cores due to the load caused by atmospheric calculations.

### Ports

Server to client is game port UDP, but the server manager also needs TCP. So which ever port you use for Game Port needs both TCP and UDP.

| Port | Protocol | Default |
| ---- | -------- | ------- |
| Game Port | UDP & TCP | 27015 |
| Update Port | TCP | 27016 |

### Environment Variables

| Name | Description | Default | Required |
| ---- | ----------- | ------- | -------- |
| GAME_PORT | Port for server connections. | 27015 | False |
| UPDATE_PORT | Port for query of server. | 27016 | False |
| SERVER_NAME | Name of server | "Containerized Stationeers" | False |
| SERVER_PASSWORD | Password to join | None | False |
| SERVER_AUTH_SECRET | Admin paspsword | None | False |
| SERVER_MAX_PLAYERS | Max players for server | 5 (1-20) | False |
| AUTO_SAVE | Enable or disable autosave | True | False |
| SAVE_INTERVAL | Time in seconds between autosaves | 300 | False |
| AUTO_PAUSE_SERVER | Should the server pause if no players are connected | True | False |
| WORLD_NAME | World ID for the world to create | Lunar | False |
| DIFFICULTY | Difficulty of world | Normal | False |
| START_CONDITION | Equipment you start with | DefaultStart | False |
| LOCATION_ID | Location ID of where you start | LunarSpawnCraterVesper | False |

### World Types (October 2025)

| World Name | WorldID | Difficulty IDs | StartCondition IDs | StartLocation IDs |
|-----------|--------|----------------|--------------------|------------------|
| Lunar (The Moon) | `Lunar` | Creative, Easy, Normal, Stationeer | DefaultStart, DefaultStartCommunity, Brutal, BrutalCommunity | LunarSpawnCraterVesper, LunarSpawnMontesUmbrarum, LunarSpawnCraterNox, LunarSpawnMonsArcanus, LunarSpawnRoundRobin |
| Mars | `Mars2` | Creative, Easy, Normal, Stationeer | DefaultStart, DefaultStartCommunity, Brutal, BrutalCommunity | MarsSpawnCanyonOverlook, MarsSpawnButchersFlat, MarsSpawnFindersCanyon, MarsSpawnHellasCrags, MarsSpawnDonutFlats, MarsSpawnRoundRobin |
| Europa | `Europa3` | Creative, Easy, Normal, Stationeer | EuropaDefault, EuropaDefaultCommunity, EuropaBrutal, EuropaBrutalCommunity | EuropaSpawnIcyBasin, EuropaSpawnGlacialChannel, EuropaSpawnBalgatanPass, EuropaSpawnFrigidHighlands, EuropaSpawnTyreValley, EuropaSpawnRoundRobin |
| Mimas | `MimasHerschel` | Creative, Easy, Normal, Stationeer | MimasDefault, MimasDefaultCommunity, MimasBrutal, MimasBrutalCommunity | MimasSpawnCentralMesa, MimasSpawnHarrietCrater, MimasSpawnCraterField, MimasSpawnDustBowl, MimasSpawnRoundRobin |
| Vulcan | `Vulcan` | Creative, Easy, Normal, Stationeer | VulcanDefault, VulcanDefaultCommunity, VulcanBrutal, VulcanBrutalCommunity | VulcanSpawnVestaValley, VulcanSpawnEtnasFury, VulcanSpawnIxionsDemise, VulcanSpawnTitusReach, VulcanSpawnRoundRobin |
| Venus | `Venus` | Creative, Easy, Normal, Stationeer | VenusDefault, VenusDefaultCommunity, VulcanBrutal, VulcanBrutalCommunity | VenusSpawnGaiaValley, VenusSpawnDaisyValley, VenusSpawnFaithValley, VenusSpawnDuskValley, VenusSpawnRoundRobin |

https://stationeers-wiki.com/Dedicated_Server_Guide

### Docker

To run the container in Docker, run the following command:

```bash
docker volume create stationeers-persistent-data
docker run \
  --detach \
  --name stationeers-server \
  --mount type=volume,source=stationeers-persistent-data,target=/home/steam/stationeers \
  --publish 27015:27015/udp \
  --publish 27015:27015/tcp \
  --publish 27016:27016/tcp \
  --env=GAME_PORT=27015 \
  --env=UPDATE_PORT=27016 \
  sknnr/stationeers-server:latest
```

### Docker Compose

To use Docker Compose, either clone this repo or copy the `compose.yaml` file out of the `container` directory to your local machine. Edit the compose file to change the environment variables to the values you desire and then save the changes. Once you have made your changes, from the same directory that contains the compose and the env files, simply run:

```bash
docker-compose up -d
```

To bring the container down:

```bash
docker-compose down
```

compose.yaml file:

```yaml
services:
  stationeers:
    image: sknnr/stationeers-server:latest
    ports:
      - "27015:27015/udp"
      - "27015:27015/tcp"
      - "27016:27016/tcp"
    environment:
      GAME_PORT: "27015"
      UPDATE_PORT: "27016"
    volumes:
      - stationeers-persistent-data:/home/steam/stationeers
    stop_grace_period: 90s

volumes:
  stationeers-persistent-data:
```

### Podman

To run the container in Podman, run the following command:

```bash
podman volume create stationeers-persistent-data
podman run \
  --detach \
  --name stationeers-server \
  --mount type=volume,source=stationeers-persistent-data,target=/home/steam/stationeers \
  --publish 27015:27015/udp \
  --publish 27015:27015/tcp \
  --publish 27016:27016/tcp \
  --env=GAME_PORT=27015 \
  --env=UPDATE_PORT=27016 \
  docker.io/sknnr/stationeers-server:latest
```

### Kubernetes

I've built a Helm chart and have included it in the `helm` directory within this repo. Modify the `values.yaml` file to your liking and install the chart into your cluster. Be sure to create and specify a namespace as I did not include a template for provisioning a namespace.

## Troubleshooting

### Connectivity

If you are having issues connecting to the server once the container is deployed, I promise the issue is not with this image. You need to make sure that the ports are open on your router as well as the container host where this container image is running. You will also have to port-forward the game-port and query-port from your router to the private IP address of the container host where this image is running. After this has been done correctly and you are still experiencing issues, your internet service provider (ISP) may be blocking the ports and you should contact them to troubleshoot.

### Storage

I recommend having Docker or Podman manage the volume that gets mounted into the container. However, if you absolutely must bind mount a directory into the container you need to make sure that on your container host the directory you are bind mounting is owned by 10000:10000 by default (`chown -R 10000:10000 /path/to/directory`). If the ownership of the directory is not correct the container will not start as the server will be unable to persist the savegame.

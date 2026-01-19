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

| Port | Protocol | Default |
| ---- | -------- | ------- |
| Game Port | UDP | 27016 |
| Update Port | UDP | 27015 |

### Environment Variables

| Name | Description | Default | Required |
| ---- | ----------- | ------- | -------- |
| GAME_PORT | Port for server connections. | 27016 | False |
| UPDATE_PORT | Port for query of server. | 27015 | False |
| UPNP_ENABLED | Enable or disable UPNP support | false | False |
| SERVER_NAME | Name of server | "Containerized Stationeers" | False |
| SERVER_VISIBLE | Does server show up on in-game list | true | False |
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

further documentation: https://stationeers-wiki.com/Dedicated_Server_Guide

### Docker

To run the container in Docker, run the following command:

```bash
docker volume create stationeers-persistent-data
docker run \
  --detach \
  --name stationeers-server \
  --mount type=volume,source=stationeers-persistent-data,target=/home/steam/stationeers \
  --publish 27015:27015/udp \
  --publish 27016:27016/udp \
  --env=GAME_PORT=27016 \
  --env=UPDATE_PORT=27015 \
  sknnr/stationeers-server:latest
```

### Docker Compose

To use Docker Compose, create a compose.yaml file similar to the below:

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
      - "27016:27016/udp"
    environment:
      GAME_PORT: "27016"
      UPDATE_PORT: "27015"
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
  --publish 27016:27016/udp \
  --env=GAME_PORT=27016 \
  --env=UPDATE_PORT=27015 \
  docker.io/sknnr/stationeers-server:latest
```

### Kubernetes

I've built a Helm chart and have included it in the `helm` directory within this repo. Modify the `values.yaml` file to your liking and install the chart into your cluster. Be sure to create and specify a namespace as I did not include a template for provisioning a namespace.

The chart in this repo is also hosted in my helm-charts repository [here](https://jsknnr.github.io/helm-charts)

To install this chart from my helm-charts repository:

```bash
helm repo add jsknnr https://jsknnr.github.io/helm-charts
helm repo update
```

To install the chart from the repo:

```bash
helm install stationeers jsknnr/stationeers-server --values myvalues.yaml
# Where myvalues.yaml is your copy of the Values.yaml file with the settings that you want
```

## FAQ

**Q:** Can you change and or make the user and group IDs configurable? \
**A:** Short answer, no I will not. Longer answer, for security reasons it is best that containers have UID/GIDs at or above 10000 to avoid collision with container host UID/GIDs. To make this configurable, the container would have to start as root and then later change to the desired user... this is also a security concern. If you *really* need to change this, just take my repo and build your own image with IDs you prefer. Just change the build args in the Containerfile.

**Q:** Can you release an ARM64 based image? \
**A:** No. Until the devs release ARM compiled server binaries I won't do this (otherwise requires some sort of emulation, performance cost, what's the point).

**Q:** I can't connect to my server, what is wrong? \
**A:** This is no fault of my image. You need to double check settings on your router and on your container host. Check and then double check firewall rules, dnat/port forwarding rules, etc. If you are still having issues, it is possible that your internet provider (ISP) is using CGNAT (carrier-grade NAT) which can make it really hard if not impossible to host internet facing services from your local network. Contact them (your ISP) and discuss.

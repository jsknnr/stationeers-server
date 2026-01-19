#!/usr/bin/env bash
set -Eeuo pipefail

timestamp() { date +"%Y-%m-%d %H:%M:%S,%3N"; }

stationeers_pid=""

shutdown() {
  echo ""
  echo "$(timestamp) INFO: Received SIGTERM, shutting down gracefully"

  if [[ -n "${stationeers_pid}" ]] && kill -0 "${stationeers_pid}" 2>/dev/null; then
    kill -INT "${stationeers_pid}" || true
    wait "${stationeers_pid}" || true
  else
    echo "$(timestamp) WARN: Server process not running (pid not set or already exited)"
  fi
}

trap shutdown TERM INT

IMAGE_VERSION="$(cat /home/steam/image_version)"
MAINTAINER="$(cat /home/steam/image_maintainer)"
EXPECTED_FS_PERMS="$(cat /home/steam/expected_filesystem_permissions)"

echo "$(timestamp) INFO: Launching Stationeers Dedicated Server image ${IMAGE_VERSION} by ${MAINTAINER}"

echo "$(timestamp) INFO: Validating data directory filesystem permissions"
mkdir -p "${STATIONEERS_PATH}"
if ! touch "${STATIONEERS_PATH}/test"; then
  echo ""
  echo "$(timestamp) ERROR: The ownership of ${STATIONEERS_PATH} is not correct and the server will not be able to save..."
  echo "the directory that you are mounting into the container needs to be owned by ${EXPECTED_FS_PERMS}"
  echo "from your container host attempt the following command 'sudo chown -R ${EXPECTED_FS_PERMS} /your/stationeers/data/directory'"
  echo ""
  exit 1
fi
rm -f "${STATIONEERS_PATH}/test"

echo "$(timestamp) INFO: Updating Stationeers Dedicated Server"
echo ""
if ! "${STEAMCMD_PATH}/steamcmd.sh" \
    +force_install_dir "${STATIONEERS_PATH}" \
    +login anonymous \
    +app_update "${STEAM_APP_ID}" validate \
    +quit; then
  echo "$(timestamp) ERROR: steamcmd was unable to successfully initialize and update Stationeers"
  exit 1
fi
echo ""
echo "$(timestamp) INFO: steamcmd update of Stationeers successful"

echo ""
echo "$(timestamp) INFO: Launching Stationeers!"
echo "--------------------------------------------------------------------------------"
echo "Container Image Version: ${IMAGE_VERSION}"
echo "Game Port: ${GAME_PORT}"
echo "Update Port: ${UPDATE_PORT}"
echo "Server Name: ${SERVER_NAME}"
echo "Max Players: ${SERVER_MAX_PLAYERS}"
echo "World: ${WORLD_NAME}"
echo "Start Location: ${LOCATION_ID}"
echo "Difficulty: ${DIFFICULTY}"
echo "Start Condition: ${START_CONDITION}"
echo "Autosave: ${AUTO_SAVE}"
echo "Autosave Interval: ${SAVE_INTERVAL}"
echo "Autopause: ${AUTO_PAUSE_SERVER}"
echo "--------------------------------------------------------------------------------"
echo ""

# Initialize logging
LOG_FILE="${STATIONEERS_PATH}/server.log"
rm -f "${LOG_FILE}"
touch "${LOG_FILE}"
# Write to stdout
ln -s /proc/1/fd/1 "${LOG_FILE}"

# Build command as an array (safe quoting)
cmd=(
  "${STATIONEERS_PATH}/rocketstation_DedicatedServer.x86_64"
  -file start ContainerStation "${WORLD_NAME}" "${DIFFICULTY}" "${START_CONDITION}" "${LOCATION_ID}"
  -logFile "${STATIONEERS_PATH}/server.log"
  -settings
  StartLocalHost true
  ServerVisible true
  GamePort "${GAME_PORT}"
  UpdatePort "${UPDATE_PORT}"
  ServerName "${SERVER_NAME}"
  ServerMaxPlayers "${SERVER_MAX_PLAYERS}"
  AutoSave "${AUTO_SAVE}"
  SaveInterval "${SAVE_INTERVAL}"
  AutoPauseServer "${AUTO_PAUSE_SERVER}"
)

if [[ -n "${SERVER_PASSWORD:-}" ]]; then
  cmd+=(ServerPassword "${SERVER_PASSWORD}")
fi

# Decide on one env var name and stick to it (example uses SERVER_AUTH_SECRET)
if [[ -n "${SERVER_AUTH_SECRET:-}" ]]; then
  cmd+=(ServerAuthSecret "${SERVER_AUTH_SECRET}")
fi

# Launch
"${cmd[@]}" &
stationeers_pid="$!"

echo "$(timestamp) INFO: Stationeers started with pid ${stationeers_pid}"

# Hold until it exits or we get a signal (trap calls wait too)
wait "${stationeers_pid}" || true

echo "$(timestamp) INFO: Shutdown complete."
exit 0

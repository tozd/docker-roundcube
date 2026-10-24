#!/bin/sh

set -e

cleanup() {
  set +e

  echo "Logs"
  docker logs test

  echo "Stopping Docker image"
  docker stop test
  docker rm -f test
}

echo "Running Docker image"
docker run -d --name test -e LOG_TO_STDOUT=1 -p 80:80 "${CI_REGISTRY_IMAGE}:${TAG}"
trap cleanup EXIT

echo "Sleeping"
sleep 10

echo "Testing"
docker exec test test -s /var/lib/roundcube/db/roundcube.db
wget -T 30 -q -O - http://docker/roundcube/ | grep -q '<title>Roundcube Webmail'
wget -T 30 -q -O - http://docker/roundcube/static.php/skins/elastic/styles/styles.min.css | grep -q 'font-family'
echo "Success"

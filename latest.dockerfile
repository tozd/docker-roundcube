FROM registry.gitlab.com/tozd/docker/php:8.3

ARG ROUNDCUBE_VERSION=1.7.5
ARG ROUNDCUBE_SHA256=93a66c94e3efff7db93187c1c9d7f35546647a3e1e7b9327cc87911564edf9d1

VOLUME /etc/roundcube/conf.d
VOLUME /var/lib/roundcube
VOLUME /var/log/roundcube

# We install the upstream release because distribution packages lag behind Roundcube security releases.
# ca-certificates is kept installed because Roundcube verifies TLS certificates of IMAP and SMTP servers.
RUN apt-get update -q -q && \
  apt-get install wget ca-certificates \
  php8.3-cli php8.3-common php8.3-curl php8.3-intl php8.3-mbstring php8.3-mysql php8.3-pgsql \
  php8.3-sqlite3 php8.3-xml php8.3-zip --yes --force-yes && \
  wget -q -O /tmp/roundcube.tar.gz "https://github.com/roundcube/roundcubemail/releases/download/${ROUNDCUBE_VERSION}/roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz" && \
  echo "${ROUNDCUBE_SHA256}  /tmp/roundcube.tar.gz" | sha256sum -c - && \
  mkdir -p /usr/share/roundcube && \
  tar -xzf /tmp/roundcube.tar.gz -C /usr/share/roundcube --strip-components=1 --no-same-owner && \
  rm -rf /usr/share/roundcube/installer /usr/share/roundcube/public_html/installer.php /usr/share/roundcube/logs && \
  ln -s /var/log/roundcube /usr/share/roundcube/logs && \
  chown -Rh fcgi-php:fcgi-php /usr/share/roundcube/temp && \
  ln -s /etc/roundcube/config.inc.php /usr/share/roundcube/config/config.inc.php && \
  mkdir -p /var/www && \
  ln -s /usr/share/roundcube/public_html /var/www/roundcube && \
  for file in /etc/php/8.3/mods-available/*.ini; do phpenmod $(basename -s .ini "$file"); done && \
  apt-get purge --yes --force-yes --auto-remove wget && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./etc /etc
COPY ./roundcube /usr/local/lib/roundcube

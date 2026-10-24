# tozd/roundcube

<https://gitlab.com/tozd/docker/roundcube>

Available as:

- [`tozd/roundcube`](https://hub.docker.com/r/tozd/roundcube)
- [`registry.gitlab.com/tozd/docker/roundcube`](https://gitlab.com/tozd/docker/roundcube/container_registry)

## Image inheritance

[`tozd/base`](https://gitlab.com/tozd/docker/base) ← [`tozd/dinit`](https://gitlab.com/tozd/docker/dinit) ← [`tozd/nginx`](https://gitlab.com/tozd/docker/nginx) ← [`tozd/nginx-mailer`](https://gitlab.com/tozd/docker/nginx-mailer) ← [`tozd/nginx-cron`](https://gitlab.com/tozd/docker/nginx-cron) ← [`tozd/php`](https://gitlab.com/tozd/docker/php) ← `tozd/roundcube`

## Tags

- `latest`: Roundcube v1.7.5

## Volumes

- `/etc/roundcube/conf.d`: Additional configuration files.
- `/var/lib/roundcube`: SQLite database, when the default database configuration is used, and generated `des_key`.
- `/var/log/roundcube`: Log files when `LOG_TO_STDOUT` is not set to `1`.

## Variables

- `ROUNDCUBE_<OPTION>`: Roundcube itself reads any of its configuration options from environment variables
  prefixed with `ROUNDCUBE_`, e.g., `ROUNDCUBE_DB_DSNW`, `ROUNDCUBE_IMAP_HOST`, `ROUNDCUBE_SMTP_HOST`,
  `ROUNDCUBE_DES_KEY`. Values of options which are arrays (e.g., `ROUNDCUBE_PLUGINS`) have to be JSON.
  Environment variables have precedence over all configuration files.

## Description

Image provides [Roundcube](https://roundcube.net/) webmail.
When the container runs Roundcube is available at `/roundcube/` URL.

By default the image uses a SQLite database stored in `/var/lib/roundcube` volume and enables `archive` and
`zipdownload` plugins. The image does not include a mail server, so you have to configure the IMAP server
(`imap_host`) and the SMTP server (`smtp_host`) Roundcube connects to.
Roundcube sends e-mails through the SMTP server using credentials of the logged in user.
Configure the image using environment variables or by mounting a volume or extending the image to add `.php`
configuration files to `/etc/roundcube/conf.d`, for example:

```php
<?php
$config['db_dsnw'] = 'mysql://roundcube:password@mysql/roundcube';
$config['imap_host'] = 'ssl://mail.example.com:993';
$config['smtp_host'] = 'ssl://mail.example.com:465';
$config['des_key'] = 'exactly 24 random chars';
```

Configuration files have to be readable by the `fcgi-php` user. Available options are documented in
[`defaults.inc.php`](https://github.com/roundcube/roundcubemail/blob/master/config/defaults.inc.php).

On every container startup the image creates the database schema if the database is empty, or applies
any pending upgrades of the database schema. A database from Roundcube 0.8 or older does not record its schema
version, so the container refuses to start until you upgrade the database once, with the version
of Roundcube which used the database, for example:

```sh
docker run --rm --entrypoint /usr/share/roundcube/bin/updatedb.sh \
 --env ROUNDCUBE_DB_DSNW=mysql://roundcube:password@mysql/roundcube \
 tozd/roundcube --package=roundcube --version=0.7.2 --dir=/usr/share/roundcube/SQL
```

The database user needs privileges to create, alter and drop tables for schema upgrades.

If you do not configure `des_key`, the image generates a random key on the first startup and stores it
in `/var/lib/roundcube` volume. Persist the volume so that users stay logged in when the container is recreated.

Cron jobs regularly remove expired sessions and cache entries. To get e-mails with any errors from them,
configure `MAILTO`, `ADMINADDR`, and `REMOTES` environment variables as described in
[`tozd/nginx-mailer`](https://gitlab.com/tozd/docker/nginx-mailer) and
[`tozd/nginx-cron`](https://gitlab.com/tozd/docker/nginx-cron) Docker images.

When `LOG_TO_STDOUT` is set to `1`, Roundcube logs to stdout, too.

## GitHub mirror

There is also a [read-only GitHub mirror available](https://github.com/tozd/docker-roundcube),
if you need to fork the project there.

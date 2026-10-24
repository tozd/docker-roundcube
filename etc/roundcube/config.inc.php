<?php

// Configuration of the Docker image. Options set here can be overridden by PHP files in /etc/roundcube/conf.d/,
// which are included in alphabetical order, and by ROUNDCUBE_<OPTION> environment variables (arrays and objects
// as JSON), which Roundcube itself applies over all configuration files.

$config = [];

$config['db_dsnw'] = 'sqlite:////var/lib/roundcube/db/roundcube.db?mode=0640';

$config['plugins'] = ['archive', 'zipdownload'];

$config['log_dir'] = '/var/log/roundcube/';
$config['log_driver'] = getenv('LOG_TO_STDOUT', true) === '1' ? 'stdout' : 'file';

// Key generated on the first container startup and stored in the volume, used unless the key is configured otherwise.
if (is_readable('/var/lib/roundcube/des_key')) {
    $config['des_key'] = trim(file_get_contents('/var/lib/roundcube/des_key'));
}

foreach (glob('/etc/roundcube/conf.d/*.php') ?: [] as $file) {
    include $file;
}

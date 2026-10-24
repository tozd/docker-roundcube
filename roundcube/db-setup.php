<?php

// Prepares the Roundcube database schema: it creates the schema in an empty database and applies pending upgrades
// to a database which records its schema version. A database with tables but without a recorded schema version
// (created by Roundcube 0.8 or older) is left unmodified and the script exits with an error, because Roundcube
// cannot determine its version and it has to be upgraded once with updatedb.sh and an explicit --version.

define('INSTALL_PATH', '/usr/share/roundcube/');

require_once INSTALL_PATH . 'program/include/clisetup.php';

$dir = INSTALL_PATH . 'SQL';
$db = rcmail_utils::db();
$tables = (array) $db->list_tables();

if (empty($tables)) {
    rcmail_utils::db_init($dir);
} elseif (in_array($db->table_name('system'), $tables)) {
    rcmail_utils::db_update($dir, 'roundcube', null, ['errors' => true]);
} else {
    fwrite(\STDERR, 'Database has tables but no recorded Roundcube schema version. Upgrade it once with: '
        . INSTALL_PATH . 'bin/updatedb.sh --package=roundcube --dir=' . $dir . " --version=<old Roundcube version>\n");
    exit(1);
}

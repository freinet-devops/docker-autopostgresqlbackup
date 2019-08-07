# Docker AutoPostgreSQLBackup

> AutoPostgreSQLBackup in a docker container

[![](https://img.shields.io/docker/cloud/build/freinet/autopostgresqlbackup.svg)](https://hub.docker.com/r/freinet/autopostgresqlbackup/builds/)

This docker container uses the autopostgresqlbackup package from ubuntu repos with a minimal modification to make it able to use variables from environment variables, making the configuration through docker model possible. The original source code with modifications is in this repo, also the license GPLv2 has been respected and this repo is under GPLv2.

This container follow the [dockerfile good practices](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/).

## Installation

```bash
docker pull freinet/autopostgresqlbackup
```

## Configuration

### Volumes

| MOUNT    | DESCRIPTION                                                                   |
| :------- | :---------------------------------------------------------------------------- |
| /backups | a directory that contains the crontab files (one or many) with crontab format |


## Environment variables

| NAME            | VALUES                                  | DEFAULT   | DESCRIPTION                                                                                                                                                                                                                                                                |
| :-------------- | :-------------------------------------- | :-------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CRON_LOG_LEVEL  | 1 to 8                                  | 8         | Level of verbosite. Most verbose is 0, less verbose is 8                                                                                                                                                                                                                   |
| CRON_SCHEDULE   | a valid cron specification              | empty     | By default the app uses cron.daily schedule, but you can't crontrol the hour, so, is a ramdon momment during the day. If you want to schedule a fix time to run the backups define this environment variable with a valid cron_schedule.                                   |
| DBHOST          | hostname                                | localhost | name of the db host to connect.                                                                                                                                                                                                                                            |
| USERNAME        | string                                  | postgres  | user used to connects to the db.                                                                                                                                                                                                                                           |
| PASSWORD        | string                                  | empty     | password for the user to connects to the db. Remember doing this you have the password in an environment variable. If you prefer to use Docker Secrets (I recommend this) don't define this env var or leave it blank, and go to the PASSWORD_SECRET environment variable. |
| PASSWORD_SECRET | docker secret name                      | empty     | contains the name of the secret file where to read the password using docker secrets. Note: if this variable is defined, PASSWORD value will be ignored.                                                                                                                   |
| DBNAMES         | list of dbnames separated by whitespace | all       | List of DBNAMES for Daily/Weekly Backup e.g. "DB1 DB2 DB3".                                                                                                                                                                                                                |  |
| DBEXCLUDE       | list of dbnames separated by whitespace | empty     | List of DBNAMES to EXLUCDE if DBNAMES are set to all                                                                                                                                                                                                                       |
| CREATE_DATABASE | yes or no                               | yes       | Include CREATE DATABASE in backup?                                                                                                                                                                                                                                         |
| SEPDIR          | yes or no                               | yes       | Separate backup directory and file for each DB?                                                                                                                                                                                                                            |
| DOWEEKLY        | 1 to 7                                  | 6         | Which day do you want weekly backups? (1 to 7 where 1 is Monday)                                                                                                                                                                                                           |
| COMP            | gzip or bzip2                           | gzip      | Choose Compression type.                                                                                                                                                                                                                                                   |
| LATEST          | yes or no                               | no        | Additionally keep a copy of the most recent backup in a seperate directory.                                                                                                                                                                                                |
| OPT             | valid commandline arguments             | empty     | OPT string for use with pg_dump ( see man pg_dump )                                                                                                                                                                                                                        |
| EXT             | a file extension starts with .          | .sql      | Backup files extension                                                                                                                                                                                                                                                     |
| TZ              | timezone                                | UTC       | Set timezone                                                                                                                                                                                                                                                               |

Optional specific environment variables:

| NAME                                                                                                                     | VALUES | DEFAULT | DESCRIPTION                                                                                                                     |
| :----------------------------------------------------------------------------------------------------------------------- | :----- | :------ | :------------------------------------------------------------------------------------------------------------------------------ |
| GLOBALS_OBJECTS: pseudo database name used to dump global objects (users, roles, tablespaces). default postgres_globals. |
| COMMCOMP                                                                                                                 | 0 to 9 | 0       | Compress communications between backup server and PostgreSQL server? set compression level from 0 to 9 (0 means no compression) |

You need to configure also the script using a configuration file, it's self described so take a look
and read the options [autopostgresqlbackup](autopostgresqlbackup.conf)

## Usage

```bash
docker run --name autopostgresqlbackup -v /my/backup/dir:/backups -e DBHOST=mypgbackup -e PASSWORD=mycomplexpassword -v /etc/localtime:/etc/localtime:ro ppadial/autopostgresqlbackup:latest
```

### With docker-compose

```yml
version: '3.5'

services:
  autopgbackup:
    image: ppadial/autopostgresqlbackup:latest
    container_name: autopgbackup
    environment:
      - DBHOST = mypgserver
      - PASSWORD_SECRET=posgre-pass
    volumes:
     - /my/backups/dir:/backups
     - /etc/localtime:/etc/localtime:ro
    secrets:
     - posgre-pass

  secrets:
    posgre-pass:
      file: /path/to/file/that/contains/password
```

## Origin

Paulino Padial – [@ppadial](https://github.com/ppadial) – github.com/ppadial

Distributed under the GPLv2 license. See [LICENSE](LICENSE) for more information.

[https://github.com/ppadial/docker-autopostgresqlbackup](https://github.com/ppadial/)

# Comet Enterprise Backup Server

A docker container with the Comet Enterprise Backup server. (https://cometbackup.com/)

You will need the CometD server tarball from their website to build your own docker image.  Place the tarball in the `cometbackup` directory and update the `COMETD_TARBALL` ARG in the Dockerfile.

To run this container, you will need a valid Comet Enterprise Server License.  (These are currently available for free on their website.)

Currently this container is very minimalistic.  This may or may not change in the future.

## Variables:
Enviornment Variable    | Purpose
----------------------- | ----
COMET_LICENSE           | REQUIRED on first run!  Your Comet Enterprise Server License key
COMET_LICENSE_FORCE     | Force the Comet license to be re-added to the config file
COMET_ARGUMENTS         | Additional arguments to pass to the Comet server
COMET_ADMIN_USER        | Primary admin username (Defaults to "admin" if never set)
COMET_ADMIN_PASS        | Primary admin password (Defaults to "admin" if never set)

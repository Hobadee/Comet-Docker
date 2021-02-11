#!/bin/sh

COMET_DIR=/opt/cometd
COMET_BIN=cometd
COMET_CFG=cometd.cfg

# Docker Variables
#COMET_LICENSE			- Comet license code
#COMET_LICENSE_FORCE	- Force the Comet license to be re-added to the config file
#COMET_ARGUMENTS		- Additional arguments to pass to the Comet server

cd $COMET_DIR

# If no config, create it
if [[ ! -f $COMET_DIR/$COMET_CFG ]]; then
	echo "Creating default Comet config..."
	$COMET_DIR/$COMET_BIN -ValidateConfigOnly
fi

# Check if we have a license set yet and add if not
if [[ $(jq '.License.SerialNumber' $COMET_DIR/$COMET_CFG) == '""' || -n "$COMET_LICENSE_FORCE" ]]; then
	if [[ -z "$COMET_LICENSE" ]]; then
		# No license key set and none provided.  Exit.
		echo "No Comet license key provided."
		exit 1
	fi
	echo "Writing Comet license key"
	cp $COMET_DIR/$COMET_CFG $COMET_DIR/$COMET_CFG.tmp
	jq --arg LICENSE "$COMET_LICENSE" '.License.SerialNumber = $LICENSE' $COMET_DIR/$COMET_CFG.tmp > $COMET_DIR/$COMET_CFG
	rm $COMET_DIR/$COMET_CFG.tmp
fi

$COMET_DIR/$COMET_BIN $COMET_ARGUMENTS

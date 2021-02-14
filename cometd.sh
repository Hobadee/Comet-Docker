#!/bin/sh

COMET_DIR=/opt/cometd
COMET_BIN=cometd
COMET_CFG=cometd.cfg

# Docker Variables
#COMET_LICENSE			- Comet license code
#COMET_LICENSE_FORCE	- Force the Comet license to be re-added to the config file
#COMET_ARGUMENTS		- Additional arguments to pass to the Comet server
#COMET_ADMIN_USER		- Admin user #0 username
#COMET_ADMIN_PASS		- Admin user #0 password

cd $COMET_DIR

# If no config, create it
if [[ ! -f $COMET_DIR/$COMET_CFG ]]; then
	echo "Creating default Comet config..."
	$COMET_DIR/$COMET_BIN -ValidateConfigOnly
fi

# Create tempfiles for jq filters
JQTMP=$(mktemp)

# function to add jq filters to the JQTMP file.
jq_filter_add () {
	# If the file contains data, prepend a JQ pipe
	if [[ -s "$JQTMP" ]]; then
		echo "| $@" >> "$JQTMP"
	else
		echo "$@" >> "$JQTMP"
	fi
}

# Check if we have a license set yet and add if not
if [[ $(jq '.License.SerialNumber' $COMET_DIR/$COMET_CFG) == '""' || -n "$COMET_LICENSE_FORCE" ]]; then
	if [[ -z "$COMET_LICENSE" ]]; then
		# No license key set and none provided.  Exit.
		echo "No Comet license key provided."
		exit 1
	fi
	jq_filter_add ".License.SerialNumber = \"$COMET_LICENSE\""
fi


# Handle environment variables pertaining to the Admin user
if [[ -n "$COMET_ADMIN_USER" ]]; then
	jq_filter_add ".AdminUsers[0].Username = \"$COMET_ADMIN_USER\""
fi
if [[ -n "$COMET_ADMIN_PASS" ]]; then
	jq_filter_add ".AdminUsers[0].PasswordFormat = 0"
	jq_filter_add ".AdminUsers[0].Password = \"$COMET_ADMIN_PASS\""
fi


# Write new config and save it
if [[ -s $JQTMP ]]; then
	echo "Updating config"
	CFGTMP=$(mktemp)
	jq -f "$JQTMP" "$COMET_DIR/$COMET_CFG" > "$CFGTMP"
	if [[ $? != 0 ]]; then
		echo "Failed to update config file.  Exiting."
		exit 1
	fi
	mv "$CFGTMP" "$COMET_DIR/$COMET_CFG"
	rm -f $CFGTMP
fi

# Cleanup temp files
rm -f "$JQTMP"

"$COMET_DIR/$COMET_BIN" $COMET_ARGUMENTS

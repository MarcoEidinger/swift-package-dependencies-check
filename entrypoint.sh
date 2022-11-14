#!/usr/bin/env bash
isMutating=$1
failWhenOutdated=$2

echo "Changing current directory..."
cd $3

echo "### Current Package Dependencies (swift package show-dependencies)"
swift package show-dependencies
SPU_RESULT=""
if [ "$isMutating" = true ] || [ "$isMutating" = 'true' ]; then
	echo "### Check and Update Packages Dependencies if they are outdated (swift package update)"

	echo "#### run swift-release-notes to get details about changes"
	NOTES_EXTRACT="$(swift-release-notes . | grep -A 100 "changed.")"
	# Multiline outputs need special treatment
	NOTES=$(
		cat <<-EOF
			$NOTES_EXTRACT
		EOF
	)
    # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings
    echo "releaseNotes<<EOF" >> $GITHUB_OUTPUT
    echo "$NOTES" >> $GITHUB_OUTPUT
    echo "EOF" >> $GITHUB_OUTPUT

	echo "### Run swift package update"
	SPU_RESULT=$(swift package update 2>&1)
else
	echo "### Check Packages Dependencies if they are up-to-date (swift package update --dry-run)"
	SPU_RESULT=$(swift package update --dry-run 2>&1)
fi
echo "$SPU_RESULT"
if echo "$SPU_RESULT" | grep -q "0 dependencies have changed.\|Everything is already up-to-date"; then
    echo outdatedDependencies=false >> $GITHUB_OUTPUT
	exit 0
elif echo "$SPU_RESULT" | grep "error: package"; then
    echo outdatedDependencies=false >> $GITHUB_OUTPUT
	exit 1
else
    echo outdatedDependencies=true >> $GITHUB_OUTPUT
	if [ "$failWhenOutdated" = true ] || [ "$failWhenOutdated" = 'true' ]; then
		exit 1
	else
		exit 0
	fi
fi

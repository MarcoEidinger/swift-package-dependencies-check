#!/usr/bin/env bash
isMutating=$1
failWhenOutdated=$2
echo "### Current Package Dependencies (swift package show-dependencies)"
swift package show-dependencies
SPU_RESULT=""
if [ "$isMutating" = true ] || [ "$isMutating" = 'true' ]; then
	echo "### Check and Update Packages Dependencies if they are outdated (swift package update)"

	echo "#### run swift-release-notes to get details about changes"
	NOTES_EXTRACT="$(swift-release-notes . | grep -A 100 "changed.")"
	# Multiline outputs need special treatment
	# See https://github.community/t5/GitHub-Actions/set-output-Truncates-Multiline-Strings/m-p/38372#M3322
	NOTES=$(
		cat <<-EOF
			$NOTES_EXTRACT
		EOF
	)
	NOTES="${NOTES//'%'/'%25'}"
	NOTES="${NOTES//$'\n'/'%0A'}"
	NOTES="${NOTES//$'\r'/'%0D'}"
	echo "::set-output name=releaseNotes::$NOTES"

	echo "### Run swift package update"
	SPU_RESULT=$(swift package update)
else
	echo "### Check Packages Dependencies if they are up-to-date (swift package update --dry-run)"
	SPU_RESULT=$(swift package update --dry-run)
fi
echo "$SPU_RESULT"
if echo "$SPU_RESULT" | grep -q "0 dependencies have changed.\|Everything is already up-to-date"; then
	echo "::set-output name=outdatedDependencies::false"
	exit 0
else
	echo "::set-output name=outdatedDependencies::true"
	if [ "$failWhenOutdated" = true ] || [ "$failWhenOutdated" = 'true' ]; then
		exit 1
	else
		exit 0
	fi
fi

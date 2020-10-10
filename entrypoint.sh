#!/bin/sh -l
isMutating=$1
echo "### Current Package Dependencies (swift package show-dependencies)"
swift package show-dependencies
OUTPUT=""
if [ "$isMutating" = true ] || [ "$isMutating" = 'true' ]
then
    echo "### Check and Update Packages Dependencies if they are outdated (swift package update)"
    OUTPUT=$(swift package update)
else
	echo "### Check Packages Dependencies if they are up-to-date (swift package update --dry-run)"
	OUTPUT=$(swift package update --dry-run)
fi
echo "$OUTPUT"
if echo "$OUTPUT" | grep -q "0 dependencies have changed."; then
  exit 0
else
  exit 1
fi

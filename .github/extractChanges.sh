#!/bin/bash

#temp changelog
TMP_CHANGELOG="tmp_changelog_lines.md"
TMP_ADDED="tmp_added.md"
TMP_UPDATED="tmp_updated.md"
TMP_REMOVED="tmp_removed.md"

# reset the file - most likely not needed
rm -f changeLog.md
rm -f Tchangelog.htm
touch changeLog.md
touch $TMP_CHANGELOG
touch Tchangelog.htm

#find the last time we made a changelog
LASTUPDATE=$(git log -1000 | grep -B 4 "Version update: Release" | grep "commit" -m 1 | cut -d " " -f 2)
#find commits since - starting with the magic phrase
ADDED=$(git rev-list $LASTUPDATE..HEAD --grep "^ADDED: ")
UPDATED=$(git rev-list $LASTUPDATE..HEAD --grep "^UPDATED: ")
REMOVED=$(git rev-list $LASTUPDATE..HEAD --grep "^REMOVED: ")
#vars
NUMADDED=0
NUMUPDATED=0
NUMREMOVED=0
#separator is newline
IFS=$'\n'
for COMMIT in $ADDED
do
  COMMITMSGS=$(git show $COMMIT --pretty=format:"%s" | grep "^ADDED: " | tr -d '\0')
    for LINE in $COMMITMSGS
    do
      #save in the temp file to be used by next script
      echo "- "${LINE##*ADDED: }"  " >> $TMP_ADDED
	  NUMADDED++
    done
done
for COMMIT in $UPDATED
do
  COMMITMSGS=$(git show $COMMIT --pretty=format:"%s" | grep "^UPDATED: " | tr -d '\0')
    for LINE in $COMMITMSGS
    do
      #save in the temp file to be used by next script
      echo "- "${LINE##*UPDATED: }"  " >> $TMP_UPDATED
	  NUMUPDATED++
    done
done
for COMMIT in $REMOVED
do
  COMMITMSGS=$(git show $COMMIT --pretty=format:"%s" | grep "^REMOVED: " | tr -d '\0')
    for LINE in $COMMITMSGS
    do
      #save in the temp file to be used by next script
      echo "- "${LINE##*REMOVED: }"  " >> $TMP_REMOVED
	  NUMREMOVED++
    done
done

if [ $NUMADDED -gt 0 ]; then
  echo "### Added  " >> $TMP_CHANGELOG
  cat $TMP_ADDED >> $TMP_CHANGELOG
  echo "\n" >> $TMP_CHANGELOG
fi
if [ $NUMUPDATED -gt 0 ]; then
  echo "### Updated  " >> $TMP_CHANGELOG
  cat $TMP_UPDATED >> $TMP_CHANGELOG
  echo "\n" >> $TMP_CHANGELOG
fi
if [ $NUMREMOVED -gt 0 ]; then
  echo "### Removed  " >> $TMP_CHANGELOG
  cat $TMP_REMOVED >> $TMP_CHANGELOG
  echo "\n" >> $TMP_CHANGELOG
fi
awk '!seen[$0]++' "$TMP_CHANGELOG" >> changeLog.md

echo 'TMessage<<EOF' >> $GITHUB_ENV
cat changeLog.msg >> $GITHUB_ENV
echo 'EOF' >> $GITHUB_ENV
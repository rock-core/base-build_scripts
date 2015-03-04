#! /bin/sh -ex

# This script allows to publish the jenkins build status
#
# Its behaviour is modified by the following environment variables:
#   TARGET_URL: the url to copy to

#BUILDS="rock-basic rock"

echo "<html lang=\"en\"><head><meta charset=\"utf-8\"><title>Rock Current Build Status</title></head><body>" > status/index.html

echo "<p><b>This page shows the current build status of Rock</b></p>" >> status/index.html
echo "<p><b>Ubuntu_LTS</b> is the most recent LTS Version<br><b>Ubuntu_current</b> the most recent version<br><br> In case Ubuntu_current is a LTS, Ubuntu_LTS is the older LTS (e.g. 12.04 and 14.04)</p>" >> status/index.html


DATE=$(date)
echo "last update: $DATE<br>" >> status/index.html

ruby ./extract_overview.rb > "status/overview.html"
echo "<h1>Overview</h1>" >> status/index.html
echo "<iframe src=\"overview.html\" width=\"1300\" height=\"400\"></iframe>" >> status/index.html

for build in $@; do
	echo "getting status of $build"
	echo "<h1>$build</h1>" >> status/index.html
	echo "<iframe src=\"$build.html\" width=\"1300\" height=\"150\"></iframe>" >> status/index.html
	ruby ./extract_status.rb $build > "status/$build.html"
done

echo "</body></html>" >> status/index.html

echo "<br>last update: $DATE" >> status/index.html

(lftp -c "open $TARGET_URL && mirror -v -R --only-newer --parallel=8 --delete ./status www/" )

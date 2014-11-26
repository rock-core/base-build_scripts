#! /bin/sh -ex

# This script allows to publish the jenkins build status
#
# Its behaviour is modified by the following environment variables:
#   TARGET_URL: the url to copy to

#BUILDS="rock-basic rock"

echo "<html lang=\"en\"><head><meta charset=\"utf-8\"><title>Rock Current Build Status</title></head><body>" > status/index.html
DATE=$(date)
echo "generated: $DATE<br>" >> status/index.html

ruby ./extract_overview.rb > "status/overview.html"
echo "<h1>Overview</h1>" >> status/index.html
echo "<iframe src=\"overview.html\" width=\"1300\" height=\"400\"></iframe>" >> status/index.html

for build in $@; do
	echo "getting status of $build"
	echo "<h1>$build</h1>" >> status/index.html
	echo "<iframe src=\"$build.html\" width=\"550\" height=\"150\"></iframe>" >> status/index.html
	ruby ./extract_status.rb $build > "status/$build.html"
done

echo "</body></html>" >> status/index.html

echo "<br>generated: $DATE" >> status/index.html

(lftp -c "open $TARGET_URL && mirror -v -R --only-newer --parallel=8 --delete ./status www/" )

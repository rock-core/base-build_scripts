#! /bin/sh -ex

# This script allows to publish the jenkins build status
#
# Its behaviour is modified by the following environment variables:
#   TARGET_URL: the url to copy to

#BUILDS="rock-basic rock"

echo "<html lang=\"en\"><head><meta charset=\"utf-8\"><title>Rock Current Build Status</title></head><body>" > status/index.html

DATE=$(date)
echo "generated $DATE" >> status/index.html

for build in $@; do
echo "getting status of $build"
ruby ./extract_status.rb $build > "status/$build.html"
echo "<h1>$build</h1>" >> status/index.html
echo "<iframe src=\"$build.html\" width=\"550\" height=\"150\"></iframe>" >> status/index.html
done

echo "</body></html>" >> status/index.html

(lftp -c "open $TARGET_URL && mirror -v -R --only-newer --parallel=8 --delete ./status www/" )

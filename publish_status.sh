#! /bin/sh -ex

# This script allows to publish the jenkins build status
#
# Its behaviour is modified by the following environment variables:
#   BUILDS: the directory in which the documentation has been generated
#   TARGET_URL: the url to copy to

#BUILDS="rock-basic rock"

echo "<html lang=\"en\"><head><meta charset=\"utf-8\"><title>Rock Current Build Status</title></head><body>" > status/status.html

for build in ${BUILDS}; do
echo "getting status of $build"
ruby ./extract_status.rb > "status/$build.html"
echo "<h1>$build</h1>" >> status/status.html
echo "<iframe src=\"$build.html\" width=\"550\" height=\"150\"></iframe>" >> status/status.html
done

echo "</body></html>" >> status/status.html

(lftp -c "open $TARGET_URL && mirror -v -R --only-newer --parallel=8 --delete ./status www/" )

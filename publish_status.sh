#! /bin/sh -ex

# This script allows to publish the jenkins build status
#
# Its behaviour is modified by the following environment variables:
#   TARGET_URL: the url to copy to
#   UPLOAD_USER: the user name to use to upload 
#   GITHUB_ACCESS_TOKEN: this needs to be set to get access to the github api

#BUILDS="rock-basic rock"

set +x
UPLOAD_PASSWD=`cat /var/lib/jenkins/upload_passwd`
JENKINS_SERVER='http://bob.dfki.uni-bremen.de:8080'

if [ -x "$UPLOAD_PASSWD" ]; then
    echo "Could not extract upload password, please check if it is set correctly"
    echo $UPLOAD_PASSWD
fi
set -ex

echo '<html lang=\"en\"><head><meta charset=\"utf-8\"><title>Rock Current Build Status</title><link rel="stylesheet" type="text/css" href="jenkins_style.css"></head><body>' > status/index.html

echo "<p><b>This page shows the current build status of Rock</b></p>" >> status/index.html
echo "<p><b>Visit <a href=\"issues.html\"> this page</a> to show all issues of rock</b></p>" >> status/index.html
echo "<p><b>Ubuntu_LTS</b> is the most recent LTS Version<br><b>Ubuntu_current</b> the most recent version<br><br> In case Ubuntu_current is a LTS, Ubuntu_LTS is the older LTS (e.g. 12.04 and 14.04)</p>" >> status/index.html


DATE=$(date)
echo "last update: $DATE<br>" >> status/index.html

#ruby ./extract_overview.rb > "status/overview.html"
echo "<h1>Overview</h1>" >> status/index.html

#echo "<iframe src=\"overview.html\" width=\"1300\" height=\"300\"></iframe>" >> status/index.html
ruby ./extract_overview.rb >> status/index.html
#Generate issues page
ruby ./generate_issue_page.rb || true #This is not critical for us

#get rss feeds
echo '<a href="rssAll"><img border="0" width="16" height="16" src="atom.gif" alt="Feed"></img>RSS for all</a><br>' >> status/index.html
echo '<a href="rssFailed"><img border="0" width="16" height="16" src="atom.gif" alt="Feed"></img>RSS for failures</a><br>' >> status/index.html
echo '<a href="rssLatest"><img border="0" width="16" height="16" src="atom.gif" alt="Feed"></img>RSS for just latest builds</a><br>' >> status/index.html
(
cd status
curl ${JENKINS_SERVER}/view/Rock/rssLatest > rssLatest
curl ${JENKINS_SERVER}/view/Rock/rssFailed > rssFailed
curl ${JENKINS_SERVER}/view/Rock/rssAll > rssAll

#temp for testing package_list
curl https://raw.githubusercontent.com/planthaber/planthaber.github.io/master/rock-package-list/JSON.js > JSON.js
curl https://raw.githubusercontent.com/planthaber/planthaber.github.io/master/rock-package-list/jquery-2.1.3.min.js > jquery-2.1.3.min.js
curl https://raw.githubusercontent.com/planthaber/planthaber.github.io/master/rock-package-list/packages.html > packages.html
)

#status for specific projects

for build in $@; do
	echo "getting status of $build"
	echo "<h1>$build</h1>" >> status/index.html
	#echo "<iframe src=\"$build.html\" width=\"440\" height=\"120\"></iframe>" >> status/index.html
	ruby ./extract_status.rb $build >> status/index.html
        #Extract the Test results
	echo "getting test-results of $build"
        ruby ./extract_test_results.rb $build || true #This is not critical for us
done

echo "</body></html>" >> status/index.html

echo "<br>last update: $DATE" >> status/index.html

set +x #hide output it would contain the password
echo "Starting upload..."
(lftp -c "open -u $UPLOAD_USER,$UPLOAD_PASSWD  $TARGET_URL && mirror -v -R --only-newer --parallel=8 --delete ./status www/" )
echo "...upload finished"
set -x #reenable output





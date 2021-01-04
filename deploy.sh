#!bash

docker-compose down
# Initial clean up of shared resources if any
# Remove shared folder 
[[ -d ./deploy ]] && rm -rf ./deploy

#Remove git repos if any
[[ -d ./gitserver/repos ]] && rm -rf ./gitserver/repos/*

[[ -d test ]] && rm -rm ./test

# Start
# Build intermidiate containers
docker-compose build

# Start stack
docker-compose up -d

#Create git repo
if [[ $OS == 'Windows_NT' ]];then
    winpty docker-compose exec git-server mkrepo test
else 
    docker-compose exec git-server mkrepo test
fi

###### Initial commit to git ######
git clone http://localhost:8099/git/test.git
cd test
touch emptyfile
git add .
git commit -am "Initital commit"
git push 

cd -


#let Jenkins to start up
echo Wait for Jenkins to start up
sleep 60 
# Jenkins get token
JENKINS_CRUMB=$(curl --silent --cookie-jar /tmp/cookies http://localhost:8080'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u admin:admin)
TOKEN=$( curl -s -X POST --cookie /tmp/cookies  'http://localhost:8080/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken' --data 'newTokenName=mytoken'  --user admin:admin  -H "$JENKINS_CRUMB" -H "Content-Type:text/xml" | awk  'BEGIN{FS="\""}{print $18}')

#Create Jenkins job
curl -s -XPOST 'http://localhost:8080/createItem?name=BlueSnap-pipe' --data-binary @./jenkins/Bluesnap_pipe-config.xml -H "Content-Type:text/xml" --user admin:$TOKEN

# Run initial build
curl -s -XPOST 'http://localhost:8080/job/BlueSnap-pipe/build' -H "Content-Type:text/xml" --user admin:$TOKEN

cat << EOF

############################################
Done, stack is up and running
    Check Jenkins http://localhost:8080/ 
        User admin:admin
        job name BlueSnap-pipe
    Clone repo:
        git clone http://localhost:8099/git/test.git
    Change file index.html and push it back
    Verify that change uploaded to URL http://localhost:8099/
EOF


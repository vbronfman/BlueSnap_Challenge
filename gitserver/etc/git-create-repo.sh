#!/bin/bash
# Script grabbed here https://linuxhint.com/setup_git_http_server_docker/ and modified 
 
GIT_DIR="/var/www/git"
REPO_NAME=$1
 
mkdir -p "${GIT_DIR}/${REPO_NAME}.git"
cd "${GIT_DIR}/${REPO_NAME}.git"
 
git init --bare &> /dev/null
touch git-daemon-export-ok
# https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
cp hooks/post-update.sample hooks/post-update

# Create post-receive hook "...notifying a continuous integration server""
cat << EOF > hooks/post-receive
#!/bin/sh
#
# An example hook script to prepare a packed repository for use over
# dumb transports.
#
# To enable this hook, rename this file to "post-update".
#curl http://yourserver/git/notifyCommit?url=<URL of the Git repository>

#exec curl http://jenkins:8080/git/notifyCommit?url=http://git-server:80/git/test.git
exec curl http://${JENKINS_SERVER}:${JENKINS_PORT}/git/notifyCommit?url=http://git-server:80/git/test.git
EOF


git update-server-info
chown -Rf www-data:www-data "${GIT_DIR}/${REPO_NAME}.git" 
echo "Git repository '${REPO_NAME}' created in ${GIT_DIR}/${REPO_NAME}.git"
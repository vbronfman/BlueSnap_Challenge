BlueSnap Challenge

# Introduction
Besides building a continuous pipeline, adopting new technologies, and thinking in scale; we would like to
build an Apache web server that will deploy builds from Jenkins pipeline. To do so, we must construct a
Jenkins server that will listen to Git SCM.
Objective
Please build and deliver a simple webserver / Jenkins / Git stack.
Requirements

1. The stack will be composed of 3 components – Git , Jenkins and Apache HTTPD.
2. The stack needs to run on top of CentOS 7 (or 8) VirtualBox Machine (VM).
3. You will deliver a tar.gz file, compromised of the following filed:
1. README.md – this file will hold all the information needed for the project.
2. Other files need for building your stack. For instance, build.sh which will create a
virtual machine and deploy.sh which will deploy the stack into the virtual-machine.
3. Once done, use Jenkinsfile to deploy Apache files into /var/www/html folder.
4. Your code and scripts must run on UNIX like systems (Linux\MacOS).
4. Optional – deliver system tests to prove the stack is working as expected.


## Pre-face
*Note*
Please note the solutions  meet requirements of production grade by no means .; 
Due shortage of time and for simplicity sake only, the following assumtions apply:; 
- names and path are pre-defined
- same instance of Apache HTTP is in use by Git and is target of deployment
- shared volume to deploy build artifacts and update Apache HTTP; should be either regular 
docker plugin or 'docker cp' at least
- there are plenty of stopgap solutions in place of proper ones; 

## Prerequisites:
- Docker with docker-composer 
- curl

## Usage
1. Untar archive
2. Run ./deploy.sh
3. Modify and upload source code:
    - clone repo:
    git clone http://localhost:8099/git/test.git
    - change file index.html and push it back
4. Verify that change uploaded to URL http://localhost:8099/
5. Check Jenkins is up http://localhost:8080/ 
   - User admin:admin
   - job name BlueSnap-pipe

## Overview
Project implies stack of docker containers under the governance of docker-compose
The project's tree comprises  :
- ./jenkins: resources to build Docker container runs Jenkins server
- ./git-server: resources to build Docker container runs both Git and Apache HTTP 
- Shared volumes exposed to local filesystem:
    - ./gitserver/repos
    - ./deploy
- docker-compose.yaml - docker-compose input
- .env - environment variables for docker-compose
- deploy.sh - bash script to set up and start the stack

## Set up
Entire project set up by ./deploy.sh
Below sections provide outline of steps.

### Install and config Jenkins server
1. Build custom image of Docker host and start it (see ./jenkins/Dockerfile); 
    - omits initial setup with wizard.runSetupWizard=false (https://www.digitalocean.com/community/tutorialsow-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code
2. Forces Jenkins instance to install plugins. 
    - employs Jenkins build-in /usr/local/bin/install-plugins.sh and list of plugina out of ./jenkins/plugins.txt
    WARN: install-plugins.sh is deprecated, please switch to jenkins-plugin-cli
        https://www.jenkins.io/doc/book/managing/plugins/

3. Create user admin:admin by employing of groovy script default-user.groovy :
    - Jenkins runs all grovy files from init.groovy.d dir; use this for creating default admin user
4. Exposes port 8080  of local host


### Git along with Apache HTTP (inspired by https://linuxhint.com/setup_git_http_server_docker/ ) 
1. Builds custom image of Centos7 (see gitserver/gitserver.Dockerfile)
    - install Git
    - install http
2. copy  ./gitserver/etc/git.conf and set git congfiguration for Apache HTTP
3. copy script ./gitserver/etc/git-create-repo.sh
4. creates hook/post-receive server hook.  The post-receive hook runs after the entire process is completed and can be used to update other services or notify users. It takes the same stdin data as the pre-receive hook. Examples include emailing a list, notifying a continuous integration server.
    - add 
        exec curl http://yourserver/git/notifyCommit?url=<URL of the Git repository>
    Note: Git repo is http://git-server:80/git/test.git
4. starts Apache HTTP  to listen port 8099 of local host

### Setup of Jenkins job 
Set up employs Jenkins API to and predefined config.xml to set up job "BlueSnap-pipe"
1. Generate token for user 'admin' (https://support.cloudbees.com/hc/en-us/articles/115003090592-How-to-re-generate-my-Jenkins-user-token)
    - crumb
    JENKINS_CRUMB=$(curl --silent --cookie-jar /tmp/cookies http://localhost:8080'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u admin:admin)
    - Get token - I know this super ugly, I'm short of time by now 
    TOKEN=$( curl -s -X POST --cookie /tmp/cookies  'http://localhost:8080/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken' --data 'newTokenName=mytoken'  --user admin:admin  -H "$JENKINS_CRUMB" -H "Content-Type:text/xml" | awk  'BEGIN{FS="\""}{print $18}')

2. Create job with curl. To create a new job, post config.xml to this URL with query parameter name=JOBNAME. You need to send a Content-Type: application/xml header. You will get a 200 status code if the creation is successful, or 4xx/5xx code if it fails. config.xml is the format Jenkins uses to store the project in the file system, so you can see examples of them in the Jenkins home directory, or by retrieving the XML configuration of existing jobs from /job/JOBNAME/config.xml.
    - curl -s -XPOST 'http://jenkins/createItem?name=yourJobName' --data-binary @config.xml -H "Content-Type:text/xml" --user user.name:YourAPIToken.
3. Launch intital job
    - curl -s -XPOST 'http://localhost:8080/job/BlueSnap-pipe/build' -H "Content-Type:text/xml" --user admin:$TOKEN


## Integration
Trigger job like this if you will:
    curl -i 'http://localhost:8080/job/Bluesnap_challenge/build?delay=0sec' --user admin:$TOKEN


## Submit change to index.html
This would trigger CI job in jenkins
1. Clone repo
D:\tmp_to_delete\mygitrepo>git clone http://localhost:8099/git/test.git Bluesnap
Cloning into 'Bluesnap'...
warning: You appear to have cloned an empty repository.

2. 
D:\tmp_to_delete\mygitrepo>cd Bluesnap

3. Make a change of content 
D:\tmp_to_delete\mygitrepo\Bluesnap>echo "Ok first page" >> index.html

4. 
D:\tmp_to_delete\mygitrepo\Bluesnap>git add -A

5. Commit change
D:\tmp_to_delete\mygitrepo\Bluesnap>git commit -am "Initial commit"
[master (root-commit) c5f1b50] Initial commit
 1 file changed, 1 insertion(+)
 create mode 100644 index.html

6. Push
D:\tmp_to_delete\mygitrepo\Bluesnap>git push
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Writing objects: 100% (3/3), 233 bytes | 116.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
remote:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
remote:                                  Dload  Upload   Total   Spent    Left  Speed
remote: 100    95  100    95    0     0    658      0 --:--:-- --:--:-- --:--:--   659
remote: No git jobs found
remote: No Git consumers using SCM API plugin for: http://git-server:80/git/test.git
To http://localhost:8099/git/test.git
 * [new branch]      master -> master




























Download ISO
curl http://centos.spd.co.il/8.3.2011/isos/x86_64/CentOS-8.3.2011-x86_64-boot.iso --output /d/CentOS-8.3.2011-x86_64-boot.iso 
or
 curl http://mirror.vpsnet.com/centos-altarch/7.9.2009/isos/i386/CentOS-7-i386-Everything-2009.iso --output  CentOS-7-i386-Everything-2009.iso



















follow this doc https://www.oracle.com/technical-resources/articles/it-infrastructure/admin-manage-vbox-cli.html
2.  VBoxManage createvm --name OracleLinux6Test --ostype Oracle_64 --register
3. VBoxManage modifyvm CentOs8Test --cpus 2 --memory 2048 --vram 12
4. VBoxManage modifyvm CentOs8Test --nic1 bridged --bridgeadapter1 eth0 
5.  VBoxManage createhd --filename ./CentOs8Test.vdi --size 5120 --variant Standard
6. VBoxManage storagectl CentOs8Test --name "SATA Controller" --add sata --bootable on
7. attach the hard disk to the controller:
VBoxManage storageattach CentOs8Test --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ./CentOs8Test.vdi
8. create DVD 
 VBoxManage storagectl CentOs8Test --name "IDE Controller" --add ide
9. Attach image 
 VBoxManage storageattach CentOs8Test --storagectl "IDE Controller"  --port 0  --device 0 --type dvddrive --medium "./CentOS-8.3.2011-x86_64-boot.iso"
10. VBoxManage unattended install CentOs8Test --iso=./CentOS-8.3.2011-x86_64-boot.iso --user=root --password=Yxxxx


 


2. Build VM 



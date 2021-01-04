FROM jenkins/jenkins:lts
ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false
ENV JENKINS_USER=admin
ENV JENKINS_PASS=admin

COPY plugins.txt /usr/share/jenkins/plugins
# RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
RUN while read i ; \ 
      do /usr/local/bin/install-plugins.sh $i ; \
    done < /usr/share/jenkins/plugins
#get CLI
#ADD 
# Jenkins runs all grovy files from init.groovy.d dir
# use this for creating default admin user
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
#COPY create_token.groovy /usr/share/jenkins/ref/init.groovy.d/
#RUN java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin git -deploy

EXPOSE 8080
EXPOSE 50000
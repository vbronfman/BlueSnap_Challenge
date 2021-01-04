#gitserver.Dockerfile
FROM centos:7
#FROM ubuntu:18.04
#RUN apt update 2>/dev/null
#RUN apt install -y git apache2 apache2-utils 2>/dev/null

# Install Apache
RUN yum -y update
RUN yum -y install git  httpd httpd-tools

# Install EPEL Repo
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

#RUN a2enmod env cgi alias rewrite
RUN mkdir /var/www/git
#RUN chown -Rfv www-data:www-data /var/www/git
COPY ./etc/git.conf /etc/apache2/sites-available/git.conf 
COPY ./etc/git-create-repo.sh /usr/bin/mkrepo
RUN chmod +x /usr/bin/mkrepo
#RUN a2dissite 000-default.conf
#RUN a2ensite git.conf
# Update Apache Configuration
RUN sed -E -i -e '/<Directory "\/var\/www\/html">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
#RUN sed -E -i -e 's/DirectoryIndex (.*)$/DirectoryIndex index.php \1/g' /etc/httpd/conf/httpd.conf
RUN mkdir /etc/httpd/sites-available /etc/httpd/sites-enabled
COPY ./etc/git.conf /etc/httpd/sites-available/git.conf
RUN ln -s /etc/httpd/sites-available/git.conf /etc/httpd/sites-enabled/git.conf
RUN echo 'IncludeOptional sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf


RUN git config --system http.receivepack true
RUN git config --system http.uploadpack true

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/httpd
ENV APACHE_LOCK_DIR /var/lock/httpd
ENV APACHE_PID_FILE /var/run/apache2.pid
EXPOSE 80/tcp

# Start Apache
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]

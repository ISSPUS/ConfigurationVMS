FROM ubuntu:16.04

ENV JAVA_VERSION 8
ENV TOMCAT_MAJOR 7
ENV TOMCAT_VERSION 7.0.75
ENV MYSQL_VERSION 5.7
ENV ECLIPSE neon/2/eclipse-jee-neon-2
ENV MYSQL_ROOT_PASSWORD root


RUN apt-get update \
    && apt-get install -y apt-utils software-properties-common curl openssl

RUN add-apt-repository -y ppa:webupd8team/java && apt-get update

RUN echo oracle-java$JAVA_VERSION-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java$JAVA_VERSION-installer libxext-dev libxrender-dev libxtst-dev curl sudo

RUN apt-get install -y maven

RUN bash -c "curl -SL http://apache.uvigo.es/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | \
        tar -C /opt/ -xz"

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN set -ex; \
    # gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
	key='A4A9406876FCBD3C456770C88C718D3B5072E1F5'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
	rm -r "$GNUPGHOME"; \
    apt-key list > /dev/null

RUN { \
		echo mysql-server-$1 mysql-server/root_password password root; \
		echo mysql-server-$1 mysql-server/root_password_again password root; \
		echo mysql-server-$1 mysql-server/remove-test-db select false; \
	} | /usr/bin/debconf-set-selections \
    && apt-get install -y mysql-server-$MYSQL_VERSION \
	&& rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	&& chmod 777 /var/run/mysqld

RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/mysql.conf.d/mysqld.cnf \
    && echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf


RUN apt-get install gosu \
    && curl -SL https://raw.githubusercontent.com/docker-library/mysql/eeb0c33dfcad3db46a0dfb24c352d2a1601c7667/5.7/docker-entrypoint.sh > /usr/local/bin/docker-entrypoint.sh \
    && ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat

RUN chmod +x /entrypoint.sh

VOLUME /var/lib/mysql

RUN bash -c "curl -SL http://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/$ECLIPSE-linux-gtk-x86_64.tar.gz | \
        tar -C /opt/ -xz" \
    && ln -s /opt/eclipse/eclipse /usr/bin/eclipse \
    && apt-get install -y libgtk2.0-0

VOLUME /root/workspace

    # MySQL
EXPOSE 3306
    # Tomcat
EXPOSE 8080


RUN sed -i '2i exec eclipse &' /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/entrypoint.sh", "mysqld"]




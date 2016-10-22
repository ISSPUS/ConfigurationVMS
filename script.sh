#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function separator {
    echo -e "\n\n\n"
}

function check_correct {
    if [ $1 ]; then
        echo "Instalado !"
    else
        echo "Hubo un error"
        exit 1
    fi 
}

function add_repositories {
    RESULT=false

    ## add-apt-repository -y ppa:andrei-pozolotin/maven3 && \  # MAVEN
    add-apt-repository -y ppa:webupd8team/java && \  # JAVA
    apt-get update && RESULT=true

    check_correct $RESULT
}

function install_java {
    RESULT=false

    # Seleccionando la versión de java
    JAVA_VERSION=$1
    echo "Instalando java$JAVA_VERSION..."

    apt-get update && \
    echo oracle-java$JAVA_VERSION-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java$JAVA_VERSION-installer libxext-dev libxrender-dev libxtst-dev curl sudo && RESULT=true

    check_correct $RESULT
}

function install_maven {
    RESULT=false
    echo "Instalando maven3..."

    apt-get install -y maven3 && RESULT=true

    check_correct $RESULT
}

function install_tomcat {
    RESULT=false; RESULT2=false
    echo "Instalando tomcat$1..."

    apt-get install -y tomcat$1 && \
    sed -i.bak 's/JAVA_OPTS.*/JAVA_OPTS="-Djava.security.egd=file:\/dev\/\.\/urandom -Djava\.awt\.headless=true -Xmx512m -XX:MaxPermSize=256m -XX:\+UseConcMarkSweepGC"/g' /etc/default/tomcat$1 && \
    RESULT=true

    check_correct $RESULT

     if [ $RESULT ]; then
        echo "Habilitandp tomcat$1..."

        systemctl restart tomcat$1 && \
        systemctl enable tomcat$1 && \
        RESULT2=true

        check_correct $RESULT2
    fi

}

function install_eclipse {
    RESULT=false
    echo "Instalando eclipse ($1)..."

    apt-get install -y curl && \
    bash -c "curl -SL http://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/oxygen/M2/eclipse-$1-linux-gtk-x86_64.tar.gz | \
        tar -C /opt/ -xz" && \
    ln -s /opt/eclipse/eclipse /usr/bin/eclipse && \
    bash -c "curl -SL https://raw.githubusercontent.com/EGCG2/ConfigurationVMS/master/Eclipse/Eclipse.desktop -o /usr/share/applications/Eclipse.desktop" && \
    chmod +x /usr/bin/eclipse && RESULT=true

    check_correct $RESULT
}

function install_mysql {
    RESULT=false

    echo "Instalando MYSQL"

    { \
		echo mysql-server mysql-community-server/root-pass password 'root'; \
		echo mysql-server mysql-community-server/re-root-pass password 'root'; \
		echo mysql-server mysql-community-server/remove-test-db select false; \
	} | /usr/bin/debconf-set-selections
    apt-get install -y mysql-server=$1

    systemctl restart mysql
    systemctl enable mysql

    check_correct $RESULT
}


function main {
    echo "Actualizando el sistema"
    apt-get update && apt-get upgrade -y

    echo "Añadiendo usuario al grupo vboxsf para permitir compartir carpetas"
    usermod -a -G vboxsf usuario

    add_repositories

    separator
    install_java 7

    separator
    install_maven

    separator
    install_tomcat 7

    separator
    install_mysql 5.7.15-0ubuntu0.16.04.1

    separator
    install_java 8

    separator
    install_eclipse jee-oxygen-M2

    separator
    echo "Finalizado ! !"

}

# Comprobar que el script está corriendo como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ser lanzado como root" 1>&2
   exit 1
fi

E=`fuser /var/lib/dpkg/lock`
if [[ $E -ne 0 ]]; then
   echo -e "Actualmente no es posible instalar los programas porque hay otras actualizaciones en proceso. \nIntentelo más tarde" 1>&2
   exit 1
fi

main

exit 0

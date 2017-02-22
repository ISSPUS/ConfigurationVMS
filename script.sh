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
    echo "Instalando maven..."

    apt-get install -y maven && RESULT=true

    check_correct $RESULT
}

function install_tomcat {
    RESULT=false
    TOMCAT_MAJOR=$1
    TOMCAT_VERSION=$2
    echo "Instalando tomcat ($TOMCAT_MAJOR/v$TOMCAT_VERSION)..."

    apt-get install -y curl && \
    bash -c "curl -SL http://apache.uvigo.es/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | \
        tar -C /opt/ -xz" && RESULT=true

    # Configurar Tomcat
    # sed -i.bak 's/JAVA_OPTS.*/JAVA_OPTS="-Djava.security.egd=file:\/dev\/\.\/urandom -Djava\.awt\.headless=true -Xmx512m -XX:MaxPermSize=256m -XX:\+UseConcMarkSweepGC"/g' /etc/default/tomcat$1 && RESULT=true


    check_correct $RESULT

}

function install_eclipse {
    RESULT=false
    echo "Instalando eclipse ($1)..."

    bash -c "curl -SL http://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/$1-linux-gtk-x86_64.tar.gz | \
        tar -C /opt/ -xz" && \
    ln -s /opt/eclipse/eclipse /usr/bin/eclipse && \
    bash -c "curl -SL https://raw.githubusercontent.com/ISSPUS/ConfigurationVMS/master/Eclipse/Eclipse.desktop -o /usr/share/applications/Eclipse.desktop" && \
    chmod +x /usr/bin/eclipse && RESULT=true

    check_correct $RESULT
}

function install_mysql {
    RESULT=false
    RESULT2=false
    RESULT3=false

    echo "Instalando MYSQL"

    { \
		echo mysql-server-$1 mysql-server/root_password password root; \
		echo mysql-server-$1 mysql-server/root_password_again password root; \
		echo mysql-server-$1 mysql-server/remove-test-db select false; \
	} | /usr/bin/debconf-set-selections
    apt-get install -y mysql-server-$1 && RESULT=true

    check_correct $RESULT

    systemctl restart mysql && \
    systemctl enable mysql && RESULT2=true

    check_correct $RESULT2

    apt-get install -y gmysqlcc && RESULT3=true

    check_correct $RESULT3
}


function main {
    echo "Actualizando el sistema"
    apt-get update && apt-get upgrade -y && apt-get install -y apt-utils software-properties-common curl

    echo "Añadiendo usuario al grupo vboxsf para permitir compartir carpetas"
    usermod -a -G vboxsf usuario

    add_repositories

    separator
    install_java 8

    separator
    install_maven

    separator
    install_tomcat 8 8.5.11

    separator
    install_mysql 5.7

    separator
    install_eclipse neon/2/eclipse-jee-neon-2

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

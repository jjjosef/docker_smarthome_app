FROM ubuntu:16.04

MAINTAINER Jason Yang <jason760924@gmail.com>

ENV NODE_VERSION=8.8.0 \
    NPM_VERSION=5.5.1 \
    IONIC_VERSION=3.15.2 \
    CORDOVA_VERSION=7.1.0 \
    ANDROID_HOME="/opt/android-sdk-linux" \
    SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip" \
    GRADLE_VERSION=4.2.1

RUN apt-get update && \
    apt-get install -y wget curl zip git python build-essential keychain && \
    curl --retry 3 -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" && \
    tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-x64.tar.gz" && \
    npm install -g npm@"$NPM_VERSION" && \
    npm install -g cordova@"$CORDOVA_VERSION" ionic@"$IONIC_VERSION" && \
    npm cache clear --force && \
#JAVA
    apt-get update && \
    apt-get install -y -q python-software-properties software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get update && apt-get -y install oracle-java8-installer && \
    apt-get clean && \
#ANDROID SDK
    mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    curl -o sdk.zip $SDK_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
    yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses && \
#Gradle
    wget https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-bin.zip && \
    mkdir -p /opt/gradle && \
    unzip -d /opt/gradle gradle-"$GRADLE_VERSION"-bin.zip && \
    rm -rf gradle-"$GRADLE_VERSION"-bin.zip

# Setup environment
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:/opt/gradle/gradle-"$GRADLE_VERSION"/bin:/usr/local/bin/devtools

RUN sdkmanager --verbose "platform-tools" "tools" "build-tools;27.0.0" "build-tools;26.0.2" "platforms;android-27" "platforms;android-26" "build-tools;25.0.3" "platforms;android-25" "extras;android;m2repository" "extras;google;m2repository" "ndk-bundle"

WORKDIR /home/user/
COPY ./id_rsa /root/.ssh/
COPY ./known_hosts /root/.ssh/
RUN git clone git@github.com:exosite/semi_vertical_app.git --depth 1 --branch feature/SVH-672 

WORKDIR /home/user/semi_vertical_app
RUN npm i && \
    ionic cordova build android --prod && \
    rm -rf ./.git/ && \
    rm -rf /root/.ssh/ \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./shells /usr/local/bin/devtools

WORKDIR /
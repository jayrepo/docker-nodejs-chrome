FROM node:current-slim

USER root

#============================================
# Dependencies
#============================================
RUN apt-get update -qqy \
    && apt-get -qqy install \
    wget \
    jq \
    unzip \
    gnupg \
    xvfb \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#============================================
# Google Chrome
#============================================
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -qqy \
    && apt-get -qqy install google-chrome-stable \
    && rm /etc/apt/sources.list.d/google-chrome.list \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/

#============================================
# chromedriver
#============================================
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}') \
    && CHROME_DRIVER_URL=$(curl https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json | jq '.versions[] | select(.version == "${}") | .downloads.chromedriver[] | select(.platform == "linux64") | .url') \
    && echo "Using chromedriver: "$CHROME_DRIVER_URL \
    && wget -q -O /tmp/chromedriver_linux64.zip CHROME_DRIVER_URL \
    && rm -rf /opt/selenium/chromedriver \
    && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
    && rm /tmp/chromedriver_linux64.zip \
    && chmod 755 /opt/selenium/chromedriver \
    && ln -fs /opt/selenium/chromedriver /usr/bin/chromedriver

#============================================
# node-gyp
#============================================
RUN apt-get update -qqy \
    && apt-get -qqy install \
    python3 \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV DISPLAY :99

USER node

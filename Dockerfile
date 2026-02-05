FROM node:current-slim

USER root

#============================================
# Dependencies + Google Chrome + node-gyp
#============================================
RUN apt-get update -qqy \
    && apt-get -qqy install \
    wget \
    jq \
    unzip \
    gnupg \
    xvfb \
    python3 \
    g++ \
    make \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmour -o /usr/share/keyrings/google-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -qqy \
    && apt-get -qqy install google-chrome-stable \
    && rm /etc/apt/sources.list.d/google-chrome.list \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#============================================
# chromedriver
#============================================
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}') \
    && echo "Chrome version: $CHROME_VERSION" \
    && VERSION_PREFIX=$(echo "$CHROME_VERSION" | cut -d. -f1-3) \
    && echo "Version prefix: $VERSION_PREFIX" \
    && wget -qO /tmp/versions.json https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json \
    && CHROME_DRIVER_URL=$(jq --arg ver "$CHROME_VERSION" -r \
       '.versions[] | select(.version == $ver) | .downloads.chromedriver[] | select(.platform == "linux64") | .url' /tmp/versions.json) \
    && if [ -z "$CHROME_DRIVER_URL" ]; then \
         echo "Exact version not found, searching for latest matching version with prefix $VERSION_PREFIX..." \
         && CHROME_DRIVER_URL=$(jq --arg ver "$CHROME_VERSION" --arg prefix "$VERSION_PREFIX." -r \
            '[.versions[] | select(.version | startswith($prefix)) | select(.version < $ver) | select(.downloads.chromedriver != null)] | last | .downloads.chromedriver[] | select(.platform == "linux64") | .url' /tmp/versions.json); \
       fi \
    && rm -f /tmp/versions.json \
    && echo "Using chromedriver: $CHROME_DRIVER_URL" \
    && wget -q -O /tmp/chromedriver_linux64.zip "$CHROME_DRIVER_URL" \
    && rm -rf /opt/selenium/chromedriver \
    && unzip -j /tmp/chromedriver_linux64.zip -d /opt/selenium \
    && rm /tmp/chromedriver_linux64.zip \
    && chmod 755 /opt/selenium/chromedriver \
    && ln -fs /opt/selenium/chromedriver /usr/bin/chromedriver

ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV DISPLAY=:99

USER node

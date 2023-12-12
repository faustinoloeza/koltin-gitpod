FROM gitpod/workspace-full-vnc:2023-12-11-21-01-51

SHELL ["/bin/bash", "-c"]
ENV QTWEBENGINE_DISABLE_SANDBOX=1
ENV PATH="$HOME/opt/android-studio/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Install Open JDK for Android and other dependencies
USER root
RUN install-packages openjdk-17-jdk -y \
        libgtk-3-dev \
        liblzma-dev \
        clang \
        ninja-build \
        pkg-config \
        cmake \
        libnss3-dev \
        fonts-noto \
        fonts-noto-cjk \
        libstdc++-12-dev \
        wget \
        unzip \
        && update-java-alternatives --set java-17-openjdk-amd64

# Update Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && apt-get -y install google-chrome-stable

# Install Kotlin
RUN wget -O kotlin-installer.zip "https://github.com/JetBrains/kotlin/releases/download/v1.5.21/kotlin-compiler-1.5.21.zip" \
    && unzip kotlin-installer.zip -d /opt/ \
    && rm kotlin-installer.zip

# Download and install Android Studio
RUN wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.3.1.21/android-studio-2022.3.1.21-linux.tar.gz -O android-studio.tar.gz && \
    tar -xzvf android-studio.tar.gz -C /opt/ && \
    rm android-studio.tar.gz

# Install Flutter and dependencies
USER gitpod
RUN echo "Downloading Android command line tools..." \
    && _file_name="commandlinetools-linux-8512546_latest.zip" \
    && wget "https://dl.google.com/android/repository/$_file_name" \
    && unzip "$_file_name" -d $ANDROID_HOME \
    && rm -f "$_file_name" \
    && echo "Android command line tools downloaded successfully."

RUN echo "Setting up Android SDK..." \
    && mkdir -p $ANDROID_HOME/cmdline-tools/latest \
    && mv $ANDROID_HOME/cmdline-tools/{bin,lib} $ANDROID_HOME/cmdline-tools/latest \
    && yes | sdkmanager "platform-tools" "build-tools;34.0.0" "platforms;android-33" \
    && echo "Android SDK set up successfully."

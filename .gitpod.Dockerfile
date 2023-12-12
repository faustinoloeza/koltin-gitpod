FROM gitpod/workspace-full-vnc:2023-11-19-19-13-44
SHELL ["/bin/bash", "-c"]
ENV ANDROID_HOME=$HOME/androidsdk \
    QTWEBENGINE_DISABLE_SANDBOX=1
ENV PATH="$HOME/flutter/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Install Open JDK for android and other dependencies
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
        && update-java-alternatives --set java-1.17.0-openjdk-amd64


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

RUN echo "Setting up Flutter..." \
    && flutter precache \
    && for _plat in web linux-desktop; do flutter config --enable-${_plat}; done \
    && flutter config --android-sdk $ANDROID_HOME \
    && yes | flutter doctor --android-licenses \
    && flutter doctor \
    && echo "Flutter set up successfully."


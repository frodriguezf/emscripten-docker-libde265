# based on Ubuntu
FROM ubuntu:20.04
#FROM prodromou87/llvm:8

# environment variable
#ENV EMSDK_NAME sdk-1.31.3-32bit
ENV EMSDK_NAME  emscripten-tag-1.31.3-32bit
ENV CMAKE_VERSION_MAJOR 3.28
ENV CMAKE_VERSION 3.28.1

# update the repository sources list
# install some packages
# curl, python, git-core
# build-essential
# openjdk-8-jdk, ant

ENV DEBIAN_FRONTEND "noninteractive"
RUN apt-get update && apt-get install -y \
    build-essential \
    python \
    tzdata\
    curl\
    git-core\
    openjdk-8-jdk\
    ant\
    libidn11\
    nodejs\
    && rm -rf /var/lib/apt/lists/*

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

# download CMake
RUN cd /tmp \
    && curl -Ok https://cmake.org/files/v${CMAKE_VERSION_MAJOR}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz \
    && tar zxf cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz \
    && rm cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz \
    && mv cmake-${CMAKE_VERSION}-Linux-x86_64 /opt/cmake \
    && ln -s /opt/cmake/bin/cmake /usr/bin/cmake

# download emsdk
#RUN cd /tmp \
#    && curl -Ok https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz \
#    && tar zxf emsdk-portable.tar.gz \
#    && rm emsdk-portable.tar.gz \
#    && mv emsdk-portable /emsdk

RUN echo "## Get EMSDK" \
    &&  git clone https://github.com/emscripten-core/emsdk.git /emsdk \
    &&  cd /emsdk && git reset --hard main \
    &&  ./emsdk update-tags \
    &&  echo "## Done"

# update emsdk
RUN cd /emsdk \
    #&& ./emsdk update \
    && ./emsdk install ${EMSDK_NAME} \
    && ./emsdk activate ${EMSDK_NAME}

# clean packages
RUN apt-get clean\
    && apt-get autoclean\
    && apt-get autoremove\
    && rm -rf /var/lib/apt/lists/*

# entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# default COMMAND
CMD ["/bin/bash"]

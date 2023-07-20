FROM ubuntu:bionic as build

LABEL description="Build vsomeip"

ENV VSOMEIP_VERSION 3.3.0
ENV VSOMEIP_SHA256 TBD
ARG BASE_DIR=/base_module
ARG PROJECT_DIR=/project
ARG ARCH=x86_64
RUN mkdir ${BASE_DIR}
RUN mkdir ${PROJECT_DIR}

# TOOLS VERSION
ENV CORE_TOOLS_VERSION 3.2.0.1
ENV DBUS_TOOLS_VERSION 3.2.0
ENV SOMEIP_TOOLS_VERSION 3.2.0.1


# ======= Base Requirement =======
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN apt-get update && apt-get install -y \
    python3 python3-pip binutils curl gcc g++ git libboost-all-dev libtool \
    make tar vim libsystemd-dev zlib1g-dev libdbus-glib-1-dev build-essential wget libssl-dev openssl doxygen graphviz asciidoc

RUN python3 -m pip install --upgrade pip
RUN pip3 install scikit-build; pip3 install cmake


# ======= JAVA INSTALL =======
RUN apt-get install -y openjdk-8-jdk openjdk-8-jre; 


# ======= dlt daemon =======
WORKDIR ${BASE_DIR}
RUN git clone https://github.com/GENIVI/dlt-daemon.git; \
cd dlt-daemon; \
mkdir build && cd build; \
cmake ..; \
make; \
make install;


# ======= Build vsomeip =======
WORKDIR ${BASE_DIR}
RUN set -eux; \
curl -o vsomeip.tar.gz -fsSL "https://github.com/GENIVI/vsomeip/archive/${VSOMEIP_VERSION}.tar.gz"; \
tar -xf vsomeip.tar.gz -C ${BASE_DIR}; \
rm vsomeip.tar.gz; \
mv ${BASE_DIR}/vsomeip-${VSOMEIP_VERSION} ${BASE_DIR}/vsomeip; \
cd ${BASE_DIR}/vsomeip; \
mkdir build && cd build; \
cmake ..; \
make;


# ======= Build Common API C++ Runtime =======
WORKDIR ${BASE_DIR}
RUN git clone https://github.com/COVESA/capicxx-core-runtime.git; \
cd capicxx-core-runtime; \
mkdir build && cd build; \
cmake ..; \
make;


# ======= Build SOMEIP CommonAPI =======
WORKDIR ${BASE_DIR}
RUN git clone https://github.com/COVESA/capicxx-someip-runtime.git; \
cd capicxx-someip-runtime; \
mkdir build && cd build; \
cmake -DUSE_INSTALLED_COMMONAPI=OFF ..; \
make;


# ======= Get Code Generators =======
RUN mkdir ${PROJECT_DIR}/generator
WORKDIR ${PROJECT_DIR}/generator
RUN wget -c https://github.com/GENIVI/capicxx-core-tools/releases/download/${CORE_TOOLS_VERSION}/commonapi_core_generator.zip; \
wget -c https://github.com/GENIVI/capicxx-dbus-tools/releases/download/${DBUS_TOOLS_VERSION}/commonapi_dbus_generator.zip; \
wget -c https://github.com/GENIVI/capicxx-someip-tools/releases/download/${SOMEIP_TOOLS_VERSION}/commonapi_someip_generator.zip

RUN unzip -u commonapi_core_generator.zip -d commonapi_core_generator; \
unzip -u commonapi_dbus_generator.zip -d commonapi_dbus_generator; \
unzip -u commonapi_someip_generator.zip -d commonapi_someip_generator

RUN rm *.zip;
RUN chmod +x ./commonapi_core_generator/commonapi-core-generator-linux-x86_64
RUN chmod +x ./commonapi_dbus_generator/commonapi-dbus-generator-linux-x86_64
RUN chmod +x ./commonapi_someip_generator/commonapi-someip-generator-linux-x86_64


# ======= Generate Example Source code =======

WORKDIR ${PROJECT_DIR}
RUN mkdir fidl
RUN mkdir gen_src

COPY ./example/HelloWorld.fidl ${PROJECT_DIR}/fidl/
COPY ./example/HelloWorld.fdepl ${PROJECT_DIR}/fidl/

RUN ./generator/commonapi_core_generator/commonapi-core-generator-linux-${ARCH} -sk -d ./gen_src/ ./fidl/HelloWorld.fidl
RUN ./generator/commonapi_someip_generator/commonapi-someip-generator-linux-${ARCH} -d ./gen_src/ ./fidl/HelloWorld.fdepl

WORKDIR ${PROJECT_DIR}
RUN mkdir src
COPY ./example/HelloWorldClient.cpp ${PROJECT_DIR}/src/
COPY ./example/HelloWorldService.cpp ${PROJECT_DIR}/src/
COPY ./example/HelloWorldStubImpl.hpp ${PROJECT_DIR}/src/
COPY ./example/HelloWorldStubImpl.cpp ${PROJECT_DIR}/src/

RUN mkdir build 
WORKDIR ${PROJECT_DIR}/build
COPY ./example/CMakeLists.txt ${PROJECT_DIR}
RUN cmake ..
RUN make -j4
ENV LD_LIBRARY_PATH :${BASE_DIR}/vsomeip/build
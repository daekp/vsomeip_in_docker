cmake_minimum_required(VERSION 2.8)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=c++0x")
set(BASE_DIR "/base_module")

include_directories(
    gen_src
    ${BASE_DIR}/capicxx-core-runtime/include
    ${BASE_DIR}/capicxx-someip-runtime/include
    ${BASE_DIR}/vsomeip/interface
)

# CMake needs the policy set to avoid warning about
# how to handle a relative path for linking.
# Then we set link search path relative to the source
# dir (thus reaching the locally built libraries we created)
# - Gunnar
cmake_policy(SET CMP0015 NEW)
link_directories(
    ${BASE_DIR}/capicxx-core-runtime/build
    ${BASE_DIR}/capicxx-someip-runtime/build
    ${BASE_DIR}/vsomeip/build
)

# SOMEIP examples

add_executable(HelloWorldSomeIPClient
	src/HelloWorldClient.cpp
	gen_src/v1/commonapi/HelloWorldSomeIPProxy.cpp
	gen_src/v1/commonapi/HelloWorldSomeIPDeployment.cpp
)
target_link_libraries(HelloWorldSomeIPClient CommonAPI CommonAPI-SomeIP vsomeip3)

add_executable(HelloWorldSomeIPService
	src/HelloWorldService.cpp
	src/HelloWorldStubImpl.cpp
	gen_src/v1/commonapi/HelloWorldSomeIPStubAdapter.cpp
	gen_src/v1/commonapi/HelloWorldSomeIPDeployment.cpp
)
target_link_libraries(HelloWorldSomeIPService CommonAPI CommonAPI-SomeIP vsomeip3)
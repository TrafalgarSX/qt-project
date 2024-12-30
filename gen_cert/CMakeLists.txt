cmake_minimum_required(VERSION 3.20..3.31)
project(gen_cert LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick QuickControls2)
find_package(OpenSSL REQUIRED)

qt_standard_project_setup(REQUIRES 6.5)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

list(APPEND PROJECT_SOURCES 
            ${PROJECT_SOURCE_DIR}/src/main.cpp
            ${PROJECT_SOURCE_DIR}/src/hex_util.cpp
            ${PROJECT_SOURCE_DIR}/src/openssl_util.cpp
            ${PROJECT_SOURCE_DIR}/src/gen_cert.cpp
            ${PROJECT_SOURCE_DIR}/src/file_dialog_helper.cpp
            )

list(
  APPEND
  PROJECT_INCLUDES
  ${PROJECT_SOURCE_DIR}/include
  ${PROJECT_SOURCE_DIR}/src
)

list(APPEND DEFINITIONS $<$<CONFIG:Debug>:QT_QML_DEBUG> )

list(
  APPEND
  LIBS
  Qt6::Core
  Qt6::Gui
  Qt6::Widgets
  Qt6::Qml
  Qt6::Quick
  Qt6::QuickControls2
  OpenSSL::Crypto
)

# list(APPEND EXTRA_COMPILE_FLAGS "-Wno-deprecated-declarations")

qt_add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_INCLUDES})

target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBS})

target_compile_definitions(${PROJECT_NAME} PRIVATE ${DEFINITIONS})

target_compile_options(${PROJECT_NAME} PRIVATE ${EXTRA_COMPILE_FLAGS})

qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    QML_FILES
        ui/gen_cert.qml 
        ui/utils.js
    RESOURCES
        rc/simp.png
        rc/qt-logo.png
)

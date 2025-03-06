cmake_minimum_required(VERSION 3.20..3.31)
project(logviewer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick QuickControls2 DBus)
find_package(OpenSSL REQUIRED)

qt_standard_project_setup(REQUIRES 6.5)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

list(APPEND PROJECT_SOURCES 
            ${PROJECT_SOURCE_DIR}/src/main.cpp
            ${PROJECT_SOURCE_DIR}/src/SettingsManager.h ${PROJECT_SOURCE_DIR}/src/SettingsManager.cpp
            ${PROJECT_SOURCE_DIR}/src/util/utils_screen.h ${PROJECT_SOURCE_DIR}/src/util/utils_screen.cpp
            ${PROJECT_SOURCE_DIR}/src/util/utils_os_windows.h ${PROJECT_SOURCE_DIR}/src/util/utils_os_windows.cpp
            ${PROJECT_SOURCE_DIR}/src/util/utils_os_linux.h ${PROJECT_SOURCE_DIR}/src/util/utils_os_linux.cpp
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
  Qt6::DBus
)

# list(APPEND EXTRA_COMPILE_FLAGS "-Wno-deprecated-declarations")
set(WIN32_FLAG "")
# if (WIN32)
if (0)
    set(WIN32_FLAG "WIN32")
endif()
qt_add_executable(${PROJECT_NAME} ${WIN32_FLAG} ${PROJECT_SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_INCLUDES})

target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBS})

target_compile_definitions(${PROJECT_NAME} PRIVATE ${DEFINITIONS})

target_compile_options(${PROJECT_NAME} PRIVATE ${EXTRA_COMPILE_FLAGS})

set_source_files_properties(ui/Constants.qml PROPERTIES QT_QML_SINGLETON_TYPE true)
set_source_files_properties(ui/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE true)
set_source_files_properties(ui/ThemeEngine.qml PROPERTIES QT_QML_SINGLETON_TYPE true)


qt_add_qml_module(${PROJECT_NAME}
    URI Logviewer
    VERSION 1.0
    QML_FILES
        ui/Main.qml 
        ui/LogDelegate.qml 
        ui/Constants.qml 
        ui/About.qml 
        ui/Theme.qml 
        ui/ThemeEngine.qml 
        ui/controls/ScrollBarThemed.qml 
    SOURCES
        ${PROJECT_SOURCE_DIR}/src/LogModel.h ${PROJECT_SOURCE_DIR}/src/LogModel.cpp
    RESOURCES
        ui/icons/checkbox.svg
        ui/icons/checkbox_blank.svg
        ui/icons/darkmode.svg
        ui/icons/filter.svg
        ui/icons/help.svg
        ui/icons/lightmode.svg
        ui/icons/place.svg
        ui/icons/qtlogo_green.png
        ui/icons/qtlogo_white.png
        ui/icons/rssiview.svg
        ui/icons/satellite_small.png
        ui/icons/satellite1.png
        ui/icons/satellite2.png
        ui/icons/search.svg
        ui/icons/settings.svg
        ui/icons/skyview.svg
        ui/icons/sort.svg
        ui/icons/tableview.svg
)

# NSIS packaging
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
	LIBRARY DESTINATION "${CMAKE_INSTALL_BINDIR}" # dynamic library
	ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" # static library
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

# Install all DLLs in the same directory as logviewer.exe
if (WIN32)
    file(GLOB DLLS "${CMAKE_CURRENT_SOURCE_DIR}/libs/*.dll")
    install(FILES ${DLLS} DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()

if(${Qt6_VERSION} VERSION_LESS "6.5")
    qt_generate_deploy_qml_app_script(
        TARGET ${PROJECT_NAME}
        FILENAME_VARIABLE deploy_script
    )
else()
    qt_generate_deploy_qml_app_script(
        TARGET ${PROJECT_NAME}
        OUTPUT_SCRIPT deploy_script
    )
endif()
install(SCRIPT ${deploy_script})

# Copy Visual Studio runtime libraries
if (MSVC)
    include(InstallRequiredSystemLibraries)
    install(FILES ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION  "${CMAKE_INSTALL_BINDIR}")
endif()

set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VERSION "1.0.0")
set(CPACK_PACKAGE_VENDOR "YourCompany")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A Qt6 QML application for generating certificates")
set(CPACK_PACKAGE_INSTALL_DIRECTORY ${PROJECT_NAME})
set(CPACK_PACKAGE_CONTACT "guoyawen98@gmail.com")

# NSIS specific configuration
set(CPACK_NSIS_DISPLAY_NAME ${PROJECT_NAME})
set(CPACK_NSIS_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_NSIS_MODIFY_PATH ON)
set(CPACK_NSIS_MUI_ICON ${CMAKE_CURRENT_SOURCE_DIR}/rc/qt-logo.ico)
set(CPACK_NSIS_MUI_UNIICON ${CMAKE_CURRENT_SOURCE_DIR}/rc/qt-logo.ico)
set(CPACK_NSIS_INSTALLED_ICON_NAME "${CMAKE_INSTALL_BINDIR}/${PROJECT_NAME}.exe")

# WiX Toolset specific configuration
set(CPACK_WIX_PRODUCT_ICON ${CMAKE_CURRENT_SOURCE_DIR}/rc/qt-logo.ico)
set(CPACK_WIX_LICENSE_RTF ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.rtf)
set(CPACK_WIX_UI_BANNER ${CMAKE_CURRENT_SOURCE_DIR}/rc/qt-logo.png)
set(CPACK_WIX_UI_DIALOG ${CMAKE_CURRENT_SOURCE_DIR}/rc/qt-logo.png)
# set(CPACK_WIX_PATCH_FILE "${PROJECT_SOURCE_DIR}/wix-patch.xml") # set environment variables

# Choose packaging tool
option(USE_NSIS "Use NSIS for packaging" ON)

if(USE_NSIS)
    set(CPACK_GENERATOR "NSIS")
else()
    set(CPACK_GENERATOR "WIX")
endif()

include(CPack)

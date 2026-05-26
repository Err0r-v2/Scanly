cmake_minimum_required(VERSION 3.16)
project(qlinuxfb LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# Standalone build of Qt6 platform plugin "linuxfb" against the reMarkable
# Paper Pro SDK. The SDK's Qt6 ships Core/Gui/FbSupport/InputSupport but
# omits KmsSupport, so we skip the optional DRM/KMS code path.
find_package(Qt6 REQUIRED COMPONENTS Core Gui)
find_package(Qt6 REQUIRED COMPONENTS FbSupportPrivate)
find_package(Qt6 OPTIONAL_COMPONENTS InputSupportPrivate)

qt_add_plugin(QLinuxFbIntegrationPlugin
    PLUGIN_TYPE platforms
    OUTPUT_NAME qlinuxfb
    CLASS_NAME QLinuxFbIntegrationPlugin
)

target_sources(QLinuxFbIntegrationPlugin PRIVATE
    main.cpp
    qlinuxfbintegration.cpp qlinuxfbintegration.h
    qlinuxfbscreen.cpp qlinuxfbscreen.h
)

target_compile_definitions(QLinuxFbIntegrationPlugin PRIVATE QT_NO_FOREACH)

target_link_libraries(QLinuxFbIntegrationPlugin PRIVATE
    Qt6::Core Qt6::CorePrivate
    Qt6::Gui  Qt6::GuiPrivate
    Qt6::FbSupportPrivate
)

if (TARGET Qt6::InputSupportPrivate)
    target_link_libraries(QLinuxFbIntegrationPlugin PRIVATE
        Qt6::InputSupportPrivate)
endif()

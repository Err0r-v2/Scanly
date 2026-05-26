cmake_minimum_required(VERSION 3.16)
project(scanly VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Quick QuickControls2 Network Qml)
find_path(WEBP_INCLUDE_DIR webp/decode.h REQUIRED)
find_library(WEBP_STATIC_LIBRARY NAMES libwebp.a)
if (WEBP_STATIC_LIBRARY)
    set(WEBP_LIBRARY ${WEBP_STATIC_LIBRARY})
else()
    find_library(WEBP_LIBRARY NAMES webp REQUIRED)
endif()

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(scanly
    src/main.cpp
    src/sushiscansource.h
    src/sushiscansource.cpp
    src/weebcentralsource.h
    src/weebcentralsource.cpp
    src/mangasourcerouter.h
    src/mangasourcerouter.cpp
    src/chaptermodel.h
    src/chaptermodel.cpp
    src/searchmodel.h
    src/searchmodel.cpp
    src/imagecache.h
    src/imagecache.cpp
    src/librarystore.h
    src/librarystore.cpp
    src/downloadmanager.h
    src/downloadmanager.cpp
    src/settingsstore.h
    src/settingsstore.cpp
    src/epaperhints.h
    src/epaperhints.cpp
    src/devicestatus.h
    src/devicestatus.cpp
    src/pageimagecache.h
    src/pageimagecache.cpp
    src/mangametasource.h
    src/mangametasource.cpp
    src/webpdecode.h
    src/webpdecode.cpp
)

set_source_files_properties(qml/Theme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(scanly
    URI app.scanly
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/Theme.qml
        qml/LibraryPage.qml
        qml/DiscoverPage.qml
        qml/MangaPage.qml
        qml/ReaderPage.qml
        qml/SettingsPage.qml
        qml/components/Hairline.qml
        qml/components/Wordmark.qml
        qml/components/StatusBar.qml
        qml/components/MangaCover.qml
        qml/components/Sidebar.qml
        qml/components/OnScreenKeyboard.qml
)

target_link_libraries(scanly PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Qml
    ${WEBP_LIBRARY}
)

target_include_directories(scanly PRIVATE ${WEBP_INCLUDE_DIR})

install(TARGETS scanly RUNTIME DESTINATION bin)

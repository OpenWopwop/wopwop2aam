# Install script for directory: /mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/..")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/info" TYPE FILE FILES "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/udunits2lib.info")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/doc/udunits" TYPE FILE FILES "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/udunits2lib.html")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libudunits2.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libudunits2.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libudunits2.so"
         RPATH "\$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/build/lib/libudunits2.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libudunits2.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libudunits2.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libudunits2.so"
         OLD_RPATH "\$ORIGIN/../lib:"
         NEW_RPATH "\$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libudunits2.so")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/udunits2.h"
    "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/converter.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/udunits" TYPE FILE FILES
    "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/udunits2.xml"
    "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/udunits2-accepted.xml"
    "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/udunits2-base.xml"
    "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/udunits2-common.xml"
    "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/udunits2-derived.xml"
    "/mnt/d/Fall 22/Research/comp_check/Computational_pipeline/dependencies/wopwop2aam/dependencies/udunits-2.2.28/lib/udunits2-prefixes.xml"
    )
endif()


message("")

# Find MOAB cmake config file
# Only used to determine the location of the HDF5 with which MOAB was built
set(MOAB_SEARCH_DIRS)
file(GLOB MOAB_SEARCH_DIRS ${MOAB_SEARCH_DIRS} "${MOAB_DIR}/lib*/cmake/MOAB")
string(REPLACE "\n" ";" MOAB_SEARCH_DIRS ${MOAB_SEARCH_DIRS})
find_path(MOAB_CMAKE_CONFIG
  NAMES MOABConfig.cmake
  PATHS ${MOAB_SEARCH_DIRS}
  NO_DEFAULT_PATH
)
if (MOAB_CMAKE_CONFIG)
  set(MOAB_CMAKE_CONFIG ${MOAB_CMAKE_CONFIG}/MOABConfig.cmake)
  message(STATUS "MOAB_CMAKE_CONFIG: ${MOAB_CMAKE_CONFIG}")
else ()
  message(FATAL_ERROR "Could not find MOAB. Set -DMOAB_DIR=<MOAB_DIR> when running cmake or use the $MOAB_DIR environment variable.")
endif ()

# Find HDF5
include(${MOAB_CMAKE_CONFIG})
set(ENV{PATH} "${HDF5_DIR}:$ENV{PATH}")
set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_SHARED_LIBRARY_SUFFIX})
find_package(HDF5 REQUIRED)
set(HDF5_LIBRARIES_SHARED ${HDF5_LIBRARIES})
# CMake doesn't let you find_package(HDF5) twice so we have to do this instead
if (BUILD_STATIC_LIBS)
  string(REPLACE ${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_STATIC_LIBRARY_SUFFIX}
         HDF5_LIBRARIES_STATIC "${HDF5_LIBRARIES_SHARED}")
endif ()
if (NOT BUILD_SHARED_LIBS)
  set(HDF5_LIBRARIES_SHARED)
endif ()
set(HDF5_LIBRARIES)

message(STATUS "HDF5_INCLUDE_DIRS: ${HDF5_INCLUDE_DIRS}")
message(STATUS "HDF5_LIBRARIES_SHARED: ${HDF5_LIBRARIES_SHARED}")
message(STATUS "HDF5_LIBRARIES_STATIC: ${HDF5_LIBRARIES_STATIC}")

include_directories(${HDF5_INCLUDE_DIRS})

# Find MOAB library (shared)
if (BUILD_SHARED_LIBS)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_SHARED_LIBRARY_SUFFIX})
  find_library(MOAB_LIBRARIES_SHARED
    NAMES MOAB
    HINTS ${MOAB_LIBRARY_DIRS}
    NO_DEFAULT_PATH
  )
endif ()

# Find MOAB library (static)
if (BUILD_STATIC_LIBS)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX})
  find_library(MOAB_LIBRARIES_STATIC
    NAMES MOAB
    HINTS ${MOAB_LIBRARY_DIRS}
    NO_DEFAULT_PATH
  )
endif ()

# The variable MOAB_USE_EIGEN determines whether or not libmoab requires
# blas/lapack. If it is YES, then it does not require blas/lapack and those
# libraries do not need to be linked. If it is NO, then it does require them and
# they must be linked.
if (NOT MOAB_USE_EIGEN)
  list(APPEND MOAB_LIBRARIES_SHARED lapack blas gfortran quadmath)
  list(APPEND MOAB_LIBRARIES_STATIC lapack blas gfortran quadmath)
endif ()

message(STATUS "MOAB_INCLUDE_DIRS: ${MOAB_INCLUDE_DIRS}")
message(STATUS "MOAB_LIBRARY_DIRS: ${MOAB_LIBRARY_DIRS}")
message(STATUS "MOAB_LIBRARIES_SHARED: ${MOAB_LIBRARIES_SHARED}")
message(STATUS "MOAB_LIBRARIES_STATIC: ${MOAB_LIBRARIES_STATIC}")

if (MOAB_INCLUDE_DIRS AND (MOAB_LIBRARIES_SHARED OR NOT BUILD_SHARED_LIBS) AND
    (MOAB_LIBRARIES_STATIC OR NOT BUILD_STATIC_LIBS))
  message(STATUS "Found MOAB")
else ()
  message(FATAL_ERROR "Could not find MOAB")
endif ()

include_directories(${MOAB_INCLUDE_DIRS})

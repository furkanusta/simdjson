if(POLICY CMP0097)
  cmake_policy(SET CMP0097 NEW)
endif()

get_cmake_property(cmake_variables VARIABLES)
set(checkperf_variables "")
foreach (_name ${cmake_variables})
  set(_value ${${_name}})
  if (_name MATCHES "SIMDJSON_") # OR _name MATCHES "CMAKE_"
    list(APPEND checkperf_variables "-D${_name}=${_value}")
  endif()
endforeach()

list(REMOVE_ITEM checkperf_variables SIMDJSON_COMPETITION SIMDJSON_GOOGLE_BENCHMARKS)
list(APPEND checkperf_variables -DSIMDJSON_COMPETITION=OFF -DSIMDJSON_GOOGLE_BENCHMARKS=OFF)
include(ExternalProject)
ExternalProject_Add(checkperf-repo
  GIT_REPOSITORY "https://www.github.com/simdjson/simdjson"
  GIT_SHALLOW TRUE
  BUILD_ALWAYS TRUE
  CMAKE_ARGS -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
             -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -G ${CMAKE_GENERATOR}
             ${checkperf_variables}
  GIT_SUBMODULES ""
  BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target parse --config $<CONFIGURATION>
  TEST_COMMAND ""
  TEST_EXCLUDE_FROM_MAIN ON
  INSTALL_COMMAND ""
  )

add_custom_target(checkperf DEPENDS checkperf-repo parse perfdiff)
set(CHECKPERF_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/checkperf-repo-prefix/src/checkperf-repo-build/benchmark)
if (CMAKE_CONFIGURATION_TYPES)
  set(CHECKPERF_PARSE ${CHECKPERF_BUILD_DIR}/$<CONFIGURATION>/parse)
else()
  set(CHECKPERF_PARSE ${CHECKPERF_BUILD_DIR}/parse)
endif()
set(SIMDJSON_CHECKPERF_ARGS ${EXAMPLE_JSON} CACHE STRING "Arguments to pass to parse during checkperf")
add_test(
  NAME checkperf
  COMMAND $<TARGET_FILE:perfdiff> $<TARGET_FILE:parse> ${CHECKPERF_PARSE} -H -t ${SIMDJSON_CHECKPERF_ARGS}
)

set_property(TEST checkperf PROPERTY RUN_SERIAL TRUE)
set_property(TEST checkperf APPEND PROPERTY DEPENDS parse perfdiff checkperf-repo)
set_property(TEST checkperf APPEND PROPERTY LABELS per_implementation)

link_libraries(simdjson simdjson-internal-flags simdjson-windows-headers)

add_executable(json2json json2json.cpp)
add_executable(jsonstats jsonstats.cpp)
add_executable(minify minify.cpp)

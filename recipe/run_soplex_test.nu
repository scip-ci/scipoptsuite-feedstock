# Writing the script in nu is usuful to make it portable between Unix and Windows,
# avoiding duplication.
# It also avoids much of the pitfalls of bash conditional/substitiution...

"cmake_minimum_required(VERSION 3.11)
project(SoplexExample)
find_package(SOPLEX REQUIRED)
# Soplex needs papilo but does not add it
find_package(papilo REQUIRED)
set(CMAKE_CXX_STANDARD 14)
add_executable(example scipoptsuite/soplex/src/example.cpp)
target_link_libraries(example PUBLIC libsoplex papilo)
" | save CMakeLists.txt

let cmake_args = $env.CMAKE_ARGS | split row " " | where { $in != "" }
cmake -G Ninja -B build -D CMAKE_BUILD_TYPE=Release ...$cmake_args

cmake --build build --parallel $env.CPU_COUNT --verbose

./build/example

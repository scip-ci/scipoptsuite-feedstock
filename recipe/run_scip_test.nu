# Writing the script in nu is usuful to make it portable between Unix and Windows,
# avoiding duplication.
# It also avoids much of the pitfalls of bash conditional/substitiution...

let cmake_args = $env.CMAKE_ARGS | split row " " | where { $in != "" }
cmake -G Ninja -B build -S scipoptsuite/scip/examples/Queens ...$cmake_args
cmake --build build --parallel $env.CPU_COUNT

./build/queens 5

scip --version

# Verifies that dependencies are properly linked
scip --version | lines | where { |it| $it =~ '(?i)Ipopt\s+[0-9]+\.[0-9]+\.[0-9]+' }
if $nu.os-info.name != "windows" {
    scip --version | lines | where { |it| $it =~ '(?i)CppAD\s+[0-9]+' }
    scip --version | lines | where { |it| $it =~ '(?i)ZLIB\s+[0-9]+\.[0-9]+\.[0-9]+' }
    scip --version | lines | where { |it| $it =~ '(?i)GMP\s+[0-9]+\.[0-9]+\.[0-9]+' }
    scip --version | lines | where { |it| $it =~ '(?i)nauty\s+[0-9]+\.[0-9]+\.[0-9]+' }
}

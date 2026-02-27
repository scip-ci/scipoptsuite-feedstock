# we need librt
if $env.target_platform starts-with "linux-" {
    $env.LDFLAGS = $"-lrt ($env.LDFLAGS)"
}

if $env.PKG_NAME =~ "papilo" {

    # Two step build, we only add papilo executable dependencies later on to
    # break the circular dependency between papilo and scip.
    if $env.PKG_NAME == "libpapilo" {
        $env.CMAKE_ARGS = $"($env.CMAKE_ARGS) -D PAPILO_NO_BINARIES=ON -D SCIP=OFF"
    } else {
        $env.CMAKE_ARGS = $"($env.CMAKE_ARGS) -D PAPILO_NO_BINARIES=OFF -D SCIP=ON -D HIGHS=ON"
    }

    (cmake -B build/ -S $"($env.SRC_DIR)/scipoptsuite/papilo" -G Ninja
        ...($env.CMAKE_ARGS | split row " " | where { $in != "" })
        -D TBB=ON
        -D TBB_DOWNLOAD=OFF
        -D INSTALL_TBB=OFF
        -D GMP=ON
        -D QUADMATH=ON
        -D LUSOL=ON
        -D SOPLEX=OFF
        -D BUILD_TESTING=OFF)
    cmake --build build/ --parallel $env.CPU_COUNT

    if $env.PKG_NAME == "libpapilo" {
        cmake --install build/ --prefix $env.PREFIX
    } else {
        cmake --install build/ --prefix local/
        mkdir $"($env.PREFIX)/bin/"
        cp local/bin/* $"($env.PREFIX)/bin/"
    }

} else if $env.PKG_NAME == "soplex" {

    (cmake -B build/ -S $"($env.SRC_DIR)/scipoptsuite/soplex" -G Ninja
        ...($env.CMAKE_ARGS | split row " " | where { $in != "" })
        -D ZLIB=ON
        -D GMP=ON
        -D STATIC_GMP=OFF
        -D BOOST=ON
        -D QUADMATH=ON
        -D MPFR=ON
        -D PAPILO=ON
        -D $"PAPILO_DIR=($env.PREFIX)"
        -D BUILD_TESTING=OFF)
    cmake --build build/ --parallel $env.CPU_COUNT
    cmake --install build/ --prefix $env.PREFIX

} else if $env.PKG_NAME == "zimpl" {

    (cmake -B build/ -S $"($env.SRC_DIR)/scipoptsuite/zimpl" -G Ninja
        ...($env.CMAKE_ARGS | split row " " | where { $in != "" })
        -D ZLIB=ON
        -D BUILD_TESTING=OFF)
    cmake --build build/ --parallel $env.CPU_COUNT
    cmake --install build/ --prefix $env.PREFIX

} else if $env.PKG_NAME == "scip" {

    # TODO: other options to investigate are
    # READLINE, AMPL, IPOPT, LAPACK, WORHP, CONOPT,
    # a LPS build matrix including HIGHS
    # a SYM build matrix including Bliss
    (cmake -B build/ -S $"($env.SRC_DIR)/scipoptsuite/scip" -G Ninja
        ...($env.CMAKE_ARGS | split row " " | where { $in != "" })
        -D ZLIB=ON
        -D GMP=ON
        -D STATIC_GMP=OFF
        -D ZIMPL=ON
        -D $"ZIMPL_DIR=($env.PREFIX)"
        -D PAPILO=ON
        -D $"PAPILO_DIR=($env.PREFIX)"
        -D LPS=spx
        -D $"soplex_DIR=($env.PREFIX)"
        -D SYM=snauty
        -D THREADSAFE=ON
        -D LTO=ON
        -D BUILD_TESTING=OFF)
    cmake --build build/ --parallel $env.CPU_COUNT
    cmake --install build/ --prefix $env.PREFIX

} else if $env.PKG_NAME == "gcg" {

    # Default symmetry is snauty, which is vendored by scip.
    # To use it without the monolithic build we need to point it to scip vendored version.
    # TODO: use the conda-forge `nauty` package, but we need to add a FindNauty.cmake.
    $env.CXXFLAGS = $"($env.CXXFLAGS) -isystem (pwd)/scipoptsuite/scip/src/"
    $env.CMAKE_ARGS = $"($env.CMAKE_ARGS) -D SCIPOptSuite_SOURCE_DIR=($env.SRC_DIR)/scipoptsuite"

    # TODO: other options to investigate are
    # OPENMP, GSL, HMETIS and a SYM build matrix
    (cmake -B build/ -S $"($env.SRC_DIR)/scipoptsuite/gcg" -G Ninja
        ...($env.CMAKE_ARGS | split row " " | where { $in != "" })
        -D $"SCIP_DIR=($env.PREFIX)"
        -D $"PAPILO_DIR=($env.PREFIX)"
        -D GMP=ON
        -D STATIC_GMP=OFF
        -D CLIQUER=ON
        -D JANSSON=ON
        -D HIGHS=ON
        -D SYM=snauty
        -D LTO=ON
        -D BUILD_TESTING=OFF)
    cmake --build build/ --parallel $env.CPU_COUNT
    cmake --install build/ --prefix $env.PREFIX

}

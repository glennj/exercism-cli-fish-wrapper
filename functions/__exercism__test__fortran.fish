function __exercism__test__fortran
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track gfortran; or return 1
    __exercism__test__validate_runner $_flag_track cmake; or return 1

    __exercism__has_metadata; or return 1
    mkdir -p build
    cd build
    test -d ./testlib; or cmake -G "Unix Makefiles" ..
    make
    and ctest -V
    cd ..
end

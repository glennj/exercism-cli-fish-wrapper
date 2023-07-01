function __exercism__test__fortran
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track gfortran; or return 1
    __exercism__test__validate_runner $_flag_track cmake; or return 1

    set cwd $PWD
    if __exercism__has_metadata >/dev/null
        mkdir -p build; and cd build
        test -d ./testlib; or cmake -G "Unix Makefiles" ..
    end
    if string match -q '*/build' $PWD
        make
        and ctest -V
    end
    cd $cwd
end

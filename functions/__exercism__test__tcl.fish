function __exercism__test__tcl
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track tclsh; or return 1

    set verbosity "configure -verbose {body error usec}"
    for tst in *.test
        if not grep -q $verbosity $tst
            gawk -i inplace -v conf="$verbosity" '
                {print}
                /^[[:blank:]]*source .*\.tcl/ && !p {
                    print conf
                    p = 1
                }
            ' $tst
            echo "added test verbosity"
        end
        __echo_and_execute RUN_ALL=1 tclsh $tst
    end
end

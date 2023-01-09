function __exercism__test__tcl
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

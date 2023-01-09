function __exercism__test__perl5
    argparse t/track= -- $argv
    __exercism__test__validate_runner $_flag_t prove; or return 1

    if test -f cpanfile
        carton install
        carton exec prove .
    else
        prove .
    end
end

function __exercism__test__perl5
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track prove; or return 1

    if test -f cpanfile
        carton install
        carton exec prove .
    else
        prove .
    end
end

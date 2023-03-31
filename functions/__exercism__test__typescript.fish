function __exercism__test__typescript
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__javascript --track=$_flag_track $argv
end

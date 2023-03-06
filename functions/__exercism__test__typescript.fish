function __exercism__test__typescript
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__javascript --track=$_flag_track $argv
end

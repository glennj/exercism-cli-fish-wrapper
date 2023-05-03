function __exercism__test__typescript
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    pnpm install yarn
    fish_add_path -g ./node_modules/.bin
    __exercism__test__validate_runner $_flag_track yarn; or return 1
    __exercism__test__javascript --track=$_flag_track $argv
end

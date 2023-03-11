function __exercism__test__crystal
    argparse t/track= -- $argv
    __exercism__test__validate_runner $_flag_t crystal; or return 3

    jq -r '.files.test[]' .exercism/config.json \
    | xargs perl -i -pe 's/\bpending\b/it/'

    echo crystal spec
    crystal spec
end

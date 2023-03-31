function __exercism__test__fsharp
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track dotnet; or return 3

    jq -r '.files.test[]' .exercism/config.json \
    | xargs perl -i -pe 's/\(Skip = .*?\)//'

    __echo_and_execute dotnet test
end

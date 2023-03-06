function __exercism__test__fsharp
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_t dotnet; or return 3

    jq -r '.files.test[]' .exercism/config.json \
    | xargs perl -i -pe 's/\(Skip = .*?\)//'

    __echo_and_execute dotnet test
end

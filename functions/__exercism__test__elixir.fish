function __exercism__test__elixir
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_track mix ; or return 1
    __echo_and_execute mix test --exclude slow --include pending
end

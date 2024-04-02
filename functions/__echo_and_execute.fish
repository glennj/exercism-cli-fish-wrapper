function __echo_and_execute
    string join -- " " (string escape -- $argv)
    # env $argv
    # not using `env` allows the "tool" to be a shell function
    $argv
end

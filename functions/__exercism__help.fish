# Show some help for the wrapper, then show command exercism help

function __exercism__help
    printf '%s\n' \
        '---------------------------------------------------------------------' \
        '  This is a wrapper around the Exercism command.' \
        '' \
        '  The list of commands can be found at:' \
        '      https://github.com/glennj/exercism-cli-fish-wrapper#subcommands' \
        '---------------------------------------------------------------------'
    command exercism help
end

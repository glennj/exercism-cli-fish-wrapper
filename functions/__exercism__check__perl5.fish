function __exercism__check__perl5
    argparse --ignore-unknown t/track= -- $argv

    set solution (jq -r '.files.solution[]' .exercism/config.json)
    set files (find (dirname $solution[1]) -name \*.pm -print)

    if not type -q perltidy
        echo "perltidy not found: cpanm Perl::Tidy" >&2
    else
        __echo_and_execute perltidy -b -bext='/' $files
    end

    echo
    if not type -q perlcritic
        echo "perlcritic not found: cpanm Perl::Critic" >&2
    else
        __echo_and_execute perlcritic (dirname $solution[1])/
    end
end

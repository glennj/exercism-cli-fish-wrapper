function __exercism__switch_user
    set confdir (
        command exercism configure 2>&1 \
        | sed -En 's/^Config dir:[[:blank:]]+//p'
    )

    argparse --name="exercism switch" 'h/help' 'l/list' -- $argv
    or return 1

    if set -q _flag_list; and not set -q _flag_help
        cd $confdir; or return 1
        ls -l user*.json
        prevd
        return
    end

    if set -q _flag_help; or test (count $argv) -eq 0
        echo "exercism switch [-h|--help] [-l|--list] [user]"
        echo "    switch to a different user-*.json config file"
        return
    end

    cd $confdir; or return 1
    set file "user-"$argv[1]".json"
    set rc 0
    if test -f $file
        ln -fs $file user.json
    else
        echo "error: no such user: $argv[1]"
        set rc 1
    end

    ls -l user*.json
    prevd
    return $rc
end

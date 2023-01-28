function __exercism__refresh
    set help 'Usage: exercism refresh [options]

Re-download the current solution.

Options
    --all   Refresh all track solutions.

This is based on your current directory, since there may be no metadata.'

    argparse --name='exercism refresh' 'h/help' 'all' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    if set -q _flag_all
        __exercism__in_track_root; or return 1
        for dir in */
            cd $dir
            __exercism__refresh
            prevd
        end
        return
    end

    # I use hard links in the bash track
    set -l utils utils*.bash
    test (count $utils) -gt 0; and rm $utils

    set dirs (string split / $PWD)
    echo exercism download --force --track=$dirs[-2] --exercise=$dirs[-1]
    exercism download --force --track=$dirs[-2] --exercise=$dirs[-1]
    or return 1

    if test (count $utils) -gt 0
        rm $utils
        for util in $utils
            ln ../lib/$util
        end
    end
end

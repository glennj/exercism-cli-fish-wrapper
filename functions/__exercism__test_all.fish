
function __exercism__test_all
    set help 'Usage: exercism test-all

Test every downloaded exercise in the track.
Writes a "report" into the track\'s parent directory.'

    argparse --name="exercism test-all" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    __exercism__in_track_root; or return 1
    set root $PWD
    set track (basename $root)

    echo "set a global variable `except` containing the list of directories to skip (use trailing '/')"
    ls
    echo "currently, `except` is:"
    if test (count $except) -eq 0
        echo "empty"
    else
        set -S except
    end
    read -P "hit Enter to proceed; or enter 'q' to abort: " ans
    test $ans = "q"; and return

    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    for e in */
        if contains $e $except
            continue
        end
        begin
            cd $root/$e
            test -d ./.exercism; or exercism refresh
            and exercism sync --update
            and exercism refresh
            and exercism test
        end
        or set errs $errs $e
    end
    cd $root

    echo
    if test (count $errs) -eq 0
        echo "ALL OK!" | tee "../$track.ok."(date +%F)
    else
        echo "these exercises failed:"
        set -S errs | tee "../$track.broken."(date +%F)
    end
end

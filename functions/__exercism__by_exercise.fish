function __exercism__by_exercise
    set help 'Usage: exercism by-exercise

Create a "_by_exercise" directory listing each exercise and
symbolically linking the tracks you\'ve implemented them.'

    argparse --name="exercism by-exercise" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    mkdir -p _by_exercise
    for lang in */
        switch $lang
            case _by_exercise/ users/ _mentor_notes/; continue
        end
        pushd $lang 
        for slug in */
            pushd ../_by_exercise
            mkdir -p $slug
            cd $slug
            set track (string trim -c / $lang)
            test -L $track; or ln -s ../../$lang/$slug $track
            popd
        end
        popd
    end
end

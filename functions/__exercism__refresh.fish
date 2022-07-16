# re-download the current exercise
# - does not rely on presence of .exercism/config.json
# - if you're in the wrong dir, `exercism download` will error

function __exercism__refresh
    # refresh-all:
    #   cd $workspace/$track
    #   for e in */; cd $e; exercism refresh; prevd; end
    #

    # I use hard links in the bash track
    set -l utils utils*.bash
    test (count $utils) -gt 0; and rm $utils

    set dirs (string split / $PWD)
    echo exercism download --track=$dirs[-2] --exercise $dirs[-1]
    exercism download --track=$dirs[-2] --exercise $dirs[-1]
    or return 1

    if test (count $utils) -gt 0
        rm $utils
        for util in $utils
            ln ../lib/$util
        end
    end
end

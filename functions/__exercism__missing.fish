# show all exercises in this track that have not been downloaded

function __exercism__missing
    __exercism__in_track_root; or return 1
    set track (basename $PWD)
    set f (mktemp)
    curl -s -o $f https://raw.githubusercontent.com/exercism/{$track}/main/config.json

    for type in concept practice
        set slugs (
            jq -r '.exercises | .'$type'[] | select(.status != "deprecated") | "\(.slug) \(.status)"' $f \
            | sort \
            | while read slug stat
                if not test -d $slug
                    if test $stat = "null"; or test $stat = "active"
                        echo $slug
                    else
                        echo "$slug  ($stat)"
                    end
                end
            end
        )
        if test (count $slugs) -gt 0
            echo "$type:"
            printf "  %s\n" $slugs
        end
    end

    rm -f $f
end

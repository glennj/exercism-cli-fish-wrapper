# show all exercises in this track that have not been downloaded

function __exercism__missing
    __exercism__in_track_root; or return 1
    set track (basename $PWD)
    curl -s https://raw.githubusercontent.com/exercism/{$track}/main/config.json \
    | jq -r '.exercises.practice[] | .slug' \
    | sort \
    | while read slug
        test -d $slug; or echo $slug
    end
end

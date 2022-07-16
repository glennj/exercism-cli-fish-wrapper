function __exercism__in_track_root
    set workspace (command exercism workspace)
    if not string match --regex -- '^'{$workspace}'/[^/]+$' $PWD >/dev/null
        echo "you should be in a track's root dir" >&2
        return 1
    else
        return 0
    end
end

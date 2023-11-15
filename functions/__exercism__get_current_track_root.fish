function __exercism__get_current_track_root
    # output the full path the root of the current track
    # exit status non-zero if PWD is not under the workspace
    string match --regex "$(command exercism workspace)/[^/]+" $PWD
end

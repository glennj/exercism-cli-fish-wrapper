function __exercism__in_dev_root
    # the root dir of the track repo
    # check the existance of required files
    set rc 0
    if  begin
               not test -f ./config.json
            or not test -d ./docs
            or not test -d ./exercises
        end
            set rc 1
    end
    test $rc -eq 0; or echo "you should be in the repo root dir" >&2
    return $rc
end

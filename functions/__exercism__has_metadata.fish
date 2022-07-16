function __exercism__has_metadata
    if not test -f .exercism/metadata.json
        echo 'not in a an exercise dir or no exercism metadata'
        echo 'try `exercism refresh`'
        return 1
    else
        return 0
    end
end

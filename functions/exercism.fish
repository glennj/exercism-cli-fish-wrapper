function exercism
    switch $argv[1]
        case download
            __exercism__download $argv[2..]
        case submit
            __exercism__submit $argv[2..]
        case missing
            __exercism__missing
        case refresh
            __exercism__refresh
        case publish
            __exercism__publish
        case enable_comments
            __exercism__enable_comments
        case metadata
            __exercism__metadata
        case sync
            __exercism__sync
        case sync-status
            __exercism__sync_status
        case iterations open
            __exercism__open
        case mentoring-queue
            __exercism__mentoring_queue
        case test-all
            __exercism__test_all
        case cleanup
            __exercism__cleanup
        case '*'
            command exercism $argv
    end
end

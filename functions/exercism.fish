function exercism
    switch $argv[1]
        case download
            __exercism__download $argv
        case missing
            __exercism__missing $argv
        case submit
            __exercism__submit $argv
        case refresh
            __exercism__refresh $argv
        case publish
            __exercism__publish $argv
        case enable_comments
            __exercism__enable_comments $argv
        case metadata
            __exercism__metadata $argv
        case sync-status
            __exercism__sync_status $argv
        case iterations open
            __exercism__open $argv
        case sync
            __exercism__sync $argv
        case mentoring-queue
            __exercism__mentoring_queue $argv
        case test-all
            __exercism__test_all $argv
        case cleanup
            __exercism__cleanup $argv
        case '*'
            command exercism $argv
    end
end

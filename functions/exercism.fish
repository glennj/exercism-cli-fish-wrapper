function exercism
    switch $argv[1]
        case cleanup;         __exercism__cleanup
        case download;        __exercism__download $argv[2..]
        case enable_comments; __exercism__enable_comments
        case iterations;      __exercism__iterations $argv[2..]
        case metadata;        __exercism__metadata $argv[2..]
        case missing;         __exercism__missing
        case open;            __exercism__open
        case publish;         __exercism__publish $argv[2..]
        case refresh;         __exercism__refresh $argv[2..]
        case submit;          __exercism__submit $argv[2..]
        case sync;            __exercism__sync $argv[2..]
        case test-all;        __exercism__test_all
        case mentoring
            switch $argv[2]
                case queue;   __exercism__mentoring_queue $argv[3..]
                case inbox;   __exercism__mentoring_inbox $argv[3..]
                case '*'
                    echo 'exercism mentoring [queue|inbox]' >&2
                    return 1
            end
        case '*';             command exercism $argv
    end
end

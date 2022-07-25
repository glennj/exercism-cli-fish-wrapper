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
        case 'switch';        __exercism__switch_user $argv[2..]
        case sync;            __exercism__sync $argv[2..]
        case test-all;        __exercism__test_all
        case test-run;        __exercism__test_run
        case mentoring
            switch $argv[2]
                case queue;   __exercism__mentoring_queue $argv[3..]
                case inbox;   __exercism__mentoring_inbox $argv[3..]
                case discussion
                    __exercism__mentoring_discussion $argv[3..]
                case overview
                    __exercism__mentoring_inbox
                    __exercism__mentoring_queue
                case '*'
                    echo 'unknown subcommand' >&2
                    return 1
            end
        case '*'
            command exercism $argv
    end
end

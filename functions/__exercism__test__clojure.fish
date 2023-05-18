function __exercism__test__clojure
    argparse --ignore-unknown t/track= h/help -- $argv
    set -q _flag_help; and return
    __exercism__test__validate_runner $_flag_t clj; or return 3
    __echo_and_execute clj -X:test
end

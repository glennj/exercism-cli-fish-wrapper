function __exercism__test__common_lisp
    argparse t/track= -- $argv
    __exercism__test__validate_runner $_flag_track sbcl; or return 1
    set slug $argv[1]
    __echo_and_execute \
        sbcl --load "$slug-test" \
             --eval "(exit :code (if ($slug-test:run-tests) 0 5))"
end

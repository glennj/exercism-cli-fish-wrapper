function __exercism__test__common_lisp -a slug
    sbcl --load "$slug-test" \
         --eval "(let () ($slug-test:run-tests) (exit))"
end

function __exercism__test__common_lisp -a slug
    sbcl --load "$slug-test" \
         --eval "(exit :code (if ($slug-test:run-tests) 0 5))"
end

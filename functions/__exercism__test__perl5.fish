function __exercism__test__perl5
    if test -f cpanfile
        carton install
        carton exec prove .
    else
        prove .
    end
end

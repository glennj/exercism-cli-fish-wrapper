function __exercism__prompt_yn --argument msg
    set -lx _msg $msg
    function __prompt__
        set_color --bold white
        printf "\n%s [y/N]? " $_msg
        set_color normal
    end
    read -p __prompt__ response
    functions -e __prompt__
    if test -n $response
        echo $response
    else
        return 1
    end
end

function __exercism__prompt_yn --argument msg
    set prompt (
        set_color --bold white
        printf "\n%s [y/N]? " $msg
        set_color normal
    )
    if read -p "printf '%s' $prompt" response
        echo $response
    else
        return 1
    end
end

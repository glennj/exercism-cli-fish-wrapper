# wraps the `exercism download` command
# - change the current directory
# - perform any track-specific tasks

function __exercism__download
    set out (command exercism download $argv); or return 1
    printf "%s\n" $out
    cd $out[-1]
    switch $PWD
        case '*/users/*'
            # to avoid executing track-specific blocks
            true
        case '*/nim/*'
            set dir (basename $PWD)
            set slug (string replace --all -- '-' '_' $dir)
            printf "%s\n" {,test_}$slug > .gitignore
        case '*/'{java,type}'script/*'
            #npm install
            #pnpm install
    end
end

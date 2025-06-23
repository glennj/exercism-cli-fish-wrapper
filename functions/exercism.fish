# NOTE: when adding a new subcommand,
#       don't forget to update __exercism__help and the README

function exercism
    switch $argv[1]
        case    achievements \
                bulk-download  bulk_download \
                by-exercise \
                check  format \
                cleanup \
                dev \
                download \
                enable-comments  enable_comments \
                exercises \
                github \
                help \
                iterations \
                last-test-run \
                mentoring \
                metadata \
                missing \
                notifications \
                open \
                publish \
                refresh \
                reputation \
                square1 \
                submit \
                switch-user \
                syllabus \
                sync \
                test \
                test-all  test_all \
                tracks
            set func "__exercism__"(string replace --all -- - _ $argv[1])
            $func $argv[2..]
        case '*'
            command exercism $argv
    end
end

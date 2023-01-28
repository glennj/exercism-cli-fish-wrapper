function exercism
    switch $argv[1]
        case  cleanup dev download enable-comments \
              help iterations last-test-run mentoring \
              metadata missing open publish \
              refresh submit switch sync \
              test test-all tracks
            set func "__exercism__"(string replace --all -- - _ $argv[1])
            $func $argv[2..]
        case '*'
            command exercism $argv
    end
end

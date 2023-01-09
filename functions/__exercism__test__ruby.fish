function __exercism__test__ruby
    argparse t/track= -- $argv
    __exercism__test__validate_runner $_flag_track ruby; or return 1

    for t in *_test.rb
        gawk -i inplace '1; /< Minitest::Test/ {print "  def skip; end"}' $t
        __echo_and_execute ruby $t
    end
end

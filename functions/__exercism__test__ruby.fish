function __exercism__test__ruby
    for t in *_test.rb
        gawk -i inplace '1; /< Minitest::Test/ {print "  def skip; end"}' $t
        ruby $t
    end
end

function __exercism__dev_prob_specs_cache
    set -q XDG_CACHE_HOME
    and set cache_dir $XDG_CACHE_HOME
    or  set cache_dir $HOME/.cache

    set prob_specs_dir $cache_dir/exercism/configlet/problem-specifications
    echo $prob_specs_dir

    # this is taken from `configlet`
    # - not fully implemented in case of unclean working directory
    begin
        if test -d $prob_specs_dir
            pushd $prob_specs_dir
            git checkout main
            and git fetch --quiet
            and git merge --ff-only origin/main
        else
            mkdir -p $prob_specs_dir
            pushd (dirname $prob_specs_dir)
            git clone --depth 1 --single-branch -- https://github.com/exercism/problem-specifications
        end
        popd
    end >/dev/null 2>&1
end

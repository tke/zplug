__zplug::sources::pip::check()
{
    local repo="$1" package cmd

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"

    # Repo's directory is not found and
    # INDEX file is not found
    if [[ ! -d $tags[dir] ]] && [[ ! -f $tags[dir]/INDEX ]]; then
        return 1
    fi

    return 0
}

__zplug::sources::pip::install()
{
    local    repo="$1" package cmd
    local -A tags

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"

    package=${repo:t}
    cmd="command pip install --user"

    (
        __zplug::utils::shell::cd \
            --force \
            "$tags[dir]"

        eval "$cmd ${repo:t}" \
            2> >(__zplug::log::capture::error) \
            1> >(__zplug::log::capture::debug) \
            && eval "command pip show ${repo:t}" >|"$tags[dir]/INDEX"
    )

    return $status
}

__zplug::sources::pip::update()
{
    local repo="$1" package cmd

    package=${repo:t}
    cmd="command pip install --user --upgrade"

    eval "$cmd ${repo:t}" \
            2> >(__zplug::log::capture::error) \
            1> >(__zplug::log::capture::debug)

    return $status
}
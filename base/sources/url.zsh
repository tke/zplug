__zplug::sources::url::check()
{
    local    repo="$1"
    local -A tags

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

__zplug::sources::url::install()
{
    local repo="$1" url

    url="$(
    __zplug::sources::url::get_url \
        "$repo"
    )"

    __zplug::sources::url::get "$repo" "$url"

    return $status
}

__zplug::sources::url::update()
{
    local repo="$1" index url
    local -A tags

    tags[dir]="$(__zplug::core::core::run_interfaces 'dir' "$repo")"

    __zplug::utils::shell::cd \
        "$tags[dir]" || return $_zplug_status[repo_not_found]


    url="$(
    __zplug::sources::url::get_url \
        "$repo"
    )"

    if [[ -d $tags[dir] ]]; then
        # Update
        if [[ -f $tags[dir]/INDEX ]]; then
            index="$(cat "$tags[dir]/INDEX" 2>/dev/null)"
            if [[ "$index" == "$url" ]]; then
                # up-to-date
                return $_zplug_status[up_to_date]
            else
                __zplug::sources::url::install "$repo"
                return $status
            fi
        fi
    else
        return $_zplug_status[repo_not_found]
    fi

    return $_zplug_status[success]
}


__zplug::sources::url::get_url()
{
    local repo="$1"
    local urlvar="ZPLUG_URL_${repo:t:u}"

    echo ${(P)urlvar}
}

__zplug::sources::url::get()
{
    local    repo="$1"
    local    url="$2"
    local    dir header artifact cmd
    local -A tags

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"
    header="${url:h:t}"
    artifact="${url:t}"

    if (( $+commands[curl] )); then
        cmd="command curl -s -L -O"
    elif (( $+commands[wget] )); then
        cmd="command wget"
    fi

    (
    __zplug::utils::shell::cd \
        --force \
        "$tags[dir]"

    # Grab artifact from url
    eval "$cmd $url" \
        &>/dev/null

    case "$artifact" in
        *.zip)
                unzip "$artifact"
                rm -f "$artifact"
            ;;
        *.tar.bz2)
                tar jxvf "$artifact"
                rm -f "$artifact"
            ;;
        *.tar.gz|*.tgz)
                tar xvf "$artifact"
                rm -f "$artifact"
            ;;
        *.*)
            return 1
            ;;
        *)
            # Through
            ;;
    esac &&
        echo "$url" >|"$tags[dir]/INDEX"
    )

    return $status
}

__zplug::sources::url::load_command()
{
    __zplug::sources::github::load_command "$argv[@]"
}

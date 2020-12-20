#!/usr/bin/env bash

#
# Terminal styling
#

style_prompt()
{
    local ACTIVE_BACKGROUND_COLOR=''
    local ACTIVE_FOREGROUND_COLOR=''
    local PREV_BACKGROUND_COLOR=''

    local SECTION_SEPARATOR_MAJOR=$(printf '\xE2\x97\xA4')
    local SECTION_SEPARATOR_MINOR='/'
    local SECTION_SEPARATOR_END=$(printf '\xE2\x97\xA3')

    local OUTPUT=''

    write_color()
    {
        echo -n '\[\033['
        echo -n $1
        echo -n 'm\]'
    }

    get_color_code()
    {
        local COLOR='30'
        case $1 in
            black)
                COLOR='30'
                ;;
            red)
                COLOR='31'
                ;;
            green)
                COLOR='32'
                ;;
            yellow)
                COLOR='33'
                ;;
            blue)
                COLOR='34'
                ;;
            magenta)
                COLOR='35'
                ;;
            cyan)
                COLOR='36'
                ;;
            white)
                COLOR='37'
                ;;
        esac

        echo -n "$COLOR"
    }

    set_foreground_color()
    {
        ACTIVE_FOREGROUND_COLOR=$1
    }

    set_background_color()
    {
        PREV_BACKGROUND_COLOR=$ACTIVE_BACKGROUND_COLOR
        ACTIVE_BACKGROUND_COLOR=$1
    }

    write_foreground_color()
    {
        local COLOR=$(get_color_code $1)

        if [ $# -ne  1 ]; then
            echo -n "$(write_color "$2;$COLOR")"
        else
            echo -n "$(write_color $COLOR)"
        fi
    }

    write_background_color()
    {
        local COLOR=$(get_color_code $1)
        COLOR=$(expr $COLOR + 10)
        echo -n "$(write_color $COLOR)"
    }

    write_out_section()
    {
        if ! [ -z "$ACTIVE_BACKGROUND_COLOR" ]; then
            echo -n $(write_background_color $ACTIVE_BACKGROUND_COLOR)
        fi

        if ! [ -z "$PREV_BACKGROUND_COLOR" ]; then
            if [[ "$PREV_BACKGROUND_COLOR" != "$ACTIVE_BACKGROUND_COLOR" ]]; then
                echo -n $(write_foreground_color $PREV_BACKGROUND_COLOR)
                echo -n $SECTION_SEPARATOR_MAJOR
            else
                echo -n $SECTION_SEPARATOR_MINOR
            fi
        fi

        if ! [ -z "$ACTIVE_FOREGROUND_COLOR" ]; then
            if [ $# -ne 0 ]; then
                echo -n $(write_foreground_color $ACTIVE_FOREGROUND_COLOR $1)
            else
                echo -n $(write_foreground_color $ACTIVE_FOREGROUND_COLOR)
            fi
        fi
    }

    set_host()
    {
        local IS_SSH=0
        if [ -n "$SSH_TTY" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_CONNECTION" ]; then
            IS_SSH=1
        else
            return
        fi

        set_background_color black
        set_foreground_color white
        OUTPUT="$OUTPUT$(write_out_section 1)\H "
    }

    set_user()
    {
        set_background_color black
        set_foreground_color yellow
        OUTPUT="$OUTPUT$(write_out_section 1)"

        if [ "$(whoami)" != "$(logname)" ]; then
            OUTPUT="$OUTPUT $(logname) (as \u) "
        else
            OUTPUT="$OUTPUT \u "
        fi
    }

    set_cwd()
    {
        set_background_color black
        set_foreground_color blue
        OUTPUT="$OUTPUT$(write_out_section 1) \w"
    }

    set_git_data()
    {
        local UNCOMMITED_CHANGE=$(printf '\xC2\xB1')
        local BRANCH_BEHIND_REMOTE=$(printf '\xE2\x86\x93')
        local BRANCH_AHEAD_REMOTE=$(printf '\xE2\x86\x91')
        local SYMBOLS=''

        git --version > /dev/null 2> /dev/null
        if [ $? -ne 0 ]; then
            return
        fi

        local REF=$(git symbolic-ref --short HEAD 2> /dev/null)
        if [ -z "$REF" ]; then
            return
        fi

        local BEHIND_COUNT=$(git rev-list --right-only HEAD...@{u} --count 2> /dev/null)
        local AHEAD_COUNT=$(git rev-list --left-only HEAD...@{u} --count 2> /dev/null)
        if [ -n "$BEHIND_COUNT" ] && [ "$BEHIND_COUNT" -gt 0 ]; then
            SYMBOLS="$SYMBOLS$BRANCH_BEHIND_REMOTE"
        fi

        if [ -n "$AHEAD_COUNT" ] && [ "$AHEAD_COUNT" -gt 0 ]; then
            SYMBOLS="$SYMBOLS$BRANCH_AHEAD_REMOTE"
        fi

        if [ -n "$(git status --porcelain)" ]; then
            SYMBOLS="$SYMBOLS$UNCOMMITED_CHANGE"
        fi

        if [ -n "$SYMBOLS" ]; then
            SYMBOLS="$SYMBOLS"
        fi

        set_background_color green
        set_foreground_color black
        OUTPUT="$OUTPUT$(write_out_section 1)$REF$SYMBOLS"
    }

    ps1()
    {
        # Generate the PS1
        set_host
        set_user
        set_cwd
        set_git_data

        # Set PS1
        echo -n $OUTPUT

        # Finish up with a separator
        echo -n '\[\033[m\]'
        echo -n $(write_foreground_color $ACTIVE_BACKGROUND_COLOR)
        echo -n $SECTION_SEPARATOR_END
        echo -n '\[\033[m\] '
    }

    PS1="$(ps1)"
}

if [ "$TERM" != "linux" ]; then
   PROMPT_COMMAND="style_prompt; $PROMPT_COMMAND"
fi

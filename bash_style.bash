#!/usr/bin/env bash

#
# Terminal styling
#

function style_bash()
{
    local ACTIVE_BACKGROUND_COLOR=''
    local ACTIVE_FOREGROUND_COLOR=''
    local PREV_BACKGROUND_COLOR=''

    local SEPARATOR=$(printf '\u25e4')

    local OUTPUT=""

    function write_color()
    {
        echo -n '\[\033['
        echo -n $1
        echo -n 'm\]'
    }

    function get_color_code()
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

    function set_foreground_color()
    {
        ACTIVE_FOREGROUND_COLOR=$1
    }

    function set_background_color()
    {
        PREV_BACKGROUND_COLOR=$ACTIVE_BACKGROUND_COLOR
        ACTIVE_BACKGROUND_COLOR=$1
    }

    function write_foreground_color()
    {
        local COLOR=$(get_color_code $1)

        if [ $# -ne  1 ]; then
            echo -n "$(write_color "$2;$COLOR")"
        else
            echo -n "$(write_color $COLOR)"
        fi
    }

    function write_background_color()
    {
        local COLOR=$(get_color_code $1)
        COLOR=$(expr $COLOR + 10)
        echo -n "$(write_color $COLOR)"
    }

    function write_out_section()
    {
        if ! [ -z "$ACTIVE_BACKGROUND_COLOR" ]; then
            echo -n $(write_background_color $ACTIVE_BACKGROUND_COLOR)
        fi

        if ! [ -z "$PREV_BACKGROUND_COLOR" ]; then
            echo -n $(write_foreground_color $PREV_BACKGROUND_COLOR)
            echo -n $SEPARATOR
        fi

        if ! [ -z "$ACTIVE_FOREGROUND_COLOR" ]; then
            if [ $# -ne 0 ]; then
                echo -n $(write_foreground_color $ACTIVE_FOREGROUND_COLOR $1)
            else
                echo -n $(write_foreground_color $ACTIVE_FOREGROUND_COLOR)
            fi
        fi
    }

    function set_host()
    {
        local IS_SSH=0
        if [ -n "$SSH_TTY" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_CONNECTION" ]; then
            IS_SSH=1
        else
            return
        fi

        set_background_color white
        set_foreground_color black
        OUTPUT="$OUTPUT$(write_out_section 1)\H"
    }

    function set_user()
    {
        set_background_color green
        set_foreground_color black
        OUTPUT="$OUTPUT$(write_out_section 1)"

        if [ "$(whoami)" != "$(logname)" ]; then
            OUTPUT="$OUTPUT$(logname) (as \u)"
        else
            OUTPUT="$OUTPUT\u"
        fi
    }

    function set_cwd()
    {
        set_background_color blue
        set_foreground_color black
        OUTPUT="$OUTPUT$(write_out_section 1)\w"
    }

    function set_git_data()
    {
        git --version >> /dev/null
        if [ $? -ne 0 ]; then
            return
        fi

        local REF=$(git symbolic-ref --short HEAD 2> /dev/null)
        if [ -z "$REF" ]; then
            return
        fi

        local MODIFIED=$(git status --porcelain)
        if [ -n "$MODIFIED" ]; then
            MODIFIED=' !'
        fi

        set_background_color yellow
        set_foreground_color black
        OUTPUT="$OUTPUT$(write_out_section 1)$REF$MODIFIED"
    }

    function ps1()
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
        echo -n $(printf '\u25e3')
        echo -n '\[\033[m\] '
    }

    PS1="$(ps1)"
}

PROMPT_COMMAND=style_bash

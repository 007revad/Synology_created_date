#!/usr/bin/env bash

scriptver="v1.0.0"
script=Synology_created_date
repo="007revad/Synology_created_date"
scriptname=syno_created_date

# Show script version
echo -e "$script $scriptver\ngithub.com/$repo\n"
#echo -e "$script $scriptver\n"

nas_revision="$(cat /proc/sys/kernel/syno_hw_revision)"
if [[ $nas_revision ]]; then nas_revision=" $nas_revision"; fi

nas_model=$(cat /proc/sys/kernel/syno_hw_version)

nas_serial=$(cat /proc/sys/kernel/syno_serial)

lang=$(synogetkeyvalue "/etc/synoinfo.conf" language)

convert(){ 
    case "$1" in
        0) n=0;;
        1) n=1;;
        2) n=2;;
        3) n=3;;
        4) n=4;;
        5) n=5;;
        6) n=6;;
        7) n=7;;
        8) n=8;;
        9) n=9;;
        A) n=10;;
        B) n=11;;
        C) n=12;;
        D) n=13;;
        E) n=14;;
        F) n=15;;
        G) n=16;;
        H) n=17;;
        I) n=18;;
        J) n=19;;
        *) echo "Invalid arg '$1'";;
    esac
}

get_date(){
    if [[ $2 == "old" ]]; then
        # Old format serial number
        convert "${nas_serial:0:1}"  # Convert 1st character
        year="$n"
        convert "${nas_serial:1:1}"  # Convert 2nd character
    else
        # Current format serial number
        year="${nas_serial:0:2}"     # First 2 characters
        convert "${nas_serial:2:1}"  # Convert 3rd character
    fi
    if [[ $lang ]]; then
        month=$(synogetkeyvalue "/usr/syno/synoman/webman/texts/${lang}/strings" "mon_$n")
    elif [[ ${#n} = 1 ]]; then
        month="0$n"
    else
        month="$n"
    fi
    nas_date="20$year $month"
}

if [[ ${nas_serial:1} =~ [0-9] ]]; then
    # Is current serial number format
    #echo "Is current serial number format: $nas_serial"  # debug ##########
    get_date "$nas_serial" current
elif [[ ${nas_serial:1} =~ [A-V] ]]; then
    # Is old serial number format
    #echo "Is old serial number format: $nas_serial"  # debug ##########
    get_date "$nas_serial" old
else
    echo "Unknown serial number format: $nas_serial"
    exit
fi 

# Show manufactured date
if [[ $lang ]]; then
    made=$(synogetkeyvalue "/usr/syno/synoman/webman/texts/${lang}/strings" version_time)
    echo -e "${nas_model}$nas_revision $nas_serial ${made}: $nas_date"
else
    echo -e "${nas_model}$nas_revision $nas_serial Date Created: $nas_date"
fi

exit


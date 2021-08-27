#!/bin/bash

main() {

    # Choose a language (3 letters) if you don't
    # want to show a dialog to select languages. 
    # The language has to be supported by Tesseract.
    #
    #LANGUAGE="eng"

    FILES="$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"

    check_dependencies

    check_files "$FILES"

    if [ "${LANGUAGE}none" = "none" ]; then
        LANGUAGE=$(choose_language)
    fi

    ocr_files "$FILES" $LANGUAGE
}

choose_language() {

	ACCEPTED_LANGUAGES=($(tesseract --list-langs | tail -n +2))

	NUM_LANGUAGES=${#ACCEPTED_LANGUAGES[@]}

	ENABLED_LANGUAGES=($(for ((i=0;i<$NUM_LANGUAGES;i+=1)); do [[ $i -eq 0 ]] && echo TRUE || echo FALSE ; done))

	LANGUAGE_COLUMNS=$(for ((i=0;i<$NUM_LANGUAGES;i+=1)); do echo ${ENABLED_LANGUAGES[$i]} ${ACCEPTED_LANGUAGES[$i]}; done)

	LANGUAGE=$(zenity --width 300 --height 250  --title="Choose the language of the PDFs" --list --radiolist   --column=""  --column="Language" $LANGUAGE_COLUMNS)

	echo $LANGUAGE
}

check_dependencies() {

    ZENITY_VERSION=$(type zenity &> /dev/null && zenity --version | tr -d '\n')
    TESSERACT_VERSION=$(type tesseract &> /dev/null && tesseract --version | head -1 |  cut -d' ' -f2 | tr -d '\n')
    TESSERACT_OSD_DATA=$(get_tesseract_osd_data_path)
    OCRMYPDF_VERSION=$(type ocrmypdf &> /dev/null && ocrmypdf --version | tr -d '\n')

    if [[ "${ZENITY_VERSION}none" = "none" ]]; then
        echo "Zenity not installed." > /dev/stderr
    fi

    if [ "${TESSERACT_VERSION}none" = "none" ] || [ "${OCRMYPDF_VERSION}none" = "none" ] || [ ! -f $TESSERACT_OSD_DATA ]; then
        zenity --error --width 300 --text="Some dependencies were not found.\n\nZenity: ${ZENITY_VERSION}\n\nTesseract: ${TESSERACT_VERSION}\n\nTesseract OSD Data: $(if [ -f $TESSERACT_OSD_DATA ]; then echo "found"; else "not found"; fi)\n\nOcrmypdf: ${OCRMYPDF_VERSION}"

        exit 1
    fi
}

get_tesseract_osd_data_path() {

    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=debian
        VER=$(cat /etc/debian_version)
    else
        zenity --error --width 300 --text="Could not find Tesseract OSD package (unknown distribution)"
        exit 1
    fi


    if [[ "${OS}" =~ ^[Ff]edora$ ]]; then
        rpm -ql tesseract-osd |  grep traineddata
    elif [[ "${OS}" =~ ^[Uu]buntu$ ]]; then
        dpkg -L tesseract-ocr-osd | grep traineddata
    elif [[ "${OS}" =~ ^[Dd]ebian$ ]]; then
        dpkg -L tesseract-ocr-osd | grep traineddata
    else
        zenity --error --width 300 --text="Operating system '${OS}' not supported yet."
        exit 1
    fi

}

check_files() {

    FILES="$1"

    echo "$FILES" | while read FILE; do

	if [ -n "$FILE" ]; then 
            # zenity --width=640 --error --text="File $FILE."

            FILETYPE=$(file "$FILE")
            
            echo "$FILETYPE" | grep PDF &> /dev/null

            if [[ $? != 0 ]]; then 
                zenity --width=640 --error --text="File $FILE is not a pdf:\n$FILETYPE" && exit 1
                if [ "$?" -eq 1 ]; then
                    exit
                fi
            fi

        fi
    done
}

ocr_files() {

    FILES="$1"
    LANGUAGE=$2

    if [[ "${LANGUAGE}none" != "none" ]]; then

        NUM_FILES=$(echo "$FILES" | wc -l)
        NUM_FILES=$(($NUM_FILES - 1))

        (
            i=0 

            echo "$FILES" | while read FILE; do

                if [ -n "$FILE" ]; then 
                    PERCENTAGE=$(bc -l <<< "($i/$NUM_FILES)*100")

                    echo "# Processing " $(basename "$FILE") "($((i+1))/$NUM_FILES)"
                    echo "${PERCENTAGE%.*}"

                    i=$(($i+1))

                    OUTPUT=$(ocr_file "$FILE" $LANGUAGE)
           
                    if [ $? -ne 0 ]; then
                        zenity --width 500 --error --text="$OUTPUT"
                    fi
                fi
            done

            echo "# Finished processing $NUM_FILES file(s)."
        ) |
        zenity --progress \
          --title="OCR'ing $NUM_FILES file(s)..." \
          --text="Starting..." \
          --percentage=0
          --auto-close

        if [ "$?" -eq 1 ]; then
            exit
        fi

    else
        exit 1
    fi
}

ocr_file() {
    FILE="$1"
    LANGUAGE="$2"
    FILE_NO_EXTENSION=$(basename "${FILE%.*}")

    ocrmypdf -l "$LANGUAGE" "$FILE" "${FILE_NO_EXTENSION}_ocr.pdf" 2>&1
}

main

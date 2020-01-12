#!/bin/bash

main() {

    # Choose a language (3 letters) if you don't
    # want to show a dialog to select languages., 
    # The language has to be supported by Tesseract.
    #
    #LANGUAGE="eng"

	FILES=($NAUTILUS_SCRIPT_SELECTED_FILE_PATHS)

    check_dependencies

    check_files $FILES

    if [ "${LANGUAGE}none" = "none" ]; then
        LANGUAGE=$(choose_language)
    fi

    ocr_files $FILES $LANGUAGE
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
    TESSERACT_OSD_DATA=/usr/share/tesseract/tessdata/osd.traineddata
    OCRMYPDF_VERSION=$(type ocrmypdf &> /dev/null && ocrmypdf --version | tr -d '\n')

    if [[ "${ZENITY_VERSION}none" = "none" ]]; then
        echo "Zenity not installed." > /dev/stderr
    fi

    if [ "${TESSERACT_VERSION}none" = "none" ] || [ "${OCRMYPDF_VERSION}none" = "none" ] || [ ! -f $TESSERACT_OSD_DATA ]; then
        zenity --error --width 300 --text="Some dependencies were not found.\n\nZenity: ${ZENITY_VERSION}\n\nTesseract: ${TESSERACT_VERSION}\n\nTesseract OSD Data: $(if [ -f $TESSERACT_OSD_DATA ]; then echo "found"; else "not found"; fi)\n\nOcrmypdf: ${OCRMYPDF_VERSION}"

        exit 1
    fi
}

check_files() {

    FILES=$1

	for filename in ${FILES[@]}; do

        file "$filename" | grep PDF &> /dev/null

        if [[ $? != 0 ]]; then 
            zenity --width=640 --error --text="File $filename is not a pdf: $(file "$filename")" && exit 1
            if [ "$?" -eq 1 ]; then
                exit
            fi
        fi

    done
}

ocr_files() {

    FILES=$1
    LANGUAGE=$2

    if [[ "${LANGUAGE}none" != "none" ]]; then

        FILES=($NAUTILUS_SCRIPT_SELECTED_FILE_PATHS)
        NUM_FILES=${#FILES[@]}

        (
            i=0

            for filename in ${FILES[@]}; do

                percentage=$(bc -l <<< "($i/$NUM_FILES)*100")

                echo "# Processing '$(basename $filename)' ($((i+1))/$NUM_FILES)"
                echo "${percentage%.*}"

                i=$(($i+1))

                OUTPUT=$(ocr_file $filename $LANGUAGE)
               
                if [ $? -ne 0 ]; then
                    zenity --width 500 --error --text="$OUTPUT"
                fi
                
            done

            echo "# Finished processing $NUM_FILES file(s)."
        ) |
        zenity --progress \
          # --auto-close \
          --title="OCR'ing $NUM_FILES file(s)..." \
          --text="Starting..." \
          --percentage=0

        if [ "$?" -eq 1 ]; then
            exit
        fi

    else
        exit 1
    fi
}

ocr_file() {
    FILE=$1
    LANGUAGE=$2

    ocrmypdf --redo-ocr -l "$LANGUAGE" "$FILE" "$(basename ${FILE%.*})_ocr.pdf" 2>&1
}

main

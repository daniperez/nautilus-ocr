# nautilus-ocr

`nautilus-ocr` is a [Nautilus script](https://help.ubuntu.com/community/NautilusScriptsHowto)
that scans pdfs and adds OCR information to them. This is useful if you scanned documents
and want to make them searcheable or copy-paste content from them.

<img src="https://raw.githubusercontent.com/daniperez/nautilus-ocr/master/img/right-click.png" alt="nautilus-ocr right-click" width="500">


# Requirements

- **Zenity**: UI dialogs
- **OCRMyPDF**: OCR
- **Tesseract**: OCR (low-level)

For Tesseract you need also the OSD data.

You can install all the dependencies in Fedora as follows:

```bash
$ dnf install tesseract tesseract-osd ocrmypdf zenity
```

Similar packages might exist for your distribution of choice.

You might also want to add training data for other languages. In Fedora
you can install, for example, French language as follows:

```bash
$ dnf install tesseract-langpack-fra
```

# Installation

*(Click to see screencast)*
[![Installation](https://raw.githubusercontent.com/daniperez/nautilus-ocr/master/img/nautilus-ocr-installation-poster.png)](https://raw.githubusercontent.com/daniperez/nautilus-ocr/master/img/nautilus-ocr-installation.webm)

Download `nautilus-ocr.sh` and move it to the Nautilus Scripts
folder. Remember to add the execution permission. If you downloaded 
the script to `~/Downloads` folder:

```bash
$ chmod +x ~/Downloads/nautilus-ocr.sh
$ mv ~/Downloads/nautilus-ocr.sh "~/.local/share/nautilus/scripts/Create OCR'ed PDF"
```

Once the script is in place, you can righ-click on any file in Nautilus.

It will create a pdf file with the `_ocr` suffix. That file will contain OCR information. If you 
can select text in that file, it means the OCR worked.

# Configuration

## Language
By default a dialog will ask you which language to use for the OCR. If you 
want to use always the same language, edit `nautilus-ocr.sh` and set
the language at [the top of the file](https://github.com/daniperez/nautilus-ocr/blob/4edfe62928b7588fc79e0c159b886991f5347779/nautilus-ocr.sh#L9).

## Close on finish
A dialog will be showed after OCR'ing the files, stating that the process 
has finished. If you want to close the dialog automatically, just [uncomment the option `--auto-close`](https://github.com/daniperez/nautilus-ocr/blob/bdcf6579b98d48db05873b58d5d8e225cd453f3f/nautilus-ocr.sh#L108).

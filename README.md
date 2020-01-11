# nautilus-ocr

`nautilus-ocr` is a [Nautilus script](https://help.ubuntu.com/community/NautilusScriptsHowto)
that scans PDFs and adds OCR information to them. This is useful if you scanned documents
and want to make them searcheable or copy-paste content from them.

# Requirements

- **Zenity**: UI dialogs
- **OCRMyPDF**: OCR
- **Tesseract**: OCR (low-level)

For Tesseract you need also the OSD data.

You can install all the dependencies in Fedora as follows:

```bash
$ dnf install tesseract tesseract-osd ocrmypdf zenity
```

You might also want to add training data for other languages. In Fedora
you can install, for example, French language as follows:

```bash
$ dnf install tesseract-langpack-fra
```

# Installation

Download the script in this repository and move it to the Nautilus Scripts
folder. If you downloaded the script to `~/Downloads` folder:

```bash
$ chmod +x ~/Downloads/nautilus-ocr.sh
$ mv ~/Downloads/nautilus-ocr.sh "~/.local/share/nautilus/scripts/Create OCR'ed PDF"

Once the script is in place, you can righ-click on any file in Nautilus:

![Nautilus, right-click](https://raw.githubusercontent.com/daniperez/nautilus-ocr/master/img/right-click.png)

It will create a file with the `_ocr` suffix. That file will contain OCR information. If you 
can select text in that file, it means the OCR worked.

# Configuration

By default a dialog will ask you which language to use for the OCR. If you 
want to use always the same language, edit `nautilus-ocr.sh` and set
the language at the top of the file.

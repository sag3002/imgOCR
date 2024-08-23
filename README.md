# About the Project
- This is a powershell script to allow searching for images based on their OCR.
- OCR is performed on all the unprocessed images in user defined folder recursively and the resultant text is saved in one of the fields of their metadata. Voidtools Everything is then used to search for images based on the content of this saved metadata field.
# Prerequisites
Following tools are needed for windows environment:
- Voidtools Everything: for searching for images
- tesseract: for OCR
# Usage
- Download and install everything 1.5a and es cli. Add the es.exe to PATH in environment variables
- change searchPath in the powershell script and other parameters as required
- Open a powershell window, cd to project's folder and run ``` $ ./5.ps1 ```

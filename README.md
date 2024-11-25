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
# To Do
- Embedded Images: Extract embedded images in ~pdf(using Apache PDFBox)~ done and .docx/pptx(extracting as zip, images in word/media), store combined OCR in metadata.
  other extensions: pages, epub, mobi, mhtml
- parallalize things to make it faster
- I don't know how to do this yet:
  - support other image formats: exif tools is only supporting jpeg and png (and is slow), currently taglib is being used for png as it extremely faster than exif but it also doesn't support other extensions in my limited expreimentation.
  - use interrupts instead of polling for new images. Figure out how to use everything or mft table directly to know if new images are available?

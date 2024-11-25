# Define paths
$searchPath = "C:\Users\sid\Desktop"
$tempFolderPath = Join-Path (Get-Location) "temp"
$pdfBoxJarPath = ".\pdfbox.jar"
$ocrScriptPath = "C:\Users\sid\Desktop\ocr\ocr1.ps1"

# Ensure the temp folder exists
if (-not (Test-Path $tempFolderPath)) {
    New-Item -ItemType Directory -Path $tempFolderPath | Out-Null
}

# Search for PDF files using Everything Search (es.exe)
$pdfFiles = es -path $searchPath ext:pdf size:<10mb size:>3kb !title: !C:\Users\sid\Desktop\ocrp\t1

# Function to clean OCR text
function Clean-OCRText {
    param (
        [string]$text
    )
    # Remove non-ASCII characters
    $text = $text -replace '[^\x20-\x7E]', ''

    # Replace multiple spaces/newlines with a single space
    $text = $text -replace '\s+', ' '
$text = $text -replace '[\\&"*^#$''/]', ''

    # Trim leading/trailing spaces
    return $text.Trim()
}


# Function to shorten text if too long
function Shorten-Text {
    param (
        [string]$text,
        [int]$maxLength = 64000
    )

    # Remove duplicate strings
    $text = ($text -split '\s+') | Select-Object -Unique | Out-String

    # If text is still too long, remove special characters
    if ($text.Length -gt $maxLength) {
        $text = $text -replace '[^\w\s]', '' # Remove all non-alphanumeric characters
    }

    # If text is still too long, remove numbers
    if ($text.Length -gt $maxLength) {
        $text = $text -replace '\d', '' # Remove all digits
    }

    return $text.Trim()
}


# Process each PDF file
foreach ($pdfFile in $pdfFiles) {
    # Generate a unique name for the PDF in the temp folder
    $uniquePdfName = (Get-Date -Format "yyyyMMddHHmmss") + "_" + (Get-Random -Maximum 9999) + "_" + (Split-Path $pdfFile -Leaf)
    $tempPdfPath = Join-Path $tempFolderPath $uniquePdfName
    Copy-Item -Path $pdfFile -Destination $tempPdfPath -Force

    # Extract images from the PDF using PDFBox
    $pdfFileName = [System.IO.Path]::GetFileNameWithoutExtension($tempPdfPath)
    $pdfBoxCommand = "java -jar `"$pdfBoxJarPath`" export:images -i `"$tempPdfPath`""
    Invoke-Expression $pdfBoxCommand

    # Perform OCR on extracted images
    $imageFiles = Get-ChildItem -Path $tempFolderPath -Filter "$pdfFileName-*.*" | Where-Object { $_.Extension -match '\.jpg|\.png' }
    $concatenatedOcr = ""

    foreach ($imageFile in $imageFiles) {
        # Run OCR script and collect the text
        $ocrResult = &$ocrScriptPath -Path $imageFile.FullName
        $ocrText = $ocrResult.Text.Trim()
        $concatenatedOcr += "$ocrText`n"
    }

    # Clean the concatenated OCR text
    $concatenatedOcr = Clean-OCRText -text $concatenatedOcr

# Check and shorten if the text exceeds 64,000 characters
if ($concatenatedOcr.Length -gt 64000) {
    $concatenatedOcr = Shorten-Text -text $concatenatedOcr
}

    # Update the PDF title using exiftool
    if (-not [string]::IsNullOrWhiteSpace($concatenatedOcr)) {
        $exiftoolCommand = "exiftool -Title=`"$concatenatedOcr`" -overwrite_original -fast -n -m -L `"$pdfFile`""
    } else {
        $exiftoolCommand = "exiftool -Title=`"NoTextFound`" -overwrite_original -fast -n -m -L `"$pdfFile`""
    }

    Invoke-Expression $exiftoolCommand

    # Output the OCR text for reference
    echo "Processed PDF: $pdfFile"
    echo "Title set to: $concatenatedOcr"
}

# Script complete
echo "All files processed. Temporary files are in: $tempFolderPath"

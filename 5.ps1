# Define the path to your OCR script
$ocrScriptPath = "C:\Users\sid\Desktop\ocr\ocr1.ps1"

# Define the path to the TagLib DLL
$tagLibPath = "C:\Users\sid\Desktop\ocr\taglib\Libraries\taglib-sharp.dll"

# Search path for Everything to look for titleless images
$searchPath = "C:\Users\sid\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\LocalState\shared\transfers"

# Load the TagLib assembly if not already loaded
if (-not ([System.Management.Automation.PSTypeName]'TagLib.File').Type) {
    [Reflection.Assembly]::LoadFrom((Resolve-Path $tagLibPath))
}

while ($true) {
    # Get the list of image files (PNG and JPG) using Everything Search (es.exe)
    $imagePaths = es -path $searchPath !title: ext:png
    $imagePaths += es -path $searchPath !title: ext:jpg

    # Process each image file
    foreach ($imagePath in $imagePaths) {
        # Get the OCR text from the image
        $ocrResult = &$ocrScriptPath -Path $imagePath

        # Extract the OCR text
        $ocrText = $ocrResult.Text.Trim()

        # Check the file extension
        $extension = [System.IO.Path]::GetExtension($imagePath).ToLower()

        if ($extension -eq ".jpg") {
            # Use exiftool to update the title for JPG files
            $command = "exiftool -XPTitle=`"$ocrText`" `"$imagePath`""
            Invoke-Expression $command
        } else {
            # Update the image metadata using TagLib for other formats (e.g., PNG)
            $imageFile = [TagLib.File]::Create($imagePath)
            $imageFile.EnsureAvailableTags()

            # Set title to "NoTextFound" if OCR text is empty
            if ([string]::IsNullOrWhiteSpace($ocrText)) {
                $imageFile.Tag.Title = "NoTextFound"
            } else {
                $imageFile.Tag.Title = $ocrText
            }

            $imageFile.Save()
        }

        # Output the OCR text for reference (optional)
        echo "Processed $imagePath"
        if ($extension -eq ".jpg") {
            echo "Title set to (XPComment): $ocrText"
        } else {
            echo "Title set to: $($imageFile.Tag.Title)"
        }
    }

    # Wait for 60 seconds before running the loop again
    Start-Sleep -Seconds 60
}

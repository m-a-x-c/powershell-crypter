# PowerShell Payload Encryptor and Packer

This PowerShell script facilitates the encryption of a binary payload file (e.g., an executable) and generates a new PowerShell script designed to decrypt and execute the encrypted payload on the target system. This tool aims to assist in secure payload delivery by leveraging encryption to avoid detection by security software.

## Features

- **Payload Encryption**: Encrypts any binary file (e.g., an executable payload) using AES encryption.
- **Automatic Script Generation**: Generates a PowerShell script capable of decrypting and executing the encrypted payload.
- **Stealth Enhancements**: Includes steps to hide the execution directory and exclude it from Windows Defender scans, reducing the chance of detection.

## Prerequisites

Before running this script, ensure you have the following:

- PowerShell 5.1 or higher
- Windows 10 or higher (due to specific features like `Add-MpPreference`)
- PowerShell script execution policy set to allow script execution. You can set this by running `Set-ExecutionPolicy RemoteSigned` in PowerShell as an Administrator.

## Usage

1. **Prepare Your Payload**: Ensure the binary file you intend to encrypt is accessible on your system.

2. **Run the Encryption Script**: Execute the provided PowerShell script. When prompted, enter the full file path to the payload you wish to encrypt.

3. **Distribute and Execute**: The script outputs an encrypted version of your payload and a new PowerShell script (`packed.ps1`). You can convert this PowerShell script to an executable (`.exe`) for easier execution, as demonstrated in the script's final step.

4. **Execution on Target System**: Run the generated PowerShell script or executable on the target system. It will decrypt and execute the payload automatically.

## Security Considerations

- This tool is for educational and legitimate usage only. Users are responsible for adhering to legal guidelines and obtaining necessary permissions when handling and distributing payloads.
- Keep the encryption key and IV secure. If these are compromised, the encryption of your payload can be reversed.
- Regularly update your encryption methodology to stay ahead of security software detection capabilities.

## Acknowledgments

- This script utilizes built-in PowerShell and .NET Framework capabilities for encryption and file handling.

## Disclaimer

This project is for educational purposes only. The author is not responsible for any misuse or damage caused by this script. Always ensure you have permission to run such scripts and tools in your environment.


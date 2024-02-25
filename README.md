# 🛡 PowerShell Payload Encryptor and Packer 📦

This PowerShell script facilitates the encryption of a binary payload file (e.g., an executable) and generates a new executable stub and encrypted payload. The stub is designed to decrypt and execute the encrypted payload on the target system. This tool aims to assist in secure payload delivery by leveraging encryption to avoid detection by security software. This project is for educational purposes only. The author is not responsible for any misuse or damage caused by this script. Always ensure you have permission to run such scripts and tools in your environment.



However, the generated executable is currently detected by 14 out of 72 AVs on VirusTotal, including by Microsoft Defender. Though, that's 47 less than the malware with no crypter.




## 🌟 Features

- **🔒 Payload Encryption**: Encrypts any binary file (e.g., an executable payload) using custom RC4 encryption functions. No encryption API calls are made as that is what AVs look for.
- **📄 Automatic Executable Generation**: Generates an executable capable of decrypting and executing the encrypted payload.
- **👻 Stealth Enhancements**: Includes steps to hide the execution directory and exclude it from Windows Defender scans, reducing the chance of detection.
- ** Microsoft Defender Evation**: Encrypts the PowerShell command which adds the folder containing the raw payload to Microsoft Defender's exclusions (AV flags it otherwise)
- ** Polymorphism**: The payload file (the CSV file) changes every time it is created.

## 📋 Prerequisites

Before running this script, ensure you have the following:

- Windows 10 or higher (due to specific features like `Add-MpPreference`)
- PowerShell 5.1 or higher
- PS2EXE: simply run `Install-Module -Name ps2exe` in Windows Terminal or Powershell ([more information](https://www.powershellgallery.com/packages/ps2exe/1.0.13))

## 🚀 Usage

1. **📁 Prepare Your Payload**: Ensure the binary file you intend to encrypt is accessible on your system.

2. **▶️ Run the Encryption Script**: Execute the provided PowerShell script. When prompted, enter the full file path to the payload you wish to encrypt. Wait around 6 minutes for a 350 KB payload.

3. **📬 Distribute and Execute**: The script outputs a stub (`vision.exe`) and an encrypted version of the payload (`users.csv`).

4. **🎯 Execution on Target System**: Run the generated executable (`vision.exe`) on the target system. It will decrypt and execute the payload automatically. Make sure `vision.exe` and `users.csv` are in the same directory, otherwise it will not work.

## 📋 To-Do

1. Change all variable names in the packed script to random words
2. Consider not adding directory of the packed executable to the exclusion list
3. Add polymorphic and metamorphic components
4. Add section at beginning of decrypter which does something for few minutes (e.g. play silent audio)
5. Consider reflective loading
6. Research how AV detection works (https://wikileaks.org/ciav7p1/cms/files/BypassAVDynamics.pdf)

## 💖 Acknowledgments

- This script utilizes built-in PowerShell and .NET Framework capabilities for encryption and file handling.

## ⚠️ Disclaimer

This project is for educational purposes only. The author is not responsible for any misuse or damage caused by this script. Always ensure you have permission to run such scripts and tools in your environment.


# Packer
The purpose of this repo is to enable regular creation of golden images, in this case, in the form of .wim files.
Each packer template will install windows, provision as instructed and the proceed to capture a windows image. This is done by 
first convert the resultant .vmdk file to .vhd and then captureing the image using dism

## Environment Setup
```powershell
#Create a copy of powershell.exe called sh.exe (this is to trick the local-shell postprocessor into working)
Push-Location -Path $env:windir\System32\WindowsPowerShell\v1.0
Copy-Item -Path .\powershell.exe -Destination sh.exe
Pop-Location

#Enable logging
$env:PACKER_LOG=1
$env:PACKER_LOG_PATH="packer.log"
```

You will also need a copy of the iso images used in each template. If using different images remeber to replace the checksum
for each under variables. 

## Example Breakdown
```json

```
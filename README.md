# Packer
The purpose of this repo is to enable regular creation of golden images, in this case, in the form of .wim files.
Each packer template will install windows, provision as instructed and the proceed to capture a windows image. This is done by 
first convert the resultant .vmdk file to .vhd and then captureing the image using dism

## Quickstart
```powershell
#Create a copy of powershell.exe called sh.exe (this is to trick the local-shell postprocessor into working)
Push-Location -Path $env:windir\System32\WindowsPowerShell\v1.0
Copy-Item -Path .\powershell.exe -Destination sh.exe
Pop-Location

#Enable logging
$env:PACKER_LOG=1
$env:PACKER_LOG_PATH="packer.log"

#Render template files (Optional)
python .\render_packer_templates.py

#Invoke a packer build
packer.exe build .\<packer_file.json>
```

Note: You will also need a copy of the iso images used in each template. If using different images remeber to replace the checksum
for each under variables. 

## Roadmap
A list of things i plan to add to this repo

- [x] Jinja2 Templating to reduce code duplication
- [] Find a better way to run powershell in post-processing, creating sh.exe is digusting
- [] Use a CI engine to build images
- [] Run pester tests on built box to verify state before sysprep


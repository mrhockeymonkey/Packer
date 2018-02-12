# VMWare Workstation Pro to Windows Image File
Use VMWare Workstation Pro to build Windows and then create a Windows Image (.wim)

```cmd
packer build -force .\vmware-wim\server_2016_1709.json
```

## Prerequisites
* Macrosoft Virtual Machine Converter 3.0 (https://www.microsoft.com/en-us/download/details.aspx?id=42497)

## Notes
* Its very annoying and expensive but to be able to capture a .wim we must first convert the .vmdk into a .vhd. 

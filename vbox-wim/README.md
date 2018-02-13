# VirtualBox to WIM Build
Use Oracle virtualBox to build Windows and then create a Windows Image (.wim)

```cmd
packer build -force .\vbox-wim\server_2016_1709.json
```

## Prerequisites
* Oracle VirtualBox installed

## Notes
* Its very annoying and expensive but to be able to capture a .wim we must first convert the .vmdk into a .vhd. 

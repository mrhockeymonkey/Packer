# VMWare Workstation Pro to VSphere Template Build
Use VMWare Workstation Pro to build Windows and then create a VSphere template as a post-processing step. 

```cmd
packer build --var 'vsphere_pass=<Password>' -var-file="vsphere_lab.json" server_2016_1709.json
```

## Prerequisites
* VMWare Workstation Pro
* ovftool.exe must be on the %PATH%

## Notes
* vsphere takes care of generalizing deployed templates so you do not need to run SysPrep
* takes a vars-file for information about vsphere as well ass -var for vsphere_pass
* take not of which VMWare hardware version is support by vsphere. (https://kb.vmware.com/s/article/1003746)

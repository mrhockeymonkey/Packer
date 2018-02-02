# VirtualBox to VSphere Template Build
Use Oracle VBox to build Windows and then create a VSphere template as a post-processing step. 

## Prerequisites
Requires the packer-post-processor-vsphere-template plugin (link below). To use custom plugins in packer you must first download the plugin and place is in the same directory as packer.exe. This should be on your PATH. In this case there is an internal plugin with the same name so we must override this using packer.config.

Create C:\user\AppData\Roaming\packer.config and add:

```json
{
  "post-processors": {
    "vsphere-template": "C:/ProgramData/Packer/packer-post-processor-vsphere-template_windows_amd64.exe"
  }
}
```

## Notes
* vsphere takes care of generalizing deployed templates so you do not need to run SysPrep


## Links
vsphere-template plugin: https://github.com/andrewstucki/packer-post-processor-vsphere-template/releases

Info on plugins: https://www.packer.io/docs/extending/plugins.html
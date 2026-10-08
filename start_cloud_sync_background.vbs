Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "c:\wabsite\anti 2"
WshShell.Run "node services/obin_cloud_sync.mjs", 0, False

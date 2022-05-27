# randomCode
random code snippets - not expected to be used generically


$Username = "corp.example.com\admin"
$Password = '#K:#K!vCH83^NhwY)w1wBW$C(JjBej' | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName 'System.Management.Automation.PSCredential' ($Username, $Password)
$Null = New-PSDrive -Name 'FileCopy' -PSProvider 'FileSystem' -Root '\\MAD-MGMT01.corp.example.com\c$' -Credential $Credential
Copy-Item -Path 'FileCopy:\key.pes' -Destination 'C:\key.pes'
$Null = Remove-PSDrive -Name 'FileCopy' -ErrorAction Stop

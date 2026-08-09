for id in "$(
  printf %s\\n Mozilla.Firefox
  printf %s\\n Brave.Brave
  printf %s\\n Microsoft.Teams
  printf %s\\n Giorgiotani.PeaZip
  printf %s\\n VSCodium.VSCodium
  printf %s\\n JGraph.Draw
  printf %s\\n dbeaver.dbeaver
  printf %s\\n Notepad++.Notepad++
  printf %s\\n "Wacom.WacomTabletDriver"
  printf %s\\n "Postman.Postman"
  printf %s\\n "MongoDB.Compass.Community"

  printf %s\\n "Amazon.AWSCLI"
  printf %s\\n "Amazon.SessionManagerPlugin"

  printf %s\\n Microsoft.Azure.StorageExplorer
  printf %s\\n 9NP355QT2SQB # AzureVPN

  #printf %s\\n GoLang.Go
  #printf %s\\n Rustlang.Rustup
  #printf %s\\n Microsoft.NuGet
  #printf %s\\n SmartBear.SoapUI
  #printf %s\\n BlueStack.BlueStacks
  #printf %s\\n mRemoteNG.mRemoteNG
  #printf %s\\n Amazon.AWSCLI #v2
  #printf %s\\n Microsoft.AzureCLI
  #printf %s\\n Cisco.WebexTeams

  #printf %s\\n ""
  #printf %s\\n "Webyog.SQLyogCommunity"
  #printf %s\\n "Microsoft.OneDrive"
)"; do
  winget.exe install "${id}"
done


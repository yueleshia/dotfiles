for id in $(
  echo "glzr-io.glazewm"
  echo "ZedIndustries.Zed"
  echo "Mozilla.Firefox"
  #echo "Brave.Brave"
  #echo "Microsoft.Teams"
  echo "Giorgiotani.PeaZip"
  #echo "VSCodium.VSCodium"
  echo "JGraph.Draw"
  echo "DBeaver.DBeaver.Community"
  echo "Notepad++.Notepad++"
  #echo "Postman.Postman"
  echo "MongoDB.Compass.Community"

  echo "Wacom.WacomTabletDriver"
  echo "KDE.Krita"

  echo "Amazon.AWSCLI"
  echo "Amazon.SessionManagerPlugin"

  #echo "Microsoft.Azure.StorageExplorer"
  #echo "9NP355QT2SQB" # AzureVPN

  #echo "GoLang.Go"
  #echo "Rustlang.Rustup"
  #echo "Microsoft.NuGet"
  #echo "SmartBear.SoapUI"
  #echo "BlueStack.BlueStacks"
  #echo "mRemoteNG.mRemoteNG"
  #echo "Microsoft.AzureCLI"
  #echo "Cisco.WebexTeams"

  #echo "Webyog.SQLyogCommunity"
  #echo "Microsoft.OneDrive"
); do
  printf %s\\n "" "== Installing '${id}' ==" >&2
  winget.exe install --id "${id}" --source winget
  case "$?"
  in 0)
  ;; 20) exit 20
  ;; 43) printf %s\\n "Skipping '${id}'"
  esac
done


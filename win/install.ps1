winget install starship
Add-Content -Path $PROFILE -Value 'Invoke-Expression (&starship init powershell)'
New-Item -ItemType Directory -Force ~/.config; New-Item -ItemType file ~/.config/starship.toml;
starship init powershell
<#
.SYNOPSIS
  Capture de l'etat volatil (reseau et processus) d'une machine Windows.
.DESCRIPTION
  A lancer en PowerShell administrateur APRES le dump RAM (ordre de volatilite, RFC 3227).
  Ecrit netstat, arp et tasklist sur un support externe, puis calcule leur SHA-256.
.PARAMETER Out
  Dossier de sortie, sur le support de collecte (jamais sur le disque de la victime).
  Par defaut, le chemin UNC du dossier partage VirtualBox : un processus administrateur
  ne voit pas les lecteurs reseau mappes (E:).
#>
param(
    [string]$Out = '\\VBoxSvr\FORENSIC_USB\Output\RAM'
)

New-Item -ItemType Directory -Force $Out | Out-Null

"Capture UTC : $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss'))" |
    Out-File "$Out\capture_info.txt" -Encoding utf8

netstat -ano | Out-File "$Out\netstat.txt"  -Encoding utf8
arp -a       | Out-File "$Out\arp.txt"      -Encoding utf8
tasklist /v  | Out-File "$Out\tasklist.txt" -Encoding utf8

Get-FileHash -Algorithm SHA256 "$Out\netstat.txt", "$Out\arp.txt", "$Out\tasklist.txt" |
    Out-File "$Out\etat_volatil.sha256.txt" -Encoding utf8

Get-ChildItem $Out | Select-Object Name, Length, LastWriteTime

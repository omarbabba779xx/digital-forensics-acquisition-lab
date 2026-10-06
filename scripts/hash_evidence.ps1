<#
.SYNOPSIS
  Calcule le SHA-256 de chaque fichier d'un dossier de preuves et l'enregistre.
.EXAMPLE
  .\hash_evidence.ps1 -Path E:\Output\RAM
#>
param(
    [Parameter(Mandatory)][string]$Path,
    [string]$OutFile = (Join-Path $Path 'sha256_references.txt')
)

$files = Get-ChildItem $Path -File -Recurse | Where-Object { $_.FullName -ne $OutFile }
$files | Get-FileHash -Algorithm SHA256 |
    ForEach-Object { '{0}  {1}' -f $_.Hash, $_.Path } |
    Out-File $OutFile -Encoding utf8

"Hash calcules le $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss')) UTC -> $OutFile"
Get-Content $OutFile

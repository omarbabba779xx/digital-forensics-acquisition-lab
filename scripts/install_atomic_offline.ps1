<#
.SYNOPSIS
  Installation HORS LIGNE d'Atomic Red Team dans la VM de laboratoire.
.DESCRIPTION
  A lancer dans PowerShell ADMINISTRATEUR. Aucun acces Internet requis : les modules et les
  definitions de tests (T1059.001, T1547.001) sont deja sur le support de collecte.
  Ne lance AUCUN test et ne fait AUCUN nettoyage.
#>
$src = '\\VBoxSvr\FORENSIC_USB\Tools\AtomicRedTeam'   # UNC : E: invisible en administrateur

if (-not (Test-Path $src)) { throw "Introuvable : $src" }
$psv = $PSVersionTable.PSVersion
"PowerShell $psv"

# 1. Modules PowerShell (Invoke-AtomicRedTeam, powershell-yaml)
$modDst = "$env:ProgramFiles\WindowsPowerShell\Modules"
Copy-Item "$src\modules\*" $modDst -Recurse -Force

# 2. Definitions des tests
New-Item -ItemType Directory -Force 'C:\AtomicRedTeam' | Out-Null
Copy-Item "$src\atomics" 'C:\AtomicRedTeam\' -Recurse -Force

# 3. Debloquer les fichiers copies depuis un partage
Get-ChildItem "$modDst\Invoke-AtomicRedTeam","$modDst\powershell-yaml",'C:\AtomicRedTeam' -Recurse -File -ErrorAction SilentlyContinue |
    Unblock-File -ErrorAction SilentlyContinue

# 4. Verification
Import-Module powershell-yaml -Force
Import-Module Invoke-AtomicRedTeam -Force
"Module charge      : " + [bool](Get-Module Invoke-AtomicRedTeam)
"Dossier atomics    : " + (Test-Path 'C:\AtomicRedTeam\atomics')
"Invoke-AtomicTest  : " + [bool](Get-Command Invoke-AtomicTest -ErrorAction SilentlyContinue)
"--- Tests disponibles (T1547.001, 3 premiers) ---"
Invoke-AtomicTest T1547.001 -ShowDetailsBrief -PathToAtomicsFolder 'C:\AtomicRedTeam\atomics' | Select-Object -First 3

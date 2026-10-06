# Journal de cas — CASE-EX1-01

Toutes les heures sont en UTC (heure de l'hôte). L'horloge de la VM avance d'une heure.

| Heure | Événement |
|---|---|
| 11:04 | Capture de l'état réseau et processus (script) |
| ~11:09 | Fin du dump `victime_ram.mem` |
| ~11:12 | Fin de la copie `pagefile.sys` |
| ~11:18 | Début de l'image disque E01 |
| ~11:27 | SHA-256 de la RAM et du pagefile calculés sur la machine d'analyse |

## Observations

- `tasklist` (135 lignes) : deux processus `powershell.exe`, issus de la session d'administration utilisée pour lancer le script. Aucun `cmd.exe` relevé.
- La VM n'a aucune interface réseau : `netstat` ne peut montrer aucune connexion externe.

## Réserves

1. L'état réseau et processus précède le dump RAM d'environ cinq minutes (écart à l'ordre RFC 3227).
2. Le disque provient d'un poste d'analyse de malwares et contient des échantillons visibles sur le bureau : il ne s'agit pas d'une image officielle de victime.
3. Une première tentative de snapshot « live » a échoué (blocage) : la VM a été coupée de force puis redémarrée avant les acquisitions. Le disque de la VM a pu subir une vérification Windows au redémarrage.

## À compléter

- Rapport de vérification FTK de l'E01, hash du RAW.
- Triage KAPE.
- Exercice 2 : simulation Atomic Red Team, tableau de corrélation, conclusion.

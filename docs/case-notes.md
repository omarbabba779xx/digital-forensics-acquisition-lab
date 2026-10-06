# Journal de cas — CASE-EX1-01

Toutes les heures sont en UTC (heure de l'hôte). L'horloge de la VM avance d'une heure.

| Heure | Événement |
|---|---|
| 11:04 | Capture de l'état réseau et processus (script) |
| ~11:09 | Fin du dump `victime_ram.mem` |
| ~11:12 | Fin de la copie `pagefile.sys` |
| ~11:18 | Début de l'image disque E01 |
| ~11:27 | SHA-256 de la RAM et du pagefile calculés sur la machine d'analyse |
| 11:55:38 | Fin de l'acquisition E01 (14 segments) |
| 11:55:49 → 15:07:44 | Vérification FTK de l'E01 : MD5 et SHA-1 conformes, aucun bad block |
| 15:19:47 | Début du triage KAPE `!SANS_Triage` (2 304 s, 4 010 fichiers copiés) |
| ~16:26 → ~16:45 | Image RAW par conversion du disque virtuel, VM éteinte proprement |
| ~16:50 | SHA-256 du RAW (12 min 44 s) et liste de hash du triage KAPE |
| ~17:00 | Snapshot `Before_Atomic_Simulation` (VM éteinte), avant l'exercice 2 |

## Observations

- `tasklist` (135 lignes) : deux processus `powershell.exe`, issus de la session d'administration utilisée pour lancer le script. Aucun `cmd.exe` relevé.
- La VM n'a aucune interface réseau : `netstat` ne peut montrer aucune connexion externe.

## Réserves

1. L'état réseau et processus précède le dump RAM d'environ cinq minutes (écart à l'ordre RFC 3227).
2. Le disque provient d'un poste d'analyse de malwares et contient des échantillons visibles sur le bureau : il ne s'agit pas d'une image officielle de victime.
3. Une première tentative de snapshot « live » a échoué (blocage) : la VM a été coupée de force puis redémarrée avant les acquisitions. Le disque de la VM a pu subir une vérification Windows au redémarrage.

4. KAPE a refusé de démarrer tant que FTK Imager était ouvert (« process related to FTK is running ») : relancé après fermeture de FTK.
5. La vérification de l'E01 a pris 3 h 12 : FTK relisait l'image à travers le dossier partagé VirtualBox, beaucoup plus lent qu'une lecture directe sur l'hôte.

## À compléter

- Exercice 2 : simulation Atomic Red Team, tableau de corrélation, conclusion.

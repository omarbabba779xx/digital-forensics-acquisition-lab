# Chain of Custody — exercices 1 et 2

Examinateur : Omar Babba — Machine source : VM VirtualBox Windows 10 Pro (4 Go de RAM), hôte Windows 11.
Support de collecte : dossier partagé `FORENSIC_USB` (disque externe USB), vu comme `E:` dans la VM.
Toutes les heures sont en UTC (l'horloge de la VM avance d'une heure).

Une acquisition = une preuve = une entrée. Le modèle vierge est dans [`templates/chain_of_custody.md`](../templates/chain_of_custody.md).

---

## Exercice 1

### EVID-2026-S2-RAM-01 — Dump mémoire

| Champ | Valeur |
|---|---|
| Source | VM Windows 10 (live, session ouverte) |
| Outil | FTK Imager 8.3.0.27, portable, en administrateur, *Include pagefile* |
| Fin du dump | ~11:09 (mem), ~11:12 (pagefile) |
| Destination | `Output\RAM\victime_ram.mem` (4,5 Go), `pagefile.sys` (4,75 Go) |
| SHA-256 `.mem` | `6CF7D67661547A56180BD9FBA3433295C6D496BD7C9E6A2668862826C9BA26BB` |
| SHA-256 pagefile | `CDC9BAEF85AB35186018B823F61363959D69C652B7CEB0A6438E16BBD35363AE` |
| Hash calculé | ~11:27, machine d'analyse, `Get-FileHash` |

### EVID-2026-S2-NET-01 — État réseau et processus

| Champ | Valeur |
|---|---|
| Source | VM Windows 10 |
| Outil | `scripts/capture_volatile.ps1` (`netstat -ano`, `arp -a`, `tasklist /v`) |
| Heure | 11:04:00 |
| Réserve | Capturé **avant** le dump RAM (~5 min) : écart à l'ordre RFC 3227 |

### EVID-2026-S2-DISK-01 — Image disque

| Champ | Valeur |
|---|---|
| Source | `\\.\PHYSICALDRIVE0` (51 200 Mo, 104 857 600 secteurs) |
| Acquisition | 11:19:00 → 11:55:38 ; vérification 11:55:49 → 15:07:44 |
| E01 | 14 segments (19,4 Go) ; MD5 `56fabf66617b70a6deb645ec32dacfe6` ; SHA-1 `1646228e2fc86efceb9605fcf9f12a7aa15e56b0` ; calculé = stocké = rapport, aucun bad block |
| RAW | méthode « dead » : VM éteinte puis `VBoxManage clonemedium ... --format RAW` ; 53 687 091 200 octets ; SHA-256 `07A4F34CE8D733D9DEBF185CA1709B2DDE82D8C84724ABA1C476EF9A45DECF48` |
| Réserve | disque issu d'une VM de laboratoire déjà utilisée pour l'analyse de malwares |

### EVID-2026-S2-KAPE-01 — Triage KAPE

| Champ | Valeur |
|---|---|
| Commande | `kape.exe --tsource C: --target !SANS_Triage --tdest ...\Output\KAPE_Output --tflush` |
| Heure | début 15:19:47, durée 2 304 s |
| Résultat | 4 010 fichiers copiés (506 dédupliqués) sur 4 536 ; 1,59 Go |
| Intégrité | liste de hash de 4 013 lignes ; SHA-256 de la liste `1F4801742F463D9C768B89C6E76E25F32F2B6259EB8738F9DB46AA035AF8CB81` |
| Réserve | premier lancement refusé (FTK ouvert) ; un fichier à chemin trop long non haché |

---

## Exercice 2

### EVID-ATOMIC-RAM-01 — `incident_ram.mem`

| Champ | Valeur |
|---|---|
| Source | VM Windows 10 après les deux simulations |
| Outil | FTK Imager 8.3.0.27, *Include pagefile* décoché |
| Heure | fin du dump ~18:03 |
| Taille | 4 831 838 208 octets |
| SHA-256 | `1718D7BE2EABDB8FB1CA3F30603148B2429996816BBD8BCF250486F57B7A1743` (calculé 18:24:47, 1 min 21 s) |

### EVID-ATOMIC-PROC-01 — `tasklist.txt`

| Champ | Valeur |
|---|---|
| Commande | `tasklist /v > ...\Evidence\RAM\tasklist.txt` |
| Heure | 18:24 (136 lignes) |
| Réserve | ~21 min après la RAM, dans une autre fenêtre PowerShell : le `powershell.exe` de la simulation n'y figure plus |

### EVID-ATOMIC-DISK-01 — `Windows_Victim.E01`

| Champ | Valeur |
|---|---|
| Cas / preuve | `CASE-ATOMIC-01` / `DISK-01` — « Windows Victim » — « Atomic Red Team Incident » |
| Acquisition | 18:32:35 → 19:27:44 ; vérification dans la VM jusqu'à 19:47:30 |
| Segments | 13 (`.E01` à `.E13`, 19 Go) |
| MD5 | `f3202dfa0884b271d46817e15ece6f80` |
| SHA-1 | `97a87f355730f2aa3ca1798ff9f8562c22b9830a` |
| Vérification | calculé = stocké = rapport, aucun bad block, **dans la VM puis sur la machine d'analyse** (valeurs identiques) |

### EVID-ATOMIC-KAPE-01 — Collecte KAPE

| Champ | Valeur |
|---|---|
| Heure | début 19:49:51, 1 102 s |
| Résultat | 4 105 fichiers copiés (510 dédupliqués) sur 4 616 ; 4 118 fichiers, 1,61 Go |
| Intégrité | liste de hash de 4 117 lignes ; SHA-256 de la liste `F7A9514137CCE2BBC0295992FC2BB4C68930C9D3591F51FE8B457480A76F2E07` |
| Réserve | un fichier temporaire non copié (`WebCacheV01tmp.log`, verrouillé) |

---

## Journal des transferts

| Date | De | Vers | Motif | Hash revérifié |
|---|---|---|---|---|
| 2026-10-06 | VM victime | `FORENSIC_USB` | Acquisition | RAM, E01, RAW, KAPE |
| 2026-10-06 | `FORENSIC_USB` | Machine d'analyse | Analyse (FTK Imager, Registry Explorer) | E01 `Windows_Victim` : MD5 et SHA-1 identiques |

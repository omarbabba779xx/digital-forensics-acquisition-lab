# Digital Forensics Acquisition Lab

Laboratoire reproductible d'**acquisition et de préservation de preuves numériques** sur une machine Windows 10 virtualisée : capture de la RAM, imagerie complète du disque (E01 + RAW), triage ciblé d'artefacts, vérification d'intégrité par SHA-256 et documentation de la chaîne de custody.

Projet réalisé dans le cadre du module *Digital Forensics* (5ᵉ année Cybersecurity, EMSI, 2026/2027), séance 2.

> **Ce dépôt ne contient aucune preuve.** Dumps mémoire, images disque et fichiers collectés restent hors Git (voir [`.gitignore`](.gitignore)). Seuls les scripts, les modèles de documents, la méthodologie et les empreintes de référence sont versionnés.

---

## Sommaire

1. [Objectifs](#objectifs)
2. [Architecture du lab](#architecture-du-lab)
3. [Méthodologie](#méthodologie)
4. [Résultats](#résultats)
5. [Structure du dépôt](#structure-du-dépôt)
6. [Reproduire le lab](#reproduire-le-lab)
7. [Limites et réserves](#limites-et-réserves)
8. [Suite du projet](#suite-du-projet)

---

## Objectifs

- Acquérir les preuves d'une machine « victime » **dans l'ordre de volatilité** (RFC 3227) : RAM, puis état réseau et processus, puis disque.
- Produire une **image disque** aux formats E01 (compressée, métadonnées, hash intégré) et RAW/dd (compatibilité maximale).
- Prouver l'**intégrité** de chaque preuve par SHA-256 et la documenter.
- Découvrir le **triage d'artefacts** avec KAPE (`!SANS_Triage`).
- Tenir une **Chain of Custody** : une preuve, une entrée, un identifiant.

## Architecture du lab

| Rôle | Machine | Outils |
|---|---|---|
| Cible | VM Windows 10 64-bit « victime » (VirtualBox, 4 Go RAM, 2 vCPU, **sans carte réseau**) | — |
| Collecte | Dossier partagé `FORENSIC_USB` (disque externe USB), monté en `E:` dans la VM | FTK Imager (portable), KAPE |
| Analyse | Poste physique Windows 11 | FTK Imager, Registry Explorer, Autopsy, Volatility 3 |

Choix de conception :

- **Outils portables sur support externe** : on lance FTK Imager et KAPE depuis le support, sans rien installer sur la victime, pour minimiser l'empreinte (principe du *live response*).
- **Destination ≠ source** : toute écriture va vers le support de collecte, jamais vers le `C:` de la victime.
- **VM isolée** : aucune interface réseau. La VM ne peut pas atteindre un réseau tiers, ce qui compte quand le disque contient des échantillons de malware.
- **Dossier partagé restreint** : seule l'arborescence de collecte est exposée à la VM, pas le disque hôte entier.

## Méthodologie

Détail dans [`docs/methodology.md`](docs/methodology.md).

| Ordre | Acquisition | Outil | Sortie |
|---|---|---|---|
| 1 | RAM (volatil) | FTK Imager → *Capture Memory*, pagefile inclus | `victime_ram.mem`, `pagefile.sys` |
| 2 | État réseau et processus | `scripts/capture_volatile.ps1` | `netstat.txt`, `arp.txt`, `tasklist.txt` |
| 3 | Disque complet | FTK Imager → *Create Disk Image*, *Physical Drive* | `image_victime.E01` et `.raw` |
| 4 | Triage ciblé | KAPE, target `!SANS_Triage` | `KAPE_Output\` |
| 5 | Intégrité | `scripts/hash_evidence.ps1` | fichiers `*.sha256.txt` |

## Résultats

État d'avancement (acquisition du 2026-10-06, heures UTC) :

| Preuve | Identifiant | État |
|---|---|---|
| Dump mémoire + pagefile | `EVID-2026-S2-RAM-01` | Terminé, hash calculé |
| État réseau et processus | `EVID-2026-S2-NET-01` | Terminé |
| Image disque E01 + RAW | `EVID-2026-S2-DISK-01` | Terminé, E01 vérifiée, RAW hashé |
| Triage KAPE | `EVID-2026-S2-KAPE-01` | Terminé (4 010 fichiers, 1,59 Go) |

Empreintes de référence :

| Fichier | Empreinte |
|---|---|
| `victime_ram.mem` (4,5 Go) | SHA-256 `6CF7D67661547A56180BD9FBA3433295C6D496BD7C9E6A2668862826C9BA26BB` |
| `pagefile.sys` (4,75 Go) | SHA-256 `CDC9BAEF85AB35186018B823F61363959D69C652B7CEB0A6438E16BBD35363AE` |
| `image_victime.E01` (14 segments, 19,4 Go) | MD5 `56fabf66617b70a6deb645ec32dacfe6`, SHA-1 `1646228e2fc86efceb9605fcf9f12a7aa15e56b0` (calculé = stocké = rapport, aucun bad block) |
| `image_victime.raw` (50 Go) | SHA-256 `07A4F34CE8D733D9DEBF185CA1709B2DDE82D8C84724ABA1C476EF9A45DECF48` |

L'image RAW est produite hors ligne (VM éteinte) par conversion du disque virtuel, la méthode « dead » du TP. L'E01 est acquise en live depuis la VM.

Pour vérifier une copie : `Get-FileHash -Algorithm SHA256 <fichier>` et comparer. Un écart impose d'arrêter l'analyse sur cette copie et de documenter la différence.

## Structure du dépôt

```
.
├── README.md
├── .gitignore                    exclut preuves, binaires et sorties
├── scripts/
│   ├── capture_volatile.ps1      netstat, arp, tasklist + hash
│   └── hash_evidence.ps1         SHA-256 d'un dossier de preuves
├── templates/
│   └── chain_of_custody.md       fiche vierge, une entrée par preuve
└── docs/
    ├── methodology.md            procédure détaillée et justifications
    └── case-notes.md             journal, observations, réserves
```

## Reproduire le lab

Prérequis : VirtualBox, un disque de VM Windows 10, un support de 32 Go ou plus, FTK Imager et KAPE (téléchargements officiels Exterro et Kroll, sur formulaire).

1. Créer sur le support l'arborescence `Tools\`, `Output\RAM`, `Output\DISK`, `Output\KAPE_Output`, `Docs\ChainOfCustody`.
2. Copier FTK Imager et KAPE dans `Tools\`.
3. Partager le dossier avec la VM (VirtualBox : dossier partagé, montage automatique `E:`), après avoir installé les Guest Additions.
4. Dans la VM, lancer **PowerShell en administrateur**, puis FTK Imager depuis le support.
5. Suivre l'ordre du tableau [Méthodologie](#méthodologie).

> **Piège connu** : un programme lancé en administrateur ne voit pas les lecteurs réseau (`E:`) montés par la session standard. Utiliser le chemin UNC `\\VBoxSvr\<nom_du_partage>\...` ou renseigner le chemin à la main dans FTK Imager.

## Limites et réserves

- **Disque source** : le disque de la VM provient d'un poste d'analyse de malwares préexistant, pas d'une image officielle du cours. Il contient des échantillons de malware sur le bureau.
- **Ordre d'acquisition** : l'état réseau et processus a été capturé environ cinq minutes **avant** le dump RAM, ce qui s'écarte de l'ordre RFC 3227 (RAM d'abord). Documenté dans la Chain of Custody.
- **Acquisition live** : FTK Imager et KAPE tournent dans le système analysé et y laissent une trace. En forensic strict, KAPE cible plutôt une image montée en lecture seule.
- **Fiabilité de l'horloge** : l'horloge de la VM avance d'une heure sur l'hôte. Les heures de la Chain of Custody sont converties en UTC (heure hôte).
- FTK Imager acquiert la mémoire mais ne l'analyse pas : l'exploitation du `.mem` demande Volatility 3.

## Suite du projet

- Simulation contrôlée de deux techniques MITRE ATT&CK avec Atomic Red Team (T1059.001 PowerShell, T1547.001 Run Keys), puis corrélation disque, mémoire et registre (Registry Explorer).
- Analyse de la RAM avec Volatility 3 et du disque avec Autopsy.

## Avertissement

Usage pédagogique, sur machines de laboratoire uniquement. Ne jamais exécuter les simulations ou manipuler des échantillons de malware sur un système de production.

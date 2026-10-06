# Méthodologie d'acquisition

## 1. Principes

- **Ordre de volatilité (RFC 3227)** : on capture d'abord ce qui disparaît le plus vite. RAM, puis connexions réseau et processus, puis disque. Éteindre la machine avant de capturer la RAM détruit des preuves.
- **Préservation** : on n'écrit jamais sur le disque source. Destination ≠ source.
- **Intégrité** : un hash SHA-256 par preuve, calculé juste après l'acquisition, puis revérifié à chaque copie ou avant analyse.
- **Traçabilité** : un identifiant et une fiche de Chain of Custody par preuve, horodatées en UTC.

## 2. Préparation du support

- Format **exFAT** (ou NTFS) : FAT32 limite les fichiers à 4 Go, or un dump RAM dépasse souvent cette taille.
- Arborescence : `Tools\` (FTK Imager, KAPE), `Output\RAM`, `Output\DISK`, `Output\KAPE_Output`, `Docs\ChainOfCustody`.
- FTK Imager installé sur la machine d'analyse puis copié sur le support : on évite d'installer quoi que ce soit sur la victime.

## 3. RAM

FTK Imager → *File → Capture Memory*. Option *Include pagefile* cochée, pas d'AD1 (un `.mem` brut convient à Volatility). Lancement depuis le support, en administrateur.

La taille du dump correspond à la RAM de la machine (4,5 Go pour une VM de 4 Go, pagefile à part).

## 4. Réseau et processus

`netstat -ano`, `arp -a` et `tasklist /v`, via `scripts/capture_volatile.ps1`. Ces sorties complètent la RAM : elles donnent un instantané lisible sans outil d'analyse mémoire.

## 5. Disque

FTK Imager → *File → Create Disk Image*, source **Physical Drive** (le disque entier, pas une partition). Deux formats :

| | E01 | RAW (dd) |
|---|---|---|
| Compression | oui | non |
| Métadonnées | oui (cas, examinateur, notes) | non |
| Hash intégré | oui | non, hash externe |
| Usage | standard de preuve | compatibilité maximale |

Option *Verify images after they are created* activée : FTK compare le hash de la source à celui de l'image. Conserver ce rapport, c'est la preuve d'intégrité de l'E01.

## 6. Triage KAPE

KAPE n'est pas un outil d'imagerie : il **collecte des artefacts ciblés** (ruches du registre, Prefetch, journaux d'événements, MFT, USN). Commande :

```
kape.exe --tsource C: --target !SANS_Triage --tdest E:\Output\KAPE_Output --tflush
```

Cibler `C:` en live laisse une légère trace. En forensic strict, on cible plutôt une image montée en lecture seule.

## 7. Pièges rencontrés

| Problème | Cause | Solution |
|---|---|---|
| « The specified path does not exist » au lancement de FTK en administrateur depuis `E:` | Un processus élevé ne voit pas les lecteurs réseau de la session standard | Lancer par chemin UNC (`\\VBoxSvr\...`) ou activer `EnableLinkedConnections` (modifie la victime) |
| Souris inutilisable dans la VM | Sans Guest Additions, la souris est en mode PS/2 | Cliquer dans la VM pour la capturer, Ctrl droit pour la libérer, puis installer les Guest Additions |
| Snapshot « live » bloqué à 0 % | Écriture de l'état de la RAM sur un disque externe lent | Prendre le snapshot VM éteinte |
| Imagerie lente | Lecture du disque virtuel et écriture de l'image sur le même disque USB | Éviter toute autre activité sur ce disque pendant l'acquisition |

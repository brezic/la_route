# GDD – La Route

> Vision **cible** du jeu complet. Le contenu de chaque version est décrit dans `versions/`.
> Les points marqués 🔶 restent à définir.

## 1. Pitch

Jeu de conduite et de survie à la première personne, en solo. Le joueur doit parcourir **5 000 km** sur une route sans fin qui traverse plusieurs biomes, dans un monde abandonné : pas de PNJ, pas d'ennemis, pas d'économie. Les seuls adversaires sont la mécanique, le climat et l'usure du corps.

- **Objectif** : atteindre le km 5 000. La nature de l'arrivée reste à définir (définir quand arrivera à la version dédié à l'arrivé).
- **Ambiance** : contemplative et apaisante, en low poly coloré (référence visuelle : *Art of Rally*).
- **Plateforme** : Windows. Solo uniquement.
- **Durée** : elle dépend du véhicule. Repère : une citadine type années 80 (ex : Peugeot 205) roule à environ 100 km/h de moyenne.

## 2. Boucle de jeu

Conduire → surveiller le tableau de bord, la météo et l'heure → s'arrêter pour fouiller des bâtiments → réparer ou améliorer la voiture, manger, boire, se réchauffer ou se rafraîchir → dormir (ce qui sauvegarde) → reprendre la route.

Le **cycle jour/nuit** structure le voyage. Dans le désert, il faut rouler de nuit pour éviter la chaleur, ce qui rend les phares et la batterie essentiels.

## 3. Véhicule (cœur du jeu)

### 3.1 Conduite
- Conduite **semi-réaliste** avec boîte **automatique**.
- L'adhérence dépend du biome, de la météo et de l'état des pneus.

### 3.2 Pièces
- Pièces de base : **moteur**, **refroidissement**, **phares**, **pneus**, **roues**. D'autres pièces viendront au fil des versions (batterie, réservoir, carrosserie…).
- Chaque pièce a un **état de 0 à 100 %** qui affecte ses performances, avec des effets en chaîne (ex : refroidissement abîmé → surchauffe).
- Le **moteur** est un objet unique qui se démonte via une interface dédiée.
- **Montage et démontage** surtout physiques : on prend la pièce en main et on la place sur son point d'attache. Le moteur passe par une interface.
- **Outils** basiques : éponge (nettoyage), outil anti-rouille, scie circulaire.
- **Réparation** : une pièce peut toujours être remplacée. Elle peut aussi être réparée, mais uniquement dans les **garages**, via des **mini-jeux simples**.
- **Améliorations** possibles : pièces de meilleure qualité, rangement…

### 3.3 Fluides et énergie
- Essence, huile moteur et liquide de refroidissement sont consommés en **quantités réelles** (litres).
- Ils se transportent en **jerricans et bouteilles**.
- La **batterie** se recharge en roulant. Sa tension et son usure déterminent sa puissance (démarrage, phares).
- Le **chauffage** utilise la **chaleur du moteur**.

### 3.4 Information
- Le **tableau de bord** est la source principale d'information sur la voiture : jauges diégétiques, sans HUD voiture.

### 3.5 Véhicules multiples
- D'autres véhicules à trouver et à réparer seront ajoutés au fil des versions.

## 4. Joueur et survie

### 4.1 Jauges
| Jauge | Source | Effets |
|---|---|---|
| Température corporelle | Biome, météo, heure, vêtements, feu, chauffage | Froid : ralentissement. Chaud : déshydratation accélérée. |
| Soif | Temps, chaleur | Mort si vide |
| Faim | Temps | Mort si vide |
| Fatigue | Progressive après **12 h en jeu** sans dormir | Vision floue, puis écrans noirs de quelques secondes |
| Santé | Chutes, accidents de voiture | Soignée avec des **trousses de secours** |

- **Vêtements** : 3 emplacements (tête, corps, jambes), qui modifient la protection thermique.
- **Feu de camp** : il est possible d'allumer un feu pour se réchauffer.

### 4.2 Sommeil
La qualité du sommeil dépend du lieu :
- **Voiture** : sommeil court et peu récupérateur.
- **Camp** (sac de couchage, tente) : sommeil correct.
- **Lit dans un bâtiment** (hôtel, motel) : le meilleur sommeil.

Dormir **sauvegarde la partie**.

### 4.3 Mort
- Causes : accident, ou une jauge de survie arrivée à zéro.
- Conséquence : retour au **dernier endroit où le joueur a dormi**, c'est-à-dire la dernière sauvegarde.

## 5. Monde

### 5.1 Structure
- Une **route infinie avec des virages**, générée au fur et à mesure à partir d'une **graine (seed) partageable**.
- Le joueur peut quitter la route, mais rien d'intéressant ne se trouve au-delà d'environ **2 km** de chaque côté. 

### 5.2 Biomes
- Désert aride, toundra enneigée, forêt tempérée, marais. D'autres biomes pourront s'ajouter.
- Leur taille est aléatoire et les **transitions sont progressives et cohérentes** (pas de toundra juste après le désert).
- Chaque biome modifie l'adhérence, la température ambiante et la météo possible.

### 5.3 Temps et météo
- **Cycle jour/nuit de 48 minutes réelles**, soit 1 h en jeu = 2 min réelles.
- Météos : pluie, neige, tempête de sable, brouillard. Elles influencent la conduite, la température du moteur et la température du joueur.

### 5.4 Lieux à fouiller
- Des bâtiments simples (une station-service seule) jusqu'aux complexes complets (motel avec station-service et snack).
- Ressources selon le lieu :
  - **station-service** : essence et pièces ;
  - **restaurant / snack** : nourriture ;
  - **hôtel / motel** : lits confortables.
- les batiement seront ajout petit à petit et avec un fichier specs dédié 

## 6. Objets et inventaire

- **Physique** : les pièces de la voiture, les vêtements portés et les objets posés dans le monde.
- **Grille** : le contenu des coffres et des rangements. Les objets rangés ne sont plus simulés physiquement, pour préserver les performances.
- **Pas de craft.**

## 7. Interface et contrôles

- **HUD hors voiture** : jauges de survie uniquement.
- **Contrôles** : clavier/souris et manette.
- **Accessibilité dès le départ** : touches réassignables, sous-titres, options daltonisme.
- **Langues** : français et anglais.

## 8. Direction artistique et audio

- **Visuel** : low poly strict, flat shading, couleurs franches, matériaux simples. 🔶 Palette à définir.
- **Caméra** : vue à la première personne avec mains et corps visibles. Une vue alternative (troisième personne) est possible.
- **Audio** : ambiance sonore et **radio** dans la voiture. Les musiques seront **générées par IA**, au format `.ogg` (vérifier la licence d'usage commercial de l'outil choisi). 

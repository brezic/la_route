# Questions ouvertes – à compléter

> Réponds directement sous chaque question, après `R :`.
> Si tu n'as pas d'avis, écris `?` ou `à toi de proposer`.
> Les questions marquées ⭐ sont prioritaires (elles conditionnent le reste).

---

## A. Vision & périmètre

**A1. ⭐ Quel est le but du jeu ?** (destination finale, distance maximale, survie sans fin, histoire…)
R : la distance fait 5000km, pour l'arrivé sa reste à définir

**A2. ⭐ Que contient le MVP (premier prototype jouable) ?** (ex : 1 voiture, 1 biome, une route, essence et température moteur seulement)
R : pour la v0.1 une route de 1km, on apparait à coté de la voiture(oui, pour l'assence et température, biome simplifié)

**A3. Quelle durée pour une partie ou un run typique ?**
R : non définit, sa dépendra des véhicules, (voiture normal (type peugeot 205), 100km/h de moyenne)

**A4. Quelles plateformes cibles ?** (PC Windows seul, Linux, web, Steam Deck…)
R : windows pour l'instant

**A5. Solo uniquement, ou du multijoueur envisagé plus tard ?**
R : solo uniquement 

**A6. Quelle ambiance ou quel ton ?** (contemplatif, stressant, humoristique, mystérieux…)
R : low poly (ambiance art of rally)

---

## B. Joueur & survie

**B1. ⭐ Quelles jauges de survie pour le joueur ?** (température, soif, faim, fatigue/sommeil, santé… lesquelles garder ?)
R : température selon le biome et météo, le joueur devra trouver des vétement, pouvoir faire du feu, oui soif et fail, oui fatigue progressive (après 12 ingame), on peut imaginer un écran plus flou, écran noir pendant quelques seconde

**B2. Comment meurt-on, et que se passe-t-il ensuite ?** (permadeath, retour à la dernière sauvegarde, perte d'objets…)
R : on meurt d'accident, selon les jaudes de survie, retour au dernier endoit où on a dormit

**B3. Le joueur peut-il se blesser ?** (chute, accident de voiture, animaux…) Si oui, comment se soigne-t-il ?
R : chute et accident de voiture, pas d'ennemeie ou d'animaux dangereux, on peut se soigner avec des trousse de secours

**B4. Quels vêtements et équipements ?** (slots, effets sur la température)
R : vêtement pour la tête, le corps, les jambes

**B5. Peut-on dormir ? Où et avec quels effets ?** (dans la voiture, passage du temps, récupération)
R : oui mais pas avec les même effets, une voiture ne permettra pas de dormir longtemps, on peut imaginer un système de camps basique(sac de couchagen, toile de tente), et des lit dans les batiement qui donneront le meilleur sommeil

---

## C. Véhicule

**C1. ⭐ Une seule voiture pour toute la partie, ou peut-on en changer ou en trouver d'autres ?**
R : dans la V1 oui, pluiseurs voiture à trouver et à réparer

**C2. ⭐ Comment se fait le montage et le démontage des pièces ?**
- [ ] Physique (on prend la pièce en main et on la place sur un point d'attache)
- [ ] Via un menu ou une interface
- [x] Mélange des deux
R : mélange des 2,  principalement physique, pour le moteur, il faudra peut être une interface

**C3. Faut-il des outils pour réparer ?** (clé, cric, ruban adhésif…) Peut-on réparer une pièce, ou seulement la remplacer ?
R : outil basique pour enelever la rouille et nettoyer (éponge, scie circulaire)

**C4. Liste définitive des pièces ?** (moteur, radiateur, batterie, démarreur, roues, réservoir, carrosserie, phares, alternateur, filtre à huile, courroie…)
R : basique, moteur, refroidissement, phare, pneu, roue. le moteur est 1 object qui pourra être démonté

**C5. Faut-il gérer une boîte de vitesses ?** (automatique, manuelle avec embrayage…)
R : automatique 

**C6. Quel niveau de simulation de conduite ?** (arcade, semi-réaliste, simulation)
R : semi-réaliste

**C7. La voiture peut-elle être améliorée ?** (pièces de meilleure qualité, galerie de toit, remorque, stockage…)
R : oui

**C8. La batterie se recharge-t-elle en roulant ?** (alternateur) Que consomme-t-elle ? (phares, chauffage, radio…)
R : la batterie se recharge en roulant, son volatge et usure va déterminé sa puissance

**C9. Le chauffage utilise-t-il la batterie ou la chaleur du moteur ?** (le GDD dit « batterie/chaleur moteur », il faut trancher)
R : chaleur du moteur

**C10. Le tableau de bord est-il la principale source d'information ?** (jauges dans la voiture plutôt que HUD)
R : oui

---

## D. Monde & génération

**D1. ⭐ Quelle forme a le monde ?**
- [x] Une route infinie générée au fur et à mesure
- [ ] Une grande carte fixe, avec un contenu procédural
- [ ] Un réseau de routes avec des embranchements
R : route infinie qui traverse différent biome, avec des virage

**D2. Peut-on quitter la route et explorer librement le terrain ?**
R : oui, au délà de 2km (à définir), il n'y aucun intérêt 

**D3. Comment s'enchaînent les biomes ?** (ordre fixe, aléatoire, selon la distance, transitions progressives)
R : taille aléatoire, progressives (par exemple pas de de tundra, artic après le désert)

**D4. Quels lieux peut-on fouiller ?** (station-service, épave, maison, garage, motel, camp…)
R : c'est sa, liste à définir

**D5. Où sont les ressources et en quelle quantité ?** (rareté de l'essence, des pièces, de l'eau, de la nourriture)
R : l'essence et pièce dans les station service, la nourriture plus dans les restaurant, lit conformatable dans les hotels, on peut imaginer des batiment simple (juste station essence), au batiment complet, un motel avec station service et snack

**D6. Y a-t-il des PNJ, des marchands ou une économie (argent, troc) ?**
R : non pas de pnj tous es abandonnée

**D7. Quels dangers en dehors des pannes et du climat ?** (animaux, créatures, événements étranges, autres véhicules)
R : aucun 

**D8. Y a-t-il un cycle jour/nuit ? Combien de temps dure une journée en minutes réelles ?**
R : oui cycle jour/nuit de 48min, très important car dans le déssert on devra rouler la nuit, 

**D9. Quelle météo ?** (pluie, neige, tempête de sable, brouillard) Quels effets sur la conduite et la survie ?
R : oui pour ces météo, on peut imaginer changer la façon de conduire, la température du moteur, le froid et chaud sur le personnage 

**D10. Le monde utilise-t-il une graine (seed) partageable ?**
R : oui

---

## E. Inventaire & objets

**E1. Comment marche l'inventaire ?** (grille, poids, slots limités, ou uniquement des objets physiques posés dans la voiture)
R : et mélange, physique pour les élément de la voiture, et aussi les vêtement porté. mais une grille pour les objet dans le ou les coffres (pour amélioré les perfomance du jeu)

**E2. Les objets sont-ils physiques dans le monde ?** (les jeter dans le coffre, sur le siège…)
R : oui mais voir E1

**E3. Y a-t-il du craft ?** Si oui, que peut-on fabriquer ?
R : non

**E4. Comment transporte-t-on les fluides ?** (jerricans, bouteilles, quantités)
R : Oui jerricans, bouteille, qunatité réel

---

## F. Interface & contrôles

**F1. Quel HUD minimal hors de la voiture ?** (rien, icônes discrètes, jauges)
R : jauges de survie

**F2. Contrôles visés : clavier/souris, manette, ou les deux ?**
R : les 2

**F3. Faut-il des options d'accessibilité dès le départ ?** (remapping, sous-titres, daltonisme)
R : oui

**F4. Quelles langues ?** (FR seul, FR + EN)
R : FR + EN

---

## G. Audio & direction artistique

**G1. Musique : une radio dans la voiture, une ambiance seule, ou les deux ?**
R : les 2, pour la musique il faudra surement généré

**G2. As-tu une palette de couleurs ou des références visuelles ?** (jeux, images)
R : à définir

**G3. Quel style pour le joueur ?** (mains visibles, corps visible en vue FPS ?)
R : mains visible et corps visible en vue fps, (oui possibilité de changé de vue)

---

## H. Technique

**H1. ⭐ Physique du véhicule : `VehicleBody3D` natif ou `RigidBody3D` avec des roues faites maison (raycasts) ?**
R : je vais avoir besoin de plus de précision

**H2. Le rendu `GL Compatibility` est-il un choix volontaire ?** (cible PC modeste, web) Ou peut-on passer en `Forward+` pour avoir le brouillard volumétrique, de meilleures ombres et des effets de gel ?
R : je veux un jeux simple, c'est mon 1er gros jeux vidéo sérieux (je suis dévellopeur pro)

**H3. Que doit contenir la sauvegarde ?** (état de chaque pièce, position, monde déjà visité) Quel format ? (`Resource` `.tres`, JSON, binaire)
R : tous ce qu'il faut pour rependre la partie, la sauvegarde pourra se faire en dormant, format json en base 64, pour limité la tentation de modifier la sauvegarde 

**H4. Quelle cible de performance ?** (FPS, configuration minimale)
R : les perfomance sont important, minumum 60fps sur du 1080, attention 5000km c'est grand, attention à la physique des objects

**H5. Veut-on des tests automatisés ?** (GUT, gdUnit4) Sur quelles parties ?
R : oui

**H6. Quels autoloads ou singletons sont autorisés ?** (GameState, TimeManager, WeatherManager… ou aucun)
R : je vais avori besoin d'explication

**H7. Comment versionner les assets Blender ?** (`.blend` dans le repo, Git LFS)
R : git lfs, et choix technique à faire 

**H8. Quelle langue pour le code et les commentaires ?** (anglais ou français)
R : code en anglais, commentaire en français, j'aime le principe du clean code, je doit pouvoir venir maintenir le code si besoin 

---

## I. Organisation

**I1. Travailles-tu seul sur le projet ?**
R : oui

**I2. Quels autres documents veux-tu ?** (ROADMAP, liste des pièces et objets, design des biomes, ART_BIBLE…)
R : je ferais les specs petit à petit 

**I3. Y a-t-il des contraintes de délai ou un jalon visé ?**
R : pas de délai, c'est du loisir 

# TECH SPECS – La Route

> Conventions et architecture **durables**. Les choix propres à une version sont dans `versions/`.

## 1. Stack

- **Moteur** : Godot 4.7, physique **Jolt**.
- **Rendu** : **GL Compatibility**. C'est un choix volontaire : le jeu est simple, low poly et doit être performant.
- **Langage** : GDScript avec typage statique obligatoire.
- **Langues du code** : noms (variables, fonctions, classes, fichiers) en **anglais**, commentaires en **français**.
- **Cible** : Windows, **60 FPS minimum en 1080p**.
- **Tests** : **gdUnit4**, en priorité sur la logique pure (consommation, températures, usure, sauvegarde).

## 2. Structure des dossiers

```
res://
  scenes/        # niveaux, véhicule, joueur, props, UI
  scripts/       # logique, composants
  resources/     # données (pièces, objets, biomes, météo) via des Resource personnalisées
  assets/models/ # exports .glb depuis Blender
  tests/         # tests gdUnit4
  localization/  # fichiers de traduction FR / EN
```

## 3. Architecture

### 3.1 Composition
- Privilégier des **composants** (nœuds enfants dédiés : `EngineComponent`, `FuelTankComponent`, `TemperatureComponent`, `InteractableComponent`…) plutôt que des scripts monolithiques.
- Les **données** (caractéristiques d'une pièce, d'un biome, d'un objet) vivent dans des `Resource` personnalisées et non dans le code.

### 3.2 Communication
- Les composants communiquent par **signaux**. La logique ne touche jamais l'UI directement : le composant émet `temperature_changed.emit(value)` et l'UI écoute.

### 3.3 Autoloads (singletons)
Un autoload est un script chargé une seule fois au démarrage, accessible partout et persistant entre les scènes. Pour éviter les dépendances cachées, on se limite à :

| Autoload | Rôle |
|---|---|
| `GameClock` | Heure en jeu, cycle jour/nuit (48 min réelles) |
| `WeatherManager` | Météo courante |
| `SaveManager` | Sauvegarde et chargement |
| `Settings` | Options, accessibilité, langue, touches |

Tout ajout d'autoload doit être justifié dans ce document.

### 3.4 Physique du véhicule
- Le véhicule est un **`RigidBody3D` avec des roues faites maison en raycast** (suspension, adhérence et friction calculées par roue). `VehicleBody3D` n'est pas utilisé.
- Ce choix donne un contrôle total sur l'adhérence par biome et par météo, l'usure des pneus et les roues amovibles.
- Tout code de mouvement s'exécute dans `_physics_process(delta)`.

### 3.5 Monde de grande taille (5 000 km)
- **Recentrage du monde (origin shifting)** : le monde est recentré régulièrement autour du joueur pour éviter la perte de précision des flottants.
- **Route en morceaux (chunks)** générés à partir de la graine (seed), chargés devant le joueur et déchargés derrière.
- **Génération déterministe** : une même graine produit toujours le même monde.
- **Objets physiques** : endormis ou figés hors d'un rayon proche du joueur. Le contenu des coffres est stocké sous forme de données, sans simulation physique.

### 3.6 Sauvegarde
- La partie est sauvegardée **quand le joueur dort**.
- La sauvegarde contient tout ce qu'il faut pour reprendre la partie : graine, position, état de chaque pièce, inventaires, jauges, heure et météo.
- **Format** : JSON encodé en base64. C'est une obfuscation pour décourager la modification, pas une sécurité.
- Un **numéro de version de sauvegarde** est obligatoire pour permettre les migrations entre versions du jeu.

### 3.7 Localisation et entrées
- Tous les textes affichés passent par `tr()` avec des clés de traduction. Aucun texte en dur.
- Toutes les entrées passent par l'**Input Map** (clavier/souris et manette), avec des touches réassignables.

## 4. Principes Clean Code (GDScript)

- **Responsabilité unique** : un script = un rôle (`FuelSystem.gd`, `EngineTemperature.gd`, `WheelPhysics.gd`).
- **Fonctions courtes** : 15 à 20 lignes maximum, découpées en sous-fonctions privées préfixées par `_`.
- **Nommage explicite** : pas d'abréviations (`current_engine_temp`, et non `tmp`).
- **Pas de nombres magiques** : utiliser des constantes ou des `@export` (`@export var max_safe_temp: float = 110.0`).
- **Typage strict** : variables, paramètres et retours (`func consume_fuel(amount: float) -> bool:`).
- **Découplage par signaux** : voir 3.2.
- **Guard clauses** : retours anticipés plutôt que des `if` imbriqués.
- **Maintenabilité** : le code doit rester lisible et maintenable par le développeur sans assistance.

## 5. Pipeline 3D (Blender + MCP)

- **Style** : low poly strict, shading *flat*.
- **Échelle** : 1 unité Blender = 1 mètre Godot.
- **Orientation** : l'avant des objets pointe vers `-Z` dans Godot (`+Y` dans Blender avant export).
- **Origine (pivot)** : placée sur l'axe de rotation ou le point d'attache des pièces amovibles (roues, portières, capot).
- **Budget** : moins de 500 triangles pour un petit prop, moins de 3 000 pour une carrosserie.
- **Nommage** : objets et matériaux nommés clairement (`car_door_left`, `mat_metal_rust`).
- **Règle pour Claude** : appliquer les transformations (`Ctrl+A` → Scale/Rotation) avant de finaliser un mesh.

## 6. Versionnement

- **Git LFS** pour tous les binaires, configuré dans `.gitattributes` :
  - 3D : `.blend`, `.glb`, `.fbx` (les `.glb` exportés sont commités, car Godot en a besoin) ;
  - images : `.png` (format par défaut), `.jpg`, `.jpeg`, `.webp`, `.exr`, `.hdr` ;
  - audio : `.ogg` (format par défaut pour la musique et les ambiances), `.wav` (sons courts), `.mp3` ;
  - polices : `.ttf`, `.otf`.
- Tout nouveau format binaire doit être ajouté à `.gitattributes` **avant** son premier commit.
- Les sauvegardes automatiques de Blender (`.blend1`, `.blend2`) sont ignorées.
- Les fichiers `.import` de Godot sont du texte et restent hors LFS.

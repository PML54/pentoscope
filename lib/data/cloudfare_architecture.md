# Architecture Cloudflare Workers pour Pentapol

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CLOUDFLARE EDGE                               │
│  (Datacenters distribués mondialement - proche des utilisateurs)     │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                         WORKER                                   │ │
│  │                    (pentapol-duel)                               │ │
│  │                                                                   │ │
│  │   index.ts  ──────────────────────────────────────────────────   │ │
│  │       │                                                          │ │
│  │       ├── /health          → Réponse directe                     │ │
│  │       ├── /room/create     → Crée un Durable Object              │ │
│  │       ├── /room/XXXX/exists → Interroge le DO                    │ │
│  │       └── /room/XXXX/ws    → WebSocket vers le DO                │ │
│  │                                                                   │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                              │                                        │
│                              ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                    DURABLE OBJECTS                               │ │
│  │             (Instances avec état persistant)                     │ │
│  │                                                                   │
│  │   ┌─────────────────────┐    ┌─────────────────────┐            │ │
│  │   │     DuelRoom        │    │  DuelIsometryRoom   │            │ │
│  │   │  (Duel Classique)   │    │ (Duel Isométries)   │            │ │
│  │   │                     │    │                     │            │ │
│  │   │  - 2 joueurs        │    │  - 2 joueurs        │            │ │
│  │   │  - 1 solution ID    │    │  - SEED généré      │            │ │
│  │   │  - Timer            │    │  - 4 rounds         │            │ │
│  │   │  - Scoring          │    │  - Scoring          │            │ │
│  │   └─────────────────────┘    └─────────────────────┘            │ │
│  │          Room ABCD                  Room EFGH                    │ │
│  │          Room IJKL                  Room MNOP                    │ │
│  │            ...                        ...                        │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 1. Concepts de base

### Worker
Un **Worker** est une fonction JavaScript/TypeScript qui s'exécute sur les serveurs edge de Cloudflare. C'est comme un micro-serveur serverless qui :
- Reçoit des requêtes HTTP
- Exécute du code
- Retourne des réponses

**Avantages :**
- Latence ultra-faible (exécuté au plus proche de l'utilisateur)
- Pas de serveur à gérer
- Scaling automatique
- Coût basé sur l'usage

**Fichier principal :** `src/index.ts`
```typescript
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Toutes les requêtes arrivent ici
    // On route vers la bonne ressource
  }
}
```

### Durable Object (DO)
Un **Durable Object** est une instance avec état qui persiste entre les requêtes. C'est l'équivalent d'un "mini-serveur" dédié à une ressource spécifique.

**Caractéristiques :**
- **Singleton garanti** : Une seule instance par ID dans le monde
- **État en mémoire** : Variables conservées entre les requêtes
- **WebSocket natif** : Peut maintenir des connexions persistantes
- **Cohérence forte** : Pas de race conditions

**Analogie Unix :** C'est comme un processus daemon avec un PID unique, sauf qu'il peut dormir et se réveiller à la demande.

---

## 2. Structure du projet Pentapol-Server

```
pentapol-server/
├── src/
│   ├── index.ts              # Point d'entrée - Routeur HTTP
│   ├── duel-room.ts          # DO pour Duel Classique
│   └── duel-isometry-room.ts # DO pour Duel Isométries
├── wrangler.toml             # Configuration Cloudflare
├── tsconfig.json             # Configuration TypeScript
└── package.json
```

### wrangler.toml expliqué

```toml
# Nom du worker (devient l'URL: pentapol-duel.xxx.workers.dev)
name = "pentapol-duel"

# Fichier d'entrée
main = "src/index.ts"

# Version des APIs Cloudflare à utiliser
compatibility_date = "2024-01-01"

# Variables d'environnement (accessibles via env.GAME_TIME_LIMIT)
[vars]
GAME_TIME_LIMIT = "180"

# Déclaration des Durable Objects
[durable_objects]
bindings = [
  # "name" = nom dans le code (env.DUEL_ROOM)
  # "class_name" = nom de la classe TypeScript exportée
  { name = "DUEL_ROOM", class_name = "DuelRoom" },
  { name = "DUEL_ISOMETRY_ROOM", class_name = "DuelIsometryRoom" }
]

# Migrations : historique de création des DO
# IMPORTANT : ne jamais supprimer les anciennes migrations !
[[migrations]]
tag = "v1"                    # Tag unique
new_classes = ["DuelRoom"]    # Créé avec l'ancien format

[[migrations]]
tag = "v2"
new_sqlite_classes = ["DuelIsometryRoom"]  # Nouveau format requis (plan gratuit)
```

**Note sur les migrations :**
- Chaque fois qu'on ajoute un nouveau DO, on ajoute une migration
- Le `tag` doit être unique et croissant
- `new_classes` : ancien format (DO existants)
- `new_sqlite_classes` : nouveau format obligatoire pour plan gratuit
- **Ne jamais supprimer** une migration existante !

---

## 3. Flux de données

### Création d'une room

```
┌──────────┐         ┌──────────┐         ┌─────────────────┐
│  Client  │         │  Worker  │         │  Durable Object │
│ (Flutter)│         │ index.ts │         │                 │
└────┬─────┘         └────┬─────┘         └────────┬────────┘
     │                    │                        │
     │ POST /room/create  │                        │
     │ {gameMode:"iso"}   │                        │
     │───────────────────>│                        │
     │                    │                        │
     │                    │ Génère roomCode "ABCD" │
     │                    │                        │
     │                    │ env.DUEL_ISOMETRY_ROOM │
     │                    │   .idFromName("ABCD")  │
     │                    │   .get(id)             │
     │                    │───────────────────────>│ Crée l'instance
     │                    │                        │
     │                    │ fetch("/init")         │
     │                    │───────────────────────>│ Initialise
     │                    │                        │
     │                    │<───────────────────────│ {success: true}
     │                    │                        │
     │ {roomCode: "ABCD"} │                        │
     │<───────────────────│                        │
     │                    │                        │
```

### Connexion WebSocket

```
┌──────────┐         ┌──────────┐         ┌─────────────────┐
│  Client  │         │  Worker  │         │  DuelIsometry   │
│ (Flutter)│         │ index.ts │         │     Room        │
└────┬─────┘         └────┬─────┘         └────────┬────────┘
     │                    │                        │
     │ GET /room/ABCD/ws  │                        │
     │ Upgrade: websocket │                        │
     │───────────────────>│                        │
     │                    │                        │
     │                    │ Vérifie quel namespace │
     │                    │ contient "ABCD"        │
     │                    │───────────────────────>│ /exists → true
     │                    │                        │
     │                    │ room.fetch(request)    │
     │                    │───────────────────────>│
     │                    │                        │
     │<═══════════════════╪════════════════════════│ WebSocket établi
     │                    │                        │
     │ {"type":"join"}    │                        │
     │════════════════════╪═══════════════════════>│
     │                    │                        │
     │ {"type":"roomCreated", "roomCode":"ABCD"}   │
     │<═══════════════════╪════════════════════════│
     │                    │                        │
```

### Déroulement d'une partie (Duel Isométries)

```
┌──────────┐                    ┌─────────────────┐                    ┌──────────┐
│ Joueur 1 │                    │ DuelIsometry    │                    │ Joueur 2 │
│          │                    │     Room        │                    │          │
└────┬─────┘                    └────────┬────────┘                    └────┬─────┘
     │                                   │                                  │
     │ join_room                         │                                  │
     │──────────────────────────────────>│                                  │
     │                                   │                                  │
     │ roomCreated                       │                                  │
     │<──────────────────────────────────│                                  │
     │                                   │                                  │
     │                                   │                      join_room   │
     │                                   │<─────────────────────────────────│
     │                                   │                                  │
     │ opponentJoined                    │                       roomJoined │
     │<──────────────────────────────────│─────────────────────────────────>│
     │                                   │                                  │
     │                          ┌────────┴────────┐                         │
     │                          │ startCountdown()│                         │
     │                          └────────┬────────┘                         │
     │                                   │                                  │
     │ puzzleReady {seed, pieceCount}    │    puzzleReady {seed, pieceCount}│
     │<──────────────────────────────────│─────────────────────────────────>│
     │                                   │                                  │
     │ countdown: 3                      │                     countdown: 3 │
     │<──────────────────────────────────│─────────────────────────────────>│
     │ countdown: 2                      │                     countdown: 2 │
     │<──────────────────────────────────│─────────────────────────────────>│
     │ countdown: 1                      │                     countdown: 1 │
     │<──────────────────────────────────│─────────────────────────────────>│
     │                                   │                                  │
     │ roundStart                        │                       roundStart │
     │<──────────────────────────────────│─────────────────────────────────>│
     │                                   │                                  │
     │      ╔════════════════════════════╧════════════════════════════╗     │
     │      ║              JOUEURS EN TRAIN DE JOUER                  ║     │
     │      ║  (Génèrent le puzzle localement avec le même SEED)      ║     │
     │      ╚════════════════════════════╤════════════════════════════╝     │
     │                                   │                                  │
     │ progress {placed: 1, iso: 3}      │                                  │
     │──────────────────────────────────>│                                  │
     │                                   │ opponentProgress {placed:1,iso:3}│
     │                                   │─────────────────────────────────>│
     │                                   │                                  │
     │                                   │          progress {placed:2,iso:5}
     │                                   │<─────────────────────────────────│
     │ opponentProgress {placed:2,iso:5} │                                  │
     │<──────────────────────────────────│                                  │
     │                                   │                                  │
     │ completed {iso: 8, time: 45000}   │                                  │
     │──────────────────────────────────>│                                  │
     │                                   │ opponentCompleted {iso:8,t:45000}│
     │                                   │─────────────────────────────────>│
     │                                   │                                  │
     │                                   │     completed {iso: 10, t: 52000}│
     │                                   │<─────────────────────────────────│
     │ opponentCompleted {iso:10,t:52000}│                                  │
     │<──────────────────────────────────│                                  │
     │                                   │                                  │
     │                          ┌────────┴────────┐                         │
     │                          │   endRound()    │                         │
     │                          │ J1 gagne (8<10) │                         │
     │                          └────────┬────────┘                         │
     │                                   │                                  │
     │ roundEnd {winner: J1, scores}     │      roundEnd {winner: J1,scores}│
     │<──────────────────────────────────│─────────────────────────────────>│
     │                                   │                                  │
```

---

## 4. Concepts clés

### Namespace et ID

```typescript
// Dans index.ts
const namespace = env.DUEL_ISOMETRY_ROOM;  // Le "type" de DO
const roomId = namespace.idFromName("ABCD"); // Convertit string → ID unique
const room = namespace.get(roomId);          // Obtient (ou crée) l'instance
```

**Analogie :**
- `namespace` = une classe
- `idFromName("ABCD")` = un constructeur qui garantit l'unicité
- `get(roomId)` = obtenir la seule instance avec cet ID

### WebSocket dans un Durable Object

```typescript
// Dans duel-isometry-room.ts
export class DuelIsometryRoom implements DurableObject {
  
  async fetch(request: Request): Promise<Response> {
    if (request.headers.get('Upgrade') === 'websocket') {
      const pair = new WebSocketPair();  // Crée une paire client/serveur
      const [client, server] = Object.values(pair);
      
      this.state.acceptWebSocket(server);  // Le DO gère ce WebSocket
      
      return new Response(null, {
        status: 101,           // Switching Protocols
        webSocket: client,     // Retourne le côté client
      });
    }
  }

  // Appelé automatiquement quand un message arrive
  async webSocketMessage(ws: WebSocket, message: string) {
    const data = JSON.parse(message);
    // Traiter le message...
  }

  // Appelé automatiquement à la déconnexion
  async webSocketClose(ws: WebSocket) {
    // Nettoyer...
  }
}
```

### État en mémoire

```typescript
export class DuelIsometryRoom implements DurableObject {
  // Ces variables PERSISTENT entre les requêtes
  // (tant que le DO reste actif)
  private players: Map<string, Player> = new Map();
  private phase: GamePhase = 'waiting';
  private currentRound = 0;
  
  // Contrairement à un Worker normal où tout est recréé
  // à chaque requête, ici l'état reste en mémoire
}
```

---

## 5. Architecture Client (Flutter)

### Correspondance Client ↔ Serveur

| Flutter (Client) | Cloudflare (Serveur) |
|------------------|----------------------|
| `duel_isometry_provider.dart` | `duel-isometry-room.ts` |
| `DuelIsometryState` | État interne du DO |
| `WebSocketChannel` | `WebSocket` du DO |
| `IsometryPuzzle.generate(seed)` | Génère juste le `seed` |

### Pourquoi le SEED ?

```
AVANT (complexe et buggy):
┌────────┐                      ┌────────┐
│ Server │ ──── puzzle data ──> │ Client │
│        │      (positions,     │        │
│        │       indices,       │        │
│        │       grille...)     │        │
└────────┘                      └────────┘
  ↑ Doit connaître les pentominos
  ↑ Peut envoyer des indices invalides
  ↑ Duplication de code

APRÈS (simple et fiable):
┌────────┐                      ┌────────┐
│ Server │ ──── seed: 12345 ──> │ Client │
│        │      pieceCount: 3   │        │
│        │                      │        │
└────────┘                      └────────┘
                                  ↓
                        IsometryPuzzle.generate(
                          seed: 12345,
                          pieceCount: 3
                        )
  ↑ Ne connaît RIEN des pentominos
  ↑ Impossible d'avoir des bugs d'indices
  ↑ Code en un seul endroit (client)
```

**Déterminisme :** Avec le même `seed`, `Random(seed)` produit la même séquence de nombres sur tous les appareils. Donc les deux joueurs génèrent exactement le même puzzle.

---

## 6. Commandes essentielles

### Développement local
```bash
cd ~/pentapol-server

# Lancer en local (port 8787)
wrangler dev

# Tester
curl http://localhost:8787/
```

### Déploiement
```bash
# Compiler TypeScript (vérification)
npx tsc --noEmit

# Déployer
wrangler deploy

# Voir les logs en temps réel
wrangler tail
```

### Debug
```bash
# Logs du dernier déploiement
wrangler tail --format pretty

# Filtrer par texte
wrangler tail --search "ISO"
```

---

## 7. Résumé

| Concept | Rôle | Fichier |
|---------|------|---------|
| **Worker** | Point d'entrée, routage HTTP | `index.ts` |
| **Durable Object** | État persistant par room | `duel-room.ts`, `duel-isometry-room.ts` |
| **Namespace** | Collection de DO du même type | `env.DUEL_ROOM`, `env.DUEL_ISOMETRY_ROOM` |
| **Migration** | Historique de création des DO | `wrangler.toml` |
| **WebSocketPair** | Connexion bidirectionnelle | Dans le DO |

Le pattern général :
1. **Client** → requête HTTP → **Worker** (index.ts)
2. **Worker** → identifie la room → **Durable Object**
3. **DO** → maintient l'état → broadcast aux clients connectés
4. **Client** → génère le puzzle localement avec le **seed** reçu
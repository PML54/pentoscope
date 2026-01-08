================================================================================
DUEL ISOMÉTRIES - FLUX DE FONCTIONNEMENT
================================================================================

PHASE 1 : CRÉATION DE LA ROOM
────────────────────────────────────────────────────────────────────────────────

MASTER (iPhone 15)                    SERVEUR                    GUEST (iPhone 13)

1. Sélectionne 3×5                                                   
   ↓
2. Crée room "NRT2"
   ├─ HTTP POST /room/create
   │  └─→ [Serveur crée DO DuelIsometryRoom]
   ↓
3. WebSocket connect
   └─→ [CONNECT-ROOM] isCreator=true
   ↓
4. Attend guest
   └─→ state = waiting

                                                                1. Rejoint code "NRT2"
                                                                   ↓
                                                                2. WebSocket connect
                                                                   └─→ [CONNECT-ROOM] isCreator=false
                                                                       ↓
                                                                3. Envoie join_room
                                                                   └─→ [Message serveur: room_joined]
                                                                       ↓
                                                                4. Attend puzzle


PHASE 2 : MASTER GÉNÈRE LA SOLUTION
────────────────────────────────────────────────────────────────────────────────

MASTER                                SERVEUR                    GUEST

5. Reçoit [player_joined]
   └─→ _handlePlayerJoined()
   ↓
6. Appelle _masterGenerateAndSendSolution()
   ├─ IsometryPuzzleGenerator.generate(3×5)
   │  └─ IsometrySolver.findSolution() ← DÉTERMINISTE avec seed
   │     └─ Génère puzzle avec pieceIds=[6, 9, 8]
   │
   ├─ Extrait:
   │  ├─ seed = 1764833984400
   │  ├─ pieceIds = [6, 9, 8]
   │  ├─ targetGrid = 3×5 grid avec pièces placées
   │  └─ placements = [
   │       { pieceId: 6, gridX: 0, gridY: 0, positionIndex: 2 },
   │       { pieceId: 9, gridX: 1, gridY: 1, positionIndex: 0 },
   │       { pieceId: 8, gridX: 2, gridY: 2, positionIndex: 1 }
   │     ]
   │
   ├─ Stocke localement: state.puzzle = puzzle
   │
   └─ Envoie StartGameMessage
   └─→ {
   type: 'start_game',
   seed: 1764833984400,
   pieceIds: [6, 9, 8],
   targetGrid: [[6,6,6,9,9], [9,8,8,8,9], ...],
   placements: [...]
   }


PHASE 3 : SERVEUR BROADCAST LA SOLUTION
────────────────────────────────────────────────────────────────────────────────

                                SERVEUR

7. Reçoit start_game du master
   ├─ Stocke: currentSolution = { seed, pieceIds, targetGrid, placements }
   │
   └─ Appelle startCountdownWithSolution()
   └─ Broadcast PuzzleReadyMessage à TOUS les clients:
   {
   type: 'puzzle_ready',
   roundNumber: 1,
   seed: 1764833984400,
   pieceIds: [6, 9, 8],
   targetGrid: [[6,6,6,9,9], ...],
   placements: [...],          ← PLACEMENTS EXACTS
   timeLimit: 180
   }


PHASE 4 : GUEST CRÉE LE PUZZLE AVEC LES PLACEMENTS DU MASTER
────────────────────────────────────────────────────────────────────────────────

                                                                   GUEST
                                                                   
                                                                   8. Reçoit puzzle_ready
                                                                      ├─ _handlePuzzleReady()
                                                                      │
                                                                      ├─ Détecte: placements.isNotEmpty
                                                                      │
                                                                      └─ Appelle IsometryPuzzle.fromPlacements(
                                                                           seed: 1764833984400,
                                                                           placements: [
                                                                             { pieceId: 6, gridX: 0, gridY: 0, positionIndex: 2 },
                                                                             { pieceId: 9, gridX: 1, gridY: 1, positionIndex: 0 },
                                                                             { pieceId: 8, gridX: 2, gridY: 2, positionIndex: 1 }
                                                                           ]
                                                                         )
                                                                         ↓
                                                                      Génère EXACTEMENT
                                                                      le même puzzle que master!
                                                                      ↓
                                                                      state.puzzle = puzzle


PHASE 5 : COUNTDOWN
────────────────────────────────────────────────────────────────────────────────

MASTER                                SERVEUR                    GUEST

9. État: countdown                                               9. État: countdown
   ↓                                                                ↓
10. Countdown 3, 2, 1, 0             Broadcast countdown ←──┐
    ↓                                                         └──→ Countdown 3, 2, 1, 0
    ↓                                                                ↓
11. Puzzle visible à l'écran                                   11. Puzzle visible à l'écran
    ├─ Cible: pièces aux positions exactes                        ├─ Cible: MÊMES positions
    └─ Initial: pièces avec isométries aléatoires                 └─ Initial: MÊMES isométries
    (générées avec seed+1)


================================================================================
DUEL ISOMÉTRIES - FLUX DE FONCTIONNEMENT
================================================================================

ARCHITECTURE GÉNÉRALE
────────────────────────────────────────────────────────────────────────────────

CLIENT MASTER (Flutter)           SERVEUR (Cloudflare Workers)        CLIENT GUEST (Flutter)
↓                                        ↓                                ↓
iOS App                         DuelIsometryRoom DO                    iOS App
Dart                           (Durable Object)                       Dart
Provider                       TypeScript                            Provider
WebSocket                      WebSocket                             WebSocket


SERVEUR - STRUCTURE INTERNE
────────────────────────────────────────────────────────────────────────────────

DuelIsometryRoom (Durable Object)
│
├─ State Management:
│  ├─ roomCode: string | null
│  ├─ phase: 'waiting' | 'countdown' | 'playing' | 'roundEnd' | 'gameEnd'
│  ├─ currentRound: number (0-4)
│  ├─ currentSeed: number
│  ├─ players: Map<playerId, Player>
│  ├─ scores: Map<playerId, number>
│  └─ currentSolution: GameSolution | null  ← 🆕 Solution du master
│
├─ Persistent Storage (Hibernatable):
│  └─ storage.get('roomCode') ← Récupéré au réveil
│
├─ WebSocket Management:
│  ├─ state.getWebSockets() ← Récupère les WS hibernés
│  ├─ state.acceptWebSocket(server)
│  └─ deserializeAttachment() ← Infos joueur sauvegardées
│
└─ Methods:
├─ fetch(request) → route HTTP
├─ webSocketMessage(ws, message) → dispatcher messages
├─ webSocketClose(ws) → joueur déconnecté
├─ webSocketError(ws, error)
└─ Private handlers...


INTERFACES TYPESCRIPT
────────────────────────────────────────────────────────────────────────────────

interface PlayerAttachment {
id: string;
name: string;
}

interface Player {
id: string;
name: string;
ws: WebSocket;
isometryCount: number;
completionTime: number | null;
completed: boolean;
}

interface GameSolution {  ← 🆕
seed: number;
pieceIds: number[];
targetGrid: number[][];
placements: [
{ pieceId: number; gridX: number; gridY: number; positionIndex: number },
...
];
}

const ROUND_CONFIGS = [
{ pieceCount: 3 },   ← Round 1
{ pieceCount: 4 },   ← Round 2
{ pieceCount: 5 },   ← Round 3
{ pieceCount: 6 },   ← Round 4 (best of 3)
];


PHASE 1 : CRÉATION DE LA ROOM
────────────────────────────────────────────────────────────────────────────────

MASTER CLIENT                        SERVEUR                       GUEST CLIENT

1. POST /room/create              
   ├─ Body: { roomCode: "NRT2" }    
   │                                fetch('/init') called
   │                                ├─ Crée DuelIsometryRoom instance
   │                                ├─ storage.put('roomCode', "NRT2")
   │                                └─ Return: { success: true }
   ↓
2. WebSocket.connect()
   └─ GET /ws (Upgrade)            
   acceptWebSocket(server)
   ├─ server en hybernation-ready
   └─ Return: WebSocket pair
   ↓
3. Send: { type: 'join_room' }     
   │                                webSocketMessage called
   │                                ├─ handleJoin(ws, data)
   │                                ├─ playerId = p_timestamp_random
   │                                ├─ ws.serializeAttachment({ id, name })
   │                                ├─ players.set(playerId, player)
   │                                ├─ players.size = 1
   │                                ├─ Send to master:
   │                                │  {
   │                                │    type: 'room_created',
   │                                │    roomCode: "NRT2",
   │                                │    playerId: "p_..."
   │                                │  }
   │                                └─ Wait for guest...
   ↓
4. Receive: room_created message
   ├─ _handleRoomCreated()
   ├─ state = waiting
   └─ Attend guest

                                                                 1. GET /room/NRT2/exists
                                                                    ├─ fetch('/exists')
                                                                    ├─ exists = (roomCode != null && players.size < 2)
                                                                    └─ Return: { exists: true }
                                                                    ↓
                                                                 2. WebSocket.connect()
                                                                    └─ acceptWebSocket(server)
                                                                    ↓
                                                                 3. Send: { type: 'join_room' }
                                                                    │
                                                                    handleJoin(ws, data)
                                                                    ├─ playerId = p_...
                                                                    ├─ players.set(playerId, player)
                                                                    ├─ players.size = 2 ✅
                                                                    ├─ opponent = master
                                                                    ├─ Send to guest:
                                                                    │  {
                                                                    │    type: 'room_joined',
                                                                    │    roomCode: "NRT2",
                                                                    │    playerId: "p_...",
                                                                    │    opponentId: "p_master",
                                                                    │    opponentName: "Joueurn"
                                                                    │  }
                                                                    ├─ Send to master:
                                                                    │  {
                                                                    │    type: 'player_joined',
                                                                    │    playerId: "p_guest",
                                                                    │    playerName: "DD"
                                                                    │  }
                                                                    └─ this.startCountdown() ← Fallback si master n'envoie pas
                                                                    ↓
                                                                 4. Receive: room_joined message
                                                                    └─ state = waiting


PHASE 2 : MASTER GÉNÈRE ET ENVOIE LA SOLUTION
────────────────────────────────────────────────────────────────────────────────

MASTER CLIENT                        SERVEUR                       GUEST CLIENT

5. Receive: player_joined message
   ├─ _handlePlayerJoined()
   ├─ opponent = { id: "p_guest", name: "DD" }
   ├─ _isCreator = true ✅
   ├─ _masterGenerateAndSendSolution()
   │  ├─ IsometryPuzzleGenerator.generate(3×5)
   │  │  └─ IsometrySolver.findSolution(seed)
   │  │     └─ Backtracking DÉTERMINISTE
   │  │        └─ puzzle = { pieces, seed, targetGrid }
   │  │
   │  ├─ Stocke: state.puzzle = puzzle
   │  ├─ Extrait:
   │  │  ├─ seed = 1764833984400
   │  │  ├─ pieceIds = [6, 9, 8]
   │  │  ├─ targetGrid = [[6,6,6,9,9], ...]
   │  │  └─ placements = [
   │  │       { pieceId: 6, gridX: 0, gridY: 0, positionIndex: 2 },
   │  │       { pieceId: 9, gridX: 1, gridY: 1, positionIndex: 0 },
   │  │       { pieceId: 8, gridX: 2, gridY: 2, positionIndex: 1 }
   │  │     ]
   │  │
   │  └─ Send StartGameMessage:
   │     {
   │       type: 'start_game',
   │       seed: 1764833984400,
   │       pieceIds: [6, 9, 8],
   │       targetGrid: [[6,6,6,9,9], ...],
   │       placements: [...]  ← CLÉS = positions exactes
   │     }
   │
   └─→ Envoi WebSocket
   webSocketMessage called
   ├─ data.type = 'start_game' ✓
   ├─ handleStartGame(ws, data)
   │  ├─ player = findPlayerByWs(ws) = master
   │  ├─ this.currentSolution = {
   │  │    seed: data.seed,
   │  │    pieceIds: data.pieceIds,
   │  │    targetGrid: data.targetGrid,
   │  │    placements: data.placements  ← STOCKÉ
   │  │  }
   │  └─ this.startCountdownWithSolution()  ← NOUVEAU
   │     ├─ phase = 'countdown'
   │     ├─ currentRound++ (= 2)
   │     ├─ broadcast PuzzleReadyMessage:
   │     │  {
   │     │    type: 'puzzle_ready',
   │     │    roundNumber: 2,
   │     │    seed: 1764833984400,
   │     │    pieceIds: [6, 9, 8],
   │     │    targetGrid: [[6,6,6,9,9], ...],
   │     │    placements: [...]  ← ENVOYÉ AUX DEUX
   │     │  }
   │     ├─ Countdown 3, 2, 1, 0 (1s chacun)
   │     └─ startRound() après 0


PHASE 3 : GUEST REÇOIT ET CRÉE LE PUZZLE
────────────────────────────────────────────────────────────────────────────────

                                                                   6. Receive: puzzle_ready
                                                                      ├─ _handlePuzzleReady(msg)
                                                                      ├─ msg.placements.isNotEmpty ✓
                                                                      ├─ IsometryPuzzle.fromPlacements(
                                                                      │    seed: 1764833984400,
                                                                      │    placements: [
                                                                      │      { pieceId: 6, gridX: 0, gridY: 0, positionIndex: 2 },
                                                                      │      { pieceId: 9, gridX: 1, gridY: 1, positionIndex: 0 },
                                                                      │      { pieceId: 8, gridX: 2, gridY: 2, positionIndex: 1 }
                                                                      │    ]
                                                                      │  )
                                                                      │  ├─ Pour chaque placement:
                                                                      │  │  ├─ config = positionIndexToConfig(positionIndex)
                                                                      │  │  ├─ random = Random(seed + 1)
                                                                      │  │  ├─ faussedConfig = generateFaussedConfig(config)
                                                                      │  │  └─ piece = TargetPiece(
                                                                      │  │       pieceId, name,
                                                                      │  │       gridX, gridY,
                                                                      │  │       targetPositionIndex, ← EXACT du master!
                                                                      │  │       targetConfig,
                                                                      │  │       initialConfig,
                                                                      │  │       ...
                                                                      │  │     )
                                                                      │  └─ totalMin += distance
                                                                      │
                                                                      ├─ state.puzzle = puzzle (IDENTIQUE au master!)
                                                                      ├─ state.gameState = countdown
                                                                      └─ Countdown 3, 2, 1, 0


PHASE 4 : JEU EN COURS
────────────────────────────────────────────────────────────────────────────────

MASTER CLIENT                        SERVEUR                       GUEST CLIENT

Countdown 3 ←──────────────────────┐
Countdown 2 ←────────────────────┐  │                            Countdown 3 ←─┐
Countdown 1 ←──────────────┐      │  └──────────────────────────→ Countdown 2   │
Countdown 0 ←──┐          │      │                                Countdown 1   │
└──────────┼──────┘                                Countdown 0 ←─┘
↓
state = playing           round_start                             state = playing

7. Joueur place pièce 6:
   ├─ Position snappée = (0, 0) ← Exacte!
   ├─ Orientation = 2 ← Cible!
   └─ Send: { type: 'progress', placedPieces: 1, isometryCount: 0 }

                                    handleProgress(ws, data)
                                    ├─ player.isometryCount = 0
                                    ├─ opponent = guest
                                    └─ Send opponent:
                                       {
                                         type: 'opponent_progress',
                                         placedPieces: 1,
                                         isometryCount: 0
                                       }
                                                                    Receive: opponent_progress
                                                                    ├─ Affiche avancement master
                                                                    └─ state listener notifie UI

8. Joueur place pièce 9:
   ├─ Placement OK
   └─ Send: progress
   └─→ opponent_progress ──────────────────────────────→ Affiche avancement

9. Joueur place pièce 8:
   ├─ Placement OK
   ├─ PUZZLE TERMINÉ!
   └─ Send: { type: 'completed', isometryCount: 5, completionTime: 42000 }

                                    handleCompleted(ws, data)
                                    ├─ player.completed = true
                                    ├─ player.isometryCount = 5
                                    ├─ player.completionTime = 42000
                                    ├─ allPlayersCompleted() ?
                                    │  ├─ Master: true
                                    │  └─ Guest: false (non terminé)
                                    │
                                    └─ Send opponent:
                                       {
                                         type: 'player_completed',
                                         playerId,
                                         isometryCount: 5,
                                         completionTime: 42000
                                       }
                                                                    Receive: player_completed
                                                                    ├─ Affiche "Master a terminé!"
                                                                    └─ Peut continuer

10. Joueur guest termine aussi (après ~45s):
    └─ Send: { type: 'completed', isometryCount: 3, completionTime: 45000 }

                                    handleCompleted(ws, data)
                                    ├─ allPlayersCompleted() = true ✓
                                    ├─ endRound()
                                    │  ├─ phase = 'roundEnd'
                                    │  ├─ currentSolution = null ← Réinit pour prochain round
                                    │  ├─ Déterminer winner:
                                    │  │  ├─ Master: completed, isometryCount=5
                                    │  │  ├─ Guest: completed, isometryCount=3
                                    │  │  └─ Winner = guest (moins d'isométries)
                                    │  ├─ scores.set(guestId, 1)
                                    │  └─ broadcast round_result:
                                    │     {
                                    │       type: 'round_result',
                                    │       roundNumber: 2,
                                    │       winnerId: 'p_guest',
                                    │       players: {
                                    │         p_master: {
                                    │           name: 'Joueurn',
                                    │           completed: true,
                                    │           isometryCount: 5,
                                    │           completionTime: 42000,
                                    │           score: 0
                                    │         },
                                    │         p_guest: {
                                    │           name: 'DD',
                                    │           completed: true,
                                    │           isometryCount: 3,
                                    │           completionTime: 45000,
                                    │           score: 1  ← +1 pour ce round!
                                    │         }
                                    │       }
                                    │     }
                                    └─ Check if match end:
                                       ├─ required = ceil(4 / 2) = 2
                                       ├─ Master score = 0
                                       ├─ Guest score = 1
                                       ├─ Pas terminé, continue...
                                       └─ setTimeout startCountdown() après 5s


PHASE 5 : ROUND 2 (Fallback ou Master envoie again)
────────────────────────────────────────────────────────────────────────────────

5s après endRound:

├─→ startCountdown() (fallback)
│   ├─ phase = 'countdown'
│   ├─ currentRound = 3
│   ├─ generatePieceIds(seed, 4)  ← Fallback si master n'envoie pas
│   │  └─ Fisher-Yates shuffle avec LCG
│   │     (currentSeed * 9301 + 49297) % 233280
│   │     → pieceIds = [4, 11, 2, 7]
│   │
│   └─ broadcast puzzle_ready:
│      {
│        type: 'puzzle_ready',
│        roundNumber: 3,
│        seed: <currentSeed>,
│        pieceCount: 4,
│        pieceIds: [4, 11, 2, 7],
│        targetGrid: [],  ← Vide! (les clients vont générer)
│        placements: []   ← Vide!
│      }
│
└─ OU Master envoie start_game AVANT
└─ startCountdownWithSolution()
└─ puzzle_ready avec targetGrid + placements


PHASE 6 : MATCH END
────────────────────────────────────────────────────────────────────────────────

Après round 4 (best of 3, donc 2 rounds gagnés requis):

Score final:
├─ Master: 0
├─ Guest: 2
└─ Guest a 2 scores → required = 2
└─ endGame()
├─ phase = 'gameEnd'
├─ winnerId = guestId (score 2 > score 0)
├─ storage.deleteAll() ← Nettoie la room
└─ broadcast match_result:
{
type: 'match_result',
winnerId: 'p_guest',
players: {
p_master: { name: 'Joueurn', score: 0 },
p_guest: { name: 'DD', score: 2 }
}
}


SERVEUR - GESTION DE L'HIBERNATION
────────────────────────────────────────────────────────────────────────────────

1. HIBERNATION (quand inactivité):

   DO "in use" for 30s → Hibernatable WebSocket

   ├─ WebSocket paused
   ├─ Memory freed
   ├─ Attachment saved: { id, name }
   └─ Storage persisted: roomCode


2. RÉVEIL (nouveau message arrive):

   fetch('/init') called
   ├─ state.blockConcurrencyWhile() ← Accès storage
   ├─ Récupère stored roomCode
   ├─ state.getWebSockets() ← Récupère WS hibernés
   │  └─ Pour chaque WS:
   │     ├─ attachment = ws.deserializeAttachment()
   │     ├─ players.set(id, { id, name, ws, ... })
   │     └─ console.log('Restored player: ' + name)
   │
   └─ DO "in memory" à nouveau


STOCKAGE PERSISTENT
────────────────────────────────────────────────────────────────────────────────

await state.storage.put('roomCode', 'NRT2')
└─ Clé-valeur persistant

await state.storage.get('roomCode')
└─ Récupéré même après hibernation

await state.storage.deleteAll()
└─ Nettoie quand match fin


================================================================================
FLUX MESSAGE COMPLET
================================================================================

CLIENT → SERVER:

join_room
├─ playerName: string
└─ [Serveur] → handleJoin()

start_game  ← 🆕 MASTER ONLY
├─ seed: number
├─ pieceIds: number[]
├─ targetGrid: number[][]
├─ placements: [{ pieceId, gridX, gridY, positionIndex }, ...]
└─ [Serveur] → handleStartGame()

progress
├─ placedPieces: number
├─ isometryCount: number
└─ [Serveur] → handleProgress()

completed
├─ isometryCount: number
├─ completionTime: number
└─ [Serveur] → handleCompleted()


SERVER → CLIENT:

room_created
├─ roomCode: string
└─ playerId: string

room_joined
├─ roomCode: string
├─ playerId: string
├─ opponentId?: string
└─ opponentName?: string

player_joined
├─ playerId: string
└─ playerName: string

puzzle_ready
├─ roundNumber: number
├─ totalRounds: number
├─ seed: number
├─ pieceCount: number
├─ pieceIds: number[]
├─ targetGrid: number[][]
├─ placements: [...]  ← 🆕 Si envoyé par master
└─ timeLimit: number

countdown
└─ value: number (3, 2, 1, 0)

round_start
└─ roundNumber: number

opponent_progress
├─ placedPieces: number
└─ isometryCount: number

player_completed
├─ playerId: string
├─ isometryCount: number
└─ completionTime: number

round_result
├─ roundNumber: number
├─ winnerId?: string
└─ players: { playerId: { name, completed, isometryCount, completionTime, score }, ... }

match_result
├─ winnerId?: string
└─ players: { playerId: { name, score }, ... }


================================================================================
CLÉS DE SYNCHRONISATION
================================================================================

✅ SYNCHRONISATION EXACTE:
1. Master génère SEUL (coûteux)
2. Master envoie solution COMPLÈTE (seed + pieceIds + targetGrid + placements)
3. Serveur stocke dans currentSolution
4. Serveur envoie via puzzle_ready à TOUS
5. Guest crée puzzle avec IsometryPuzzle.fromPlacements()
6. Guest utilise placements exacts = positions + orientations synchrones

✅ DÉTERMINISTE:
- IsometrySolver avec seed fixe = même solution
- Random(seed+1) = même désorientation initiale
- Placements exacts garantissent même cible

✅ FALLBACK:
- Si master n'envoie pas start_game → startCountdown() fallback
- Génère pieceIds déterministes avec seededRandom()
- Pas de targetGrid ni placements
- Les deux clients génèrent aléatoirement

✅ RÉSILIENCE:
- Hibernatable WebSockets
- Storage persistent
- Restoration au réveil
- Cleanup automatique à match end


================================================================================
────────────────────────────────────────────────────────────────────────────────

MASTER                                SERVEUR                    GUEST

12. État: playing                                               12. État: playing
    ↓                                                                ↓
13. Joueur place pièce 6:                                       13. Joueur tente placements
    ├─ Position (0, 0) ✓ ← Correct!
    ├─ Orientation 2 ✓ ← Correct!
    └─ Envoie completed (si fini)
    └─→ [Message serveur: completed]
    └──→ Broadcast opponent_progress
    ↓
    14. Affiche avancement master

14. Joueur place pièce 9:
    ├─ Position (1, 1) ✓ ← Correct!
    ├─ Orientation 0 ✓ ← Correct!
    └─ Envoie completed (si fini)
    └─→ [Message serveur: completed]
    └──→ Broadcast opponent_progress
    ↓
    15. Affiche avancement master

15. Joueur place pièce 8:
    ├─ Position (2, 2) ✓ ← Correct!
    ├─ Orientation 1 ✓ ← Correct!
    └─ Envoie completed
    └─→ [Message serveur: completed]
    ├─ Master: isometryCount = 5
    ├─ Guest: isometryCount = 3
    └─ Winner: GUEST (moins d'isométries) 🏆
    ↓
    Broadcast round_result


PHASE 7 : FIN DU ROUND
────────────────────────────────────────────────────────────────────────────────

MASTER                                SERVEUR                    GUEST

16. Reçoit round_result                                         16. Reçoit round_result
    ├─ winnerId = guest_id                                          ├─ winnerId = self (je suis guest)
    ├─ players: {                                                   ├─ Affiche: "VOUS AVEZ GAGNÉ!"
    │   master: { name, score },                                   └─ Score: +1
    │   guest: { name, score }
    │ }
    └─ Affiche résultat
    └─ Score: +0


PHASE 8 : ROUND 2 (cycle recommence)
────────────────────────────────────────────────────────────────────────────────

17. Master crée nouveau puzzle (3×5, mais avec NOUVEAU seed)
    └─ Envoie start_game
    └─ Serveur broadcast puzzle_ready avec NOUVEAUX placements
    └─ Guest crée puzzle avec MÊMES placements
    └─ Les deux jouent EXACTEMENT le même puzzle


================================================================================
POINTS CLÉS
================================================================================

✅ SYNCHRONISATION:
- Master génère SEUL (coûteux: solver)
- Master envoie solution COMPLÈTE (seed + pieceIds + targetGrid + placements)
- Guest reçoit placements exacts et les utilise
- GARANTIE: 100% même puzzle sur les deux clients

✅ DÉTERMINISTE:
- IsometrySolver avec seed fixe = même solution à chaque fois
- Random(seed+1) pour isométries initiales = même désorientation

✅ ÉQUITABLE:
- Cible identique pour les deux
- Initial identique pour les deux
- Seule différence: skills des joueurs

✅ MINIMALISTE SERVER:
- Serveur relaie SEULEMENT (pas de calcul)
- Pas de génération côté serveur
- Juste du broadcast WebSocket


================================================================================
MESSAGES CLÉS
================================================================================

CLIENT → SERVER:
- join_room { roomCode, playerName }
- start_game { seed, pieceIds, targetGrid, placements }  ← MASTER ONLY
- progress { placedPieces, isometryCount }
- completed { isometryCount, completionTime }

SERVER → CLIENT:
- room_created { roomCode, playerId }
- room_joined { roomCode, playerId, opponentId, opponentName }
- player_joined { playerId, playerName }
- puzzle_ready { roundNumber, seed, pieceIds, targetGrid, placements }
- countdown { value }
- round_start { roundNumber }
- opponent_progress { placedPieces, isometryCount }
- round_result { roundNumber, winnerId, players }
- match_result { winnerId, players }


================================================================================
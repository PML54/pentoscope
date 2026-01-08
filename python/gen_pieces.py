#!/usr/bin/env python3
"""
Générateur de pentominos avec export pour Dart/Flutter
Génère un fichier Dart contenant tous les pentominos avec leurs transformations
Lundi 10 Novembre 6:42
"""

from typing import List, Tuple, Set
import json

class Piece:
    """Représente une pièce composée de carrés"""

    def __init__(self, squares: List[Tuple[int, int]], track_indices: bool = False):
        """
        squares: liste des coordonnées (x, y) des coins inf-gauche des carrés
        track_indices: si True, conserver l'ordre original sans trier
        """
        if track_indices:
            self.squares = list(squares)
        else:
            self.squares = sorted(squares)

    def __repr__(self):
        return f"Piece({self.squares})"

    def __eq__(self, other):
        return self.squares == other.squares

    def __hash__(self):
        return hash(tuple(self.squares))

    def normalize(self, track_indices: bool = False):
        """Normalise la pièce: translation pour que min(x)=0 et min(y)=0"""
        if not self.squares:
            return Piece([], track_indices=track_indices)

        min_x = min(x for x, y in self.squares)
        min_y = min(y for x, y in self.squares)

        normalized = [(x - min_x, y - min_y) for x, y in self.squares]
        if track_indices:
            # Préserver l'ordre original
            return Piece(normalized, track_indices=True)
        else:
            return Piece(sorted(normalized))

    def rotate_90(self, track_indices: bool = False):
        """Rotation de 90° dans le sens antihoraire: (x,y) -> (-y, x)"""
        rotated = [(-y, x) for x, y in self.squares]
        return Piece(rotated, track_indices=track_indices).normalize(track_indices=track_indices)

    def flip_horizontal(self, track_indices: bool = False):
        """Symétrie horizontale: (x,y) -> (-x, y)"""
        flipped = [(-x, y) for x, y in self.squares]
        return Piece(flipped, track_indices=track_indices).normalize(track_indices=track_indices)

    def get_ordered_transformations(self, track_indices: bool = False):
        """
        Retourne les transformations dans l'ordre spécifique:
        4 rotations, puis symétrie + 4 rotations
        En éliminant les doublons (garder la première occurrence)
        
        Args:
            track_indices: si True, préserve l'ordre des cellules pour tracker la correspondance
        """
        transformations = []
        seen = set()

        # 4 rotations
        current = self.normalize(track_indices=track_indices)
        for _ in range(4):
            normalized = current.normalize(track_indices=track_indices)
            # Pour la détection de doublons, utiliser la forme canonique
            if track_indices:
                canonical_form = Piece(sorted(normalized.squares))
                form_tuple = tuple(canonical_form.squares)
            else:
                form_tuple = tuple(normalized.squares)
                
            if form_tuple not in seen:
                transformations.append(normalized)
                seen.add(form_tuple)
            current = current.rotate_90(track_indices=track_indices)

        # Symétrie puis 4 rotations
        current = self.normalize(track_indices=track_indices).flip_horizontal(track_indices=track_indices)
        for _ in range(4):
            normalized = current.normalize(track_indices=track_indices)
            # Pour la détection de doublons, utiliser la forme canonique
            if track_indices:
                canonical_form = Piece(sorted(normalized.squares))
                form_tuple = tuple(canonical_form.squares)
            else:
                form_tuple = tuple(normalized.squares)
                
            if form_tuple not in seen:
                transformations.append(normalized)
                seen.add(form_tuple)
            current = current.rotate_90(track_indices=track_indices)

        return transformations

    def canonical_form(self):
        """Retourne la forme canonique (représentation lexicographiquement minimale)"""
        # Pour la forme canonique, on génère toutes les transformations possibles
        all_transforms = []
        current = self.normalize()

        # 4 rotations
        for _ in range(4):
            all_transforms.append(current.normalize())
            current = current.rotate_90()

        # Symétrie puis 4 rotations
        current = self.normalize().flip_horizontal()
        for _ in range(4):
            all_transforms.append(current.normalize())
            current = current.rotate_90()

        # Retourner la forme minimale
        canonical = min(all_transforms, key=lambda p: p.squares)
        return canonical

    def signature(self):
        """Signature unique pour détection de doublons"""
        canonical = self.canonical_form()
        return str(canonical.squares)

    def get_free_sides(self):
        """Retourne les positions libres adjacentes aux carrés de la pièce"""
        occupied = set(self.squares)
        free_positions = set()

        for x, y in self.squares:
            # 4 directions: Nord, Sud, Est, Ouest
            candidates = [
                (x, y + 1),    # Nord
                (x, y - 1),    # Sud
                (x + 1, y),    # Est
                (x - 1, y),    # Ouest
            ]

            for pos in candidates:
                if pos not in occupied:
                    free_positions.add(pos)

        return list(free_positions)


def generate_polyominoes(n: int) -> List[Piece]:
    """
    Génère tous les polyominos de taille n (sans doublons)

    Args:
        n: nombre de carrés par pièce

    Returns:
        Liste des pièces uniques
    """
    if n <= 0:
        return []

    # Étape 1: pièce initiale avec 1 carré en (0,0)
    current_level = [Piece([(0, 0)])]

    # Construire progressivement de 1 à n carrés
    for size in range(2, n + 1):
        print(f"Génération des pièces à {size} carrés...")
        next_level = []
        seen_signatures = set()

        for piece in current_level:
            # Trouver tous les côtés libres
            free_sides = piece.get_free_sides()

            # Créer une nouvelle pièce pour chaque côté libre
            for new_square in free_sides:
                new_squares = piece.squares + [new_square]
                new_piece = Piece(new_squares)

                # Vérifier si cette pièce est unique (via signature canonique)
                signature = new_piece.signature()

                if signature not in seen_signatures:
                    seen_signatures.add(signature)
                    next_level.append(new_piece.normalize())

        current_level = next_level
        print(f"  -> {len(current_level)} pièces uniques trouvées")

    return current_level


def coords_to_cell_number(x: int, y: int, grid_width: int = 5) -> int:
    """
    Convertit des coordonnées (x,y) en numéro de case
    Pour une grille de largeur grid_width

    Args:
        x: coordonnée x
        y: coordonnée y
        grid_width: largeur de la grille (défaut 5)

    Returns:
        Numéro de case (1-based)
    """
    return y * grid_width + x + 1


def piece_to_cell_numbers(piece: Piece, grid_width: int = 5, sort_result: bool = True) -> List[int]:
    """
    Convertit une pièce en liste de numéros de cases

    Args:
        piece: la pièce à convertir
        grid_width: largeur de la grille
        sort_result: si True, trier les cellules (défaut True pour compatibilité)

    Returns:
        Liste des numéros de cases (triée si sort_result=True)
    """
    cells = [coords_to_cell_number(x, y, grid_width) for x, y in piece.squares]
    return sorted(cells) if sort_result else cells


def export_to_dart(pieces: List[Piece], filename: str = "pentominos.dart", grid_width: int = 5):
    """
    Exporte les pièces au format Dart avec numéros de cases

    Args:
        pieces: liste des pièces
        filename: nom du fichier de sortie
        grid_width: largeur de la grille (défaut 5)
    """
    with open(filename, 'w', encoding='utf-8') as f:
        # Header
        f.write("// Généré automatiquement - Ne pas modifier manuellement\n")
        f.write(f"// Pentominos avec numéros de cases sur grille {grid_width}×{grid_width}\n")
        f.write(f"// Numérotation: ligne 1 (bas) = cases 1-{grid_width}, ligne 2 = cases {grid_width+1}-{2*grid_width}, etc.\n\n")

        # Classe Pento
        f.write("class Pento {\n")
        f.write("  final int id;\n")
        f.write("  final int size;\n")
        f.write("  final List<List<int>> positions;\n")
        f.write("  final int numPositions;\n")
        f.write("  final List<int> baseShape;\n")
        f.write("  \n")
        f.write("  const Pento({\n")
        f.write("    required this.id,\n")
        f.write("    required this.size,\n")
        f.write("    required this.positions,\n")
        f.write("    required this.numPositions,\n")
        f.write("    required this.baseShape,\n")
        f.write("  });\n")
        f.write("}\n\n")

        # Liste des pentominos
        f.write("final List<Pento> pentominos = [\n")

        for idx, piece in enumerate(pieces, 1):
            # Obtenir les transformations avec tracking des indices
            transformations = piece.get_ordered_transformations(track_indices=True)
            base_shape = transformations[0] if transformations else piece.normalize(track_indices=True)

            f.write(f"  // Pièce {idx}\n")
            f.write("  Pento(\n")
            f.write(f"    id: {idx},\n")
            f.write(f"    size: {len(piece.squares)},\n")
            f.write(f"    numPositions: {len(transformations)},\n")

            # Base shape en numéros de cases (triée pour compatibilité)
            base_cells_sorted = sorted([coords_to_cell_number(x, y, grid_width) for x, y in base_shape.squares])
            f.write(f"    baseShape: {base_cells_sorted},\n")

            # Toutes les positions en numéros de cases
            # IMPORTANT : ne PAS trier pour préserver la correspondance géométrique !
            f.write("    positions: [\n")
            for transform in transformations:
                # Ne PAS trier : l'ordre des cellules correspond à l'ordre géométrique
                cells = [coords_to_cell_number(x, y, grid_width) for x, y in transform.squares]
                f.write(f"      {cells},\n")
            f.write("    ],\n")

            f.write("  ),\n")
            if idx < len(pieces):
                f.write("\n")

        f.write("];\n")

    print(f"\nFichier Dart généré: {filename}")
    print(f"Grille: {grid_width}×{grid_width} ({grid_width*grid_width} cases)")


def print_summary(pieces: List[Piece], grid_width: int = 5):
    """Affiche un résumé des pièces générées avec numéros de cases"""
    print(f"\n{'='*60}")
    print(f"RÉSUMÉ DES {len(pieces)} PENTOMINOS (grille {grid_width}×{grid_width})")
    print(f"{'='*60}\n")

    for idx, piece in enumerate(pieces, 1):
        transformations = piece.get_ordered_transformations()
        base_cells = piece_to_cell_numbers(piece, grid_width)
        print(f"Pièce {idx}: {len(transformations)} position(s) unique(s)")
        print(f"  Base (coordonnées): {piece.squares}")
        print(f"  Base (cases): {base_cells}")

    print(f"\n{'='*60}")
    total_positions = sum(len(p.get_ordered_transformations()) for p in pieces)
    print(f"Total: {len(pieces)} pièces, {total_positions} positions au total")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    print("="*60)
    print("GÉNÉRATEUR DE PENTOMINOS POUR DART")
    print("="*60)
    print()

    # Générer tous les pentominos (5 carrés)
    n = 5
    grid_width = 5

    pentominos = generate_polyominoes(n)

    # Afficher le résumé
    print_summary(pentominos, grid_width)

    # Exporter vers Dart
    export_to_dart(pentominos, "pentominos.dart", grid_width)

    print("\nTerminé !")

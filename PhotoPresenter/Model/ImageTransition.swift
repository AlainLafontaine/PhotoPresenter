//
//  ImageTransition.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-19.
//

import Foundation

/// Mode de transition appliqué lors du changement d'image dans `ImageView`.
///
/// Réglage global (porté par `CommunityParameter`, persisté dans le `DisplaySpace`).
/// `none` reproduit le comportement historique : aucune animation entre deux images.
///
/// Les modes directionnels (Horizontal/Vertical, mais aussi Recouvrement,
/// Dévoilement, Retournement, Cube, Volets, Balayage…) déterminent le sens du
/// glissement à l'exécution par la comparaison d'index (voir `anyTransition(forward:)`).
/// Pour Evo_005, les nouveaux effets directionnels utilisent l'axe horizontal.
enum ImageTransition: String, Codable, CaseIterable {

    // MARK: Base (existant)
    case none       = "none"
    case horizontal = "horizontal"
    case vertical   = "vertical"
    case fade       = "fade"

    // MARK: Standards (Palier 1)
    case cover      = "cover"        // Recouvrement
    case reveal     = "reveal"       // Dévoilement
    case slideFade  = "slideFade"    // Glissement + fondu
    case zoom       = "zoom"         // Zoom
    case dipToBlack = "dipToBlack"   // Fondu via noir
    case dipToWhite = "dipToWhite"   // Fondu via blanc

    // MARK: Optionnelles (Palier 2)
    case flip       = "flip"         // Retournement
    case cube       = "cube"         // Cube
    case blinds     = "blinds"       // Volets
    case wipe       = "wipe"         // Balayage
    case iris       = "iris"         // Iris
    case shape      = "shape"        // Forme

    /// Libellé lisible affiché dans le combobox de `CommunityParamView`.
    var label: String {
        switch self {
        case .none:       return "Aucune"
        case .horizontal: return "Horizontal"
        case .vertical:   return "Vertical"
        case .fade:       return "Fondu"
        case .cover:      return "Recouvrement"
        case .reveal:     return "Dévoilement"
        case .slideFade:  return "Glissement + fondu"
        case .zoom:       return "Zoom"
        case .dipToBlack: return "Fondu via noir"
        case .dipToWhite: return "Fondu via blanc"
        case .flip:       return "Retournement"
        case .cube:       return "Cube"
        case .blinds:     return "Volets"
        case .wipe:       return "Balayage"
        case .iris:       return "Iris"
        case .shape:      return "Forme"
        }
    }

    /// Catégorie d'appartenance, utilisée pour grouper le combobox en sections.
    var category: Category {
        switch self {
        case .none, .horizontal, .vertical, .fade:
            return .base
        case .cover, .reveal, .slideFade, .zoom, .dipToBlack, .dipToWhite:
            return .standards
        case .flip, .cube, .blinds, .wipe, .iris, .shape:
            return .optionnelles
        }
    }

    /// `true` pour les transitions à deux phases passant par une couleur (dip),
    /// qui suivent un chemin de rendu dédié (overlay) plutôt que `AnyTransition`.
    var isDipTransition: Bool {
        self == .dipToBlack || self == .dipToWhite
    }

    // MARK: - Catégories

    enum Category: CaseIterable {
        case base
        case standards
        case optionnelles

        var label: String {
            switch self {
            case .base:         return "Base"
            case .standards:    return "Standards"
            case .optionnelles: return "Optionnelles"
            }
        }
    }

    /// Transitions d'une catégorie, dans l'ordre de déclaration de l'énumération.
    static func cases(in category: Category) -> [ImageTransition] {
        allCases.filter { $0.category == category }
    }
}

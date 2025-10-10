//
//  FederalStateModel.swift
//  Leben in Deutschland
//
//  Model representing a German federal state
//

import Foundation

// MARK: - Federal State Model
struct FederalStateModel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    
    /// Localized display name
    var localizedName: String {
        name.localized
    }
    
    // MARK: - All German Federal States
    static let allStates: [FederalStateModel] = [
        FederalStateModel(name: "Baden-Württemberg"),
        FederalStateModel(name: "Bayern"),
        FederalStateModel(name: "Berlin"),
        FederalStateModel(name: "Brandenburg"),
        FederalStateModel(name: "Bremen"),
        FederalStateModel(name: "Hamburg"),
        FederalStateModel(name: "Hessen"),
        FederalStateModel(name: "Mecklenburg-Vorpommern"),
        FederalStateModel(name: "Niedersachsen"),
        FederalStateModel(name: "Nordrhein-Westfalen"),
        FederalStateModel(name: "Rheinland-Pfalz"),
        FederalStateModel(name: "Saarland"),
        FederalStateModel(name: "Sachsen"),
        FederalStateModel(name: "Sachsen-Anhalt"),
        FederalStateModel(name: "Schleswig-Holstein"),
        FederalStateModel(name: "Thüringen")
    ]
}

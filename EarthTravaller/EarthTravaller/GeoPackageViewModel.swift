//
//  GeoPackageViewModel.swift
//  EarthTravaller
//
//  Created by Robert Arvin Lee on 9/3/26.
//

import SwiftUI
import MapKit
import GEOSwift
import SQLite
import Combine

// MARK: - ObservableObject ViewModel
class GeoPackageViewModel: ObservableObject {

    @Published var geometries: [Geometry] = []

    init() {
        loadGeoPackage()
    }

    func loadGeoPackage() {
        guard let path = Bundle.main.path(forResource: "natural_earth_vector", ofType: "gpkg") else {
            print("GeoPackage not found in bundle")
            return
        }

        do {
            let db = try Connection(path)
            var results: [Geometry] = []

            // Example table: "ne_10m_admin_0_countries"
            // You can list tables using SQLite if needed
            let table = "ne_10m_admin_0_countries"
            let geomColumn = "geom"
            let sql = "SELECT \(geomColumn) FROM \(table)"

            for row in try db.prepare(sql) {

                if let blob = row[0] as? Blob {
                    let data = Data.fromDatatypeValue(blob)

                    if data.count > 8 { // strip minimal GeoPackage header
                        let wkb = data.subdata(in: 8..<data.count)
                        if let geom = try? Geometry(wkb: wkb) {
                            results.append(geom)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.geometries = results
            }

        } catch {
            print("GeoPackage load error:", error)
        }
    }
}

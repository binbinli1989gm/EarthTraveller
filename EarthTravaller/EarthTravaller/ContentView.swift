//
//  ContentView.swift
//  EarthTravaller
//
//  Created by Robert Arvin Lee on 9/3/26.
//

import SwiftUI

struct ContentView: View {
    
    
    @StateObject var viewModel = GeoPackageViewModel()
    @State private var gpkgPath: String?
    
    var body: some View {
        VStack {
                    MapView(geometries: viewModel.geometries)
                        .edgesIgnoringSafeArea(.all)
                }
                .onAppear {
                    viewModel.loadGeoPackage()
                }
    }
}

#Preview {
    ContentView()
}

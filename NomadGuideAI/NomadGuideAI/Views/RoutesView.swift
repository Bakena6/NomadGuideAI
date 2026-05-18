//
//  RoutesView.swift
//  NomadGuideAI
//
//  Placeholder for tourist routes. Will load data/routes/<region>.json in v1.1.
//

import SwiftUI

struct RoutesView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "map.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.secondary)
                Text("Tourist routes")
                    .font(.title3.bold())
                Text("10 itineraries (1-8 days) coming soon — currently in the repo as data/routes/mangystau.json.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }
            .navigationTitle("Routes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

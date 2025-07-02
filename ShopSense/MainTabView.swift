//
//  MainTabView.swift
//  ShopSense
//
//  Created by Nidhish Nair on 7/1/25.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "sparkle.magnifyingglass")
                    Text("Scan & Ask")
                }

            ShoppingListView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Shopping List")
                }

            DealsView()
                .tabItem {
                    Image(systemName: "tag.circle.fill")
                    Text("Smart Deals")
                }

            AccountView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}



#Preview {
    MainTabView()
}

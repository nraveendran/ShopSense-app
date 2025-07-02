//
//  AccountView.swift
//  ShopSense
//
//  Created by Nidhish Nair on 7/1/25.
//


import SwiftUI

struct AccountView: View {
    @State private var isVoiceEnabled = true
    @State private var isLoggedIn = false
    @StateObject private var viewModel = AccountViewModel()

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Account
                Section(header: Text("Account")) {
                    if isLoggedIn {
                        Text("Logged in as: john@example.com")
                        Button("Logout") {
                            isLoggedIn = false
                        }
                    } else {
                        Button("Login") {
                            // login logic placeholder
                            isLoggedIn = true
                        }
                    }
                }

                // MARK: - Sync
                Section(header: Text("Receipt Sync")) {
                    Button("Sync Unsynced Receipts") {
                        viewModel.syncReceipts()
                        
                        if let status = viewModel.syncStatus {
                            Text(status)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Button("Clear Saved Receipts") {
                        clearSavedReceipts()
                    }
                }

                // MARK: - Data
                Section(header: Text("Data & Storage")) {
                    Button("Export Receipts as CSV") {
                        // future logic
                    }
                    Button("Clear Local Cache") {
                        // future logic
                    }
                }

                // MARK: - Preferences
                Section(header: Text("App Preferences")) {
                    Toggle("Enable Voice Interaction", isOn: $isVoiceEnabled)
                    Text("Version 1.0.0")
                        .foregroundColor(.gray)
                }

                // MARK: - Developer Tools (optional)
                Section(header: Text("Developer Tools")) {
                    Button("Show Saved Files") {
                        listSavedReceipts()
                    }
                    Button("Force Upload") {
                        syncReceipts()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    func syncReceipts() {
//        let receipts = getSavedReceiptImages()
//        for receipt in receipts {
//            uploadReceipt(at: receipt)
//        }
    }

    func clearSavedReceipts() {
//        let receipts = getSavedReceiptImages()
//        for receipt in receipts {
//            try? FileManager.default.removeItem(at: receipt)
//        }
    }

    func listSavedReceipts() {
//        let receipts = getSavedReceiptImages()
//        receipts.forEach { print("Saved: \($0.lastPathComponent)") }
    }
}

#Preview {
    AccountView()
}

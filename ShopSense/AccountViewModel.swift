import Foundation
import SwiftUI

class AccountViewModel: ObservableObject {
    @Published var syncStatus: String? = nil

    func syncReceipts() {
        let receipts = getSavedReceiptImages()

        guard !receipts.isEmpty else {
            print("[Sync] No receipts found for syncing.")
            DispatchQueue.main.async {
                self.syncStatus = "No receipts to sync."
            }
            return
        }

        print("[Sync] Found \(receipts.count) receipt(s) to sync.")

        for receipt in receipts {
            print("[Sync] Attempting upload: \(receipt.lastPathComponent)")
            uploadReceipt(at: receipt)
        }

        DispatchQueue.main.async {
            self.syncStatus = "Receipts syncing in background..."
        }
    }

    func getSavedReceiptImages() -> [URL] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("[Files] Scanning directory: \(documentsURL.path)")

        let files: [URL]
        do {
            files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        } catch {
            print("[Files] Failed to list contents: \(error)")
            return []
        }

        let receipts = files.filter { $0.pathExtension == "jpg" && $0.lastPathComponent.starts(with: "receipt-") }
        print("[Files] Found \(receipts.count) receipt image(s)")
        return receipts
    }

    func uploadReceipt(at fileURL: URL) {
        DispatchQueue.global(qos: .background).async {
            print("[Upload] Preparing to upload: \(fileURL.lastPathComponent)")

            guard let imageData = try? Data(contentsOf: fileURL) else {
                print("[Upload] Failed to read file: \(fileURL.lastPathComponent)")
                return
            }

            var request = URLRequest(url: URL(string: "https://your-api.com/receipt-upload")!)
            request.httpMethod = "POST"
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("[Upload] Failed: \(fileURL.lastPathComponent) — \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("[Upload] Completed: \(fileURL.lastPathComponent) — Status: \(httpResponse.statusCode)")
                }

                // Optionally delete the file if successful
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("[Cleanup] Deleted local file: \(fileURL.lastPathComponent)")
                } catch {
                    print("[Cleanup] Failed to delete: \(fileURL.lastPathComponent) — \(error)")
                }
            }.resume()
        }
    }
}

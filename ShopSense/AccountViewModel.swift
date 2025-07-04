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
            print("[UI] syncStatus updated to: \(self.syncStatus ?? "nil")")
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
                DispatchQueue.main.async {
                    self.syncStatus = "❌ Failed to read receipt: \(fileURL.lastPathComponent)"
                    self.clearStatusAfterDelay()
                }
                return
            }

            var request = URLRequest(url: URL(string: "http://192.168.68.72:8080/extractTextAndStore")!)
            request.httpMethod = "POST"
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("[Upload] Network error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.syncStatus = "❌ Network error while uploading: \(fileURL.lastPathComponent)"
                        self.clearStatusAfterDelay()
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[Upload] No valid HTTP response")
                    DispatchQueue.main.async {
                        self.syncStatus = "❌ Invalid server response for: \(fileURL.lastPathComponent)"
                        self.clearStatusAfterDelay()
                    }
                    return
                }

                if httpResponse.statusCode == 200 {
                    print("[Upload] Success: \(fileURL.lastPathComponent) — Status: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.syncStatus = "✅ Uploaded: \(fileURL.lastPathComponent)"
                        self.clearStatusAfterDelay()
                    }

                    // Optional cleanup
    //                do {
    //                    try FileManager.default.removeItem(at: fileURL)
    //                    print("[Cleanup] Deleted local file: \(fileURL.lastPathComponent)")
    //                } catch {
    //                    print("[Cleanup] Failed to delete: \(fileURL.lastPathComponent) — \(error)")
    //                }

                } else {
                    print("[Upload] Failed: \(fileURL.lastPathComponent) — HTTP \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.syncStatus = "❌ Upload failed: \(fileURL.lastPathComponent) — HTTP \(httpResponse.statusCode)"
                        self.clearStatusAfterDelay()
                    }
                }
            }.resume()
        }
    }


    private func clearStatusAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.syncStatus = nil
        }
    }

}

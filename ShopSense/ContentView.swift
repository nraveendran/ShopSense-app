import SwiftUI

struct ContentView: View {
    @State private var isShowingScanner = false
    @State private var confirmationMessage: String? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Welcome to ShopSense")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)

                Button(action: {
                    isShowingScanner = true
                }) {
                    VStack {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                        Text("Scan Receipt")
                            .font(.caption)
                    }
                }

                Spacer()
            }
            .padding()

            // Confirmation Message Overlay
            if let message = confirmationMessage {
                Text(message)
                    .padding()
                    .background(Color.green.opacity(0.9))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .font(.headline)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: confirmationMessage)
        .sheet(isPresented: $isShowingScanner) {
            VNDocumentCameraViewControllerRepresentableSave { image in
                if let image = image {
                    saveImageLocally(image)
                }
            }
        }
    }

    func saveImageLocally(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            confirmationMessage = "Failed to convert image ❌"
            return
        }

        let filename = "receipt-\(UUID().uuidString.prefix(8)).jpg"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)

        do {
            try imageData.write(to: fileURL)
            print("Saved image to: \(fileURL.path)")
            confirmationMessage = "Receipt saved successfully ✅"
        } catch {
            print("Error saving image: \(error)")
            confirmationMessage = "Failed to save receipt ❌"
        }

        // Hide message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confirmationMessage = nil
        }
    }
}

#Preview {
    ContentView()
}


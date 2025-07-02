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
            processImageInBackground(imageURL: fileURL)
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

func processImageInBackground(imageURL: URL) {
    DispatchQueue.global(qos: .background).async {
        // Step 1: Load image from file
        guard let imageData = try? Data(contentsOf: imageURL) else {
            print("Failed to read saved image")
            return
        }

        // Step 2: Build your API request
        var request = URLRequest(url: URL(string: "https://your-api.com/receipt-upload")!)
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        // Step 3: Call the API
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Upload completed with status code: \(httpResponse.statusCode)")
            }

            // Optionally: delete the image file here if no longer needed
        }

        task.resume()
    }
}


#Preview {
    ContentView()
}


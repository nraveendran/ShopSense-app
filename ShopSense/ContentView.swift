import SwiftUI

struct ContentView: View {
    @State private var isShowingScanner = false
    @State private var confirmationMessage: String? = nil
    @State private var isListening = false
    @State private var transcript = "Ask something about your shopping..."
    @StateObject private var speechRecognizer = SpeechRecognizer()



    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 16)

                // MARK: - App Title Banner
                HStack {
                    Image(systemName: "bag.fill")
                        .foregroundColor(.blue)
                    Text("ShopSense")
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                .padding(.horizontal)
                .padding(.bottom, 4)

                // MARK: - Microphone Button
                Button(action: {
                    isListening.toggle()
                    if isListening {
                        speechRecognizer.startTranscribing()
                    } else {
                        speechRecognizer.stopTranscribing()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(isListening ? Color.red.opacity(0.8) : Color.blue)
                            .frame(width: 100, height: 100)
                            .shadow(radius: 10)
                        Image(systemName: isListening ? "waveform.circle.fill" : "mic.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                    }
                }

                // MARK: - Transcript Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Conversation")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    ScrollView {
                        Text(speechRecognizer.transcript.isEmpty ? "Ask something about your shopping..." : speechRecognizer.transcript)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                .frame(maxHeight: 250)


                Spacer()
            }

            // MARK: - Floating Receipt Scan Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isShowingScanner = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 4)
                            Image(systemName: "doc.text.viewfinder")
                                .foregroundColor(.white)
                                .font(.system(size: 28))
                        }
                    }
                    .padding()
                }
            }

            // MARK: - Receipt Confirmation Banner
            if let message = confirmationMessage {
                VStack {
                    Text(message)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .shadow(radius: 5)
                    Spacer()
                }
                .padding(.top)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            VNDocumentCameraViewControllerRepresentableSave { image in
                if let image = image {
                    saveImageLocally(image)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: confirmationMessage)
    }


    func saveImageLocally(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            confirmationMessage = "❌ Failed to convert image"
            return
        }

        let filename = "receipt-\(UUID().uuidString.prefix(8)).jpg"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)

        do {
            try imageData.write(to: fileURL)
            print("Saved image to: \(fileURL.path)")
            confirmationMessage = "✅ Receipt saved!"
//            processImageInBackground(imageURL: fileURL)
        } catch {
            print("Error saving image: \(error)")
            confirmationMessage = "❌ Save failed"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confirmationMessage = nil
        }
    }
}


#Preview {
 ContentView()
}

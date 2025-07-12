import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
#endif


struct ContentView: View {
    @State private var isShowingScanner = false
    @State private var confirmationMessage: String? = nil
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    // Inside your ContentView
    @State private var apiResponse: String = ""

    
    var body : some View {
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
                    
                    if speechRecognizer.isRecording {
                        speechRecognizer.stopTranscribing()
                    } else {
                        speechRecognizer.startTranscribing()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                speechRecognizer.isRecording ? Color.red
                                    .opacity(0.8) : Color.blue
                            )
                            .frame(width: 100, height: 100)
                            .shadow(radius: 10)
                        Image(
                            systemName: speechRecognizer.isRecording ? "waveform.circle.fill" : "mic.circle.fill"
                        )
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
                        .padding(.horizontal)

                    // Editable transcript area
                    TextEditor(text: $speechRecognizer.transcript)
                        .frame(minHeight: 100, maxHeight: 200)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    // Send button to call backend
                    HStack {
                        Spacer()
                        Button(action: {
                            hideKeyboard() // 👈 Dismiss the keyboard
                            Task {
                                await fetchChatResponse(for: speechRecognizer.transcript)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "paperplane.fill")
                                Text("Send")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .padding(.trailing)
                    }

                    // Display API Response
                    
                    if !apiResponse.isEmpty {
                        Text(apiResponse)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .font(.body)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true) // 👈 important
                    }

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
        
    }
    
    func fetchChatResponse(for query: String) async {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "http://192.168.68.72:8080/api/chat/\(encodedQuery)") else {
            apiResponse = "❌ Invalid URL"
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let responseText = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    apiResponse = responseText
                }
            } else {
                DispatchQueue.main.async {
                    apiResponse = "❌ Unable to parse response"
                }
            }
        } catch {
            DispatchQueue.main.async {
                apiResponse = "❌ Network error: \(error.localizedDescription)"
            }
        }
    }

    func saveImageLocally(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            confirmationMessage = "❌ Failed to convert image"
            return
        }
            
        let filename = "receipt-\(UUID().uuidString.prefix(8)).jpg"
        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
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

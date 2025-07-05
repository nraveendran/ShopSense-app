import SwiftUI
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    @Published var transcript: String = "I am a shopping assistant"
    @Published var isRecording: Bool = false
    
    // MARK: - Silence timer
    private var silenceTimer: Timer?
    private let silenceInterval: TimeInterval = 3.0   //3‑second cutoff
    
    init() {
        requestPermission()
        transcript = "Hello world!"
    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("✅ Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    print("❌ Speech recognition not allowed")
                @unknown default:
                    break
                }
            }
        }
    }
    
    func startTranscribing() {
        transcript = ""
        request = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let request = request else { return }
        
        DispatchQueue.main.async {
            self.isRecording = true
        }
        
        request.shouldReportPartialResults = true
        
        recognitionTask = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                
                let isFinal = result.isFinal
                
                // Final transcript logic (safe to run now)
                if isFinal {
                   
                    
                    
                        print("✅ Done speaking. Final transcript: \(self.transcript)")
                        self.handleFinalTranscript(self.transcript)
                    
                    
                }else{
                    let transcript = result.bestTranscription.formattedString
                    DispatchQueue.main.async {
                        self.transcript = transcript
                    }
                    if (self.isRecording){
                        
                        self.resetSilenceTimer()
                    }
                }
            }
            
            if error != nil {
                //                    self.stopTranscribing()
            }
        }
        
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        print("🎙 Started transcribing")
    }
    
    func stopTranscribing() {
        print("🛑 Calling Stop transcribing")
        
        if (self.isRecording){
            
            DispatchQueue.main.async {
                self.isRecording = false
            }
            
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionTask?.cancel()
            print("🛑 Stopped transcribing")
        }
        
    }
    
    // MARK: - Silence timer helpers
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("🤫 Detected \(self.silenceInterval)s of silence – stopping.")
            self.stopTranscribing()
        }
    }
    
    func handleFinalTranscript(_ text: String) {
        guard !text.isEmpty else { return }
        print("✅ Final transcript ready: \(text)")
        
        // Your API logic here
        // ...
    }
}


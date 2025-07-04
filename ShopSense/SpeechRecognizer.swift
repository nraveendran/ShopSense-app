//
//  SpeechRecognizer.swift
//  ShopSense
//
//  Created by Nidhish Nair on 7/3/25.
//


import SwiftUI
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    @Published var transcript: String = ""

    init() {
        requestPermission()
    }

    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition authorized ✅")
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not allowed ❌")
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

        request.shouldReportPartialResults = true

        recognitionTask = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }

            if error != nil {
                self.stopTranscribing()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
    }
}

//
//  SpeechToTextView.swift
//  ShopSense
//
//  Created by Nidhish Nair on 7/3/25.
//
import SwiftUI

struct SpeechToTextView: View {
    @StateObject private var recognizer = SpeechRecognizer()
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 20) {
            Text(recognizer.transcript)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            Button(action: {
                if isRecording {
                    recognizer.stopTranscribing()
                } else {
                    recognizer.startTranscribing()
                }
                isRecording.toggle()
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(isRecording ? .red : .blue)
            }
        }
        .padding()
    }
}

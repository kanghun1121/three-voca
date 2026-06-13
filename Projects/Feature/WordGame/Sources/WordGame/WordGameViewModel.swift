import Foundation
import SwiftUI

import DomainInterface

import Dependencies

@Observable
@MainActor
public final class WordGameViewModel {

    enum ActiveStage {
        case loading
        case recognition(RecognitionViewModel)
        case spelling(SpellingViewModel)
        case error(String)
    }

    public enum StartingStage {
        case recognition
        case spelling
    }

    private(set) var activeStage: ActiveStage = .loading
    var dismiss = false

    @ObservationIgnored @Dependency(\.sessionClient) private var sessionClient

    private let sessionID: String
    private let startingStage: StartingStage

    public init(sessionID: String, startingFrom: StartingStage = .recognition) {
        self.sessionID = sessionID
        self.startingStage = startingFrom
    }

    func load() async {
        do {
            let session = try await sessionClient.fetchSessionDetail(sessionID)
            let words = session.words.map { GameWord(from: $0) }
            switch startingStage {
            case .recognition: startRecognition(words: words)
            case .spelling:    startSpelling(words: words)
            }
        } catch {
            activeStage = .error("단어를 불러오지 못했습니다.")
        }
    }

    private func startRecognition(words: [GameWord]) {
        let vm = RecognitionViewModel(
            words: words,
            onCompleted: { [weak self] in self?.startSpelling(words: words) },
            onClose: { [weak self] in self?.dismiss = true }
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            activeStage = .recognition(vm)
        }
    }

    private func startSpelling(words: [GameWord]) {
        let vm = SpellingViewModel(
            words: words,
            onCompleted: { [weak self] in self?.finishGame() },
            onClose: { [weak self] in self?.dismiss = true }
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            activeStage = .spelling(vm)
        }
    }

    private func finishGame() {
        Task { [weak self] in
            guard let self else { return }
            if let id = Int(sessionID) {
                try? await sessionClient.completeSession(id)
            }
            dismiss = true
        }
    }
}

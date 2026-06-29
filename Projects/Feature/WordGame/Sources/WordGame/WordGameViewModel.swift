import Foundation
import SwiftUI

import DomainInterface

import Dependencies

@Observable
@MainActor
public final class WordGameViewModel {

    enum ActiveStage {
        case loading
        case launch(onStart: () -> Void)
        case recognition(RecognitionViewModel)
        case stageEnd(title: String, onContinue: () -> Void)
        case multipleChoice(MultipleChoiceViewModel)
        case spelling(SpellingViewModel)
        case gameComplete(wordCount: Int, onDismiss: () -> Void)
        case error(String)
    }

    public enum StartingStage {
        case recognition
        case multipleChoice
        case spelling
    }

    private(set) var activeStage: ActiveStage = .loading
    var dismiss = false

    @ObservationIgnored @Dependency(\.sessionClient) private var sessionClient
    @ObservationIgnored @Dependency(\.audioClient) private var audioClient

    private let sessionID: String
    private let startingStage: StartingStage

    public init(sessionID: String, startingFrom: StartingStage = .recognition) {
        self.sessionID = sessionID
        self.startingStage = startingFrom
    }

    func load() async {
        do {
            let session = try await sessionClient.fetchSessionDetail(sessionID)
            let audioItems = session.words.map { ($0.term, $0.audioUrl) }
            Task { await audioClient.prefetchAudio(audioItems) }
            let words = session.words.map { GameWord(from: $0) }
            switch startingStage {
            case .recognition:    showLaunch(words: words)
            case .multipleChoice: startMultipleChoice(words: words)
            case .spelling:       startSpelling(words: words)
            }
        } catch {
            activeStage = .error("단어를 불러오지 못했습니다.")
        }
    }

    private func showLaunch(words: [GameWord]) {
        withAnimation(.easeInOut(duration: 0.3)) {
            activeStage = .launch(onStart: { [weak self] in self?.startRecognition(words: words) })
        }
    }

    private func startRecognition(words: [GameWord]) {
        let vm = RecognitionViewModel(
            words: words,
            onCompleted: { [weak self] in self?.showStageEnd(title: "인식 단계 종료!", onContinue: { self?.startMultipleChoice(words: words) }) },
            onClose: { [weak self] in self?.dismiss = true }
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            activeStage = .recognition(vm)
        }
    }

    private func startMultipleChoice(words: [GameWord]) {
        let vm = MultipleChoiceViewModel(
            words: words,
            onCompleted: { [weak self] in self?.showStageEnd(title: "뜻 단계 종료!", onContinue: { self?.startSpelling(words: words) }) },
            onClose: { [weak self] in self?.dismiss = true }
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            activeStage = .multipleChoice(vm)
        }
    }

    private func startSpelling(words: [GameWord]) {
        let vm = SpellingViewModel(
            words: words,
            onCompleted: { [weak self] in self?.showGameComplete(wordCount: words.count) },
            onClose: { [weak self] in self?.dismiss = true }
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            activeStage = .spelling(vm)
        }
    }

    private func showGameComplete(wordCount: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            activeStage = .gameComplete(wordCount: wordCount, onDismiss: { [weak self] in self?.finishGame() })
        }
    }

    private func showStageEnd(title: String, onContinue: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.3)) {
            activeStage = .stageEnd(title: title, onContinue: onContinue)
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

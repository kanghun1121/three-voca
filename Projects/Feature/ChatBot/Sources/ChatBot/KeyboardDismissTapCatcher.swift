import SwiftUI
import UIKit

/// 스크롤 영역 안 어디를 탭해도 키보드를 내리기 위한 최소 UIKit 브리지.
///
/// `.scrollDismissesKeyboard(.interactively)`가 켜지면 UIScrollView 내부의 네이티브 제스처
/// 인식기가 그 안의 모든 터치를 먼저 가져가 버려, SwiftUI 레벨의 `.onTapGesture`/
/// `.simultaneousGesture`는 (컨테이너 어디에 붙이든) 인식되지 않는다 — 순수 SwiftUI 제스처
/// 시스템과 ScrollView 내부 네이티브 인식기는 서로 다른 경계라 조율되지 않기 때문이다.
/// `UIGestureRecognizerDelegate`로 "항상 동시 인식 허용"을 명시해야 실제로 같이 동작한다.
struct KeyboardDismissTapCatcher: UIViewRepresentable {
    let onTap: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        recognizer.delegate = context.coordinator
        recognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(recognizer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onTap = onTap
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onTap: () -> Void

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }

        @objc func handleTap() {
            onTap()
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}

import SwiftUI
import UIKit

/// 키보드가 올라올 때, 스크롤 뷰의 오프셋을 키보드와 같은 애니메이션으로 움직인다.
///
/// 키보드는 알림(`keyboardWillChangeFrame`)에 실제 `duration`과 `curve`를 담아 보낸다.
/// 그 값을 그대로 `UIView.animate`에 넘기므로 키보드와 콘텐츠가 같은 속도로 움직인다.
/// 하단 인셋이 늘어나는 것만으로는 오프셋이 바뀌지 않아 콘텐츠가 키보드 뒤로 가려지고,
/// 오프셋을 `scrollTo`로 즉시 바꾸면 키보드보다 먼저 한 번에 이동하므로 이 방식을 쓴다.
///
/// 키보드가 내려갈 때는 알림의 `duration`이 0이다. 이때는 시스템이 하단 인셋을 줄이며
/// 오프셋을 최하단으로 맞춰 입력바와 함께 내려가므로 아무것도 하지 않는다.
struct KeyboardSyncedScroll: UIViewRepresentable {
    /// 키보드가 올라오기 직전에 최하단에서 이만큼 이내면 "최하단 근처를 보던 중"으로 본다.
    var bottomTolerance: CGFloat = 24

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        context.coordinator.anchorView = view
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.bottomTolerance = bottomTolerance
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        weak var anchorView: UIView?
        var bottomTolerance: CGFloat = 24
        private var observer: NSObjectProtocol?

        init() {
            observer = NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                self?.keyboardWillChangeFrame(notification)
            }
        }

        deinit {
            if let observer { NotificationCenter.default.removeObserver(observer) }
        }

        private func keyboardWillChangeFrame(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let scrollView = anchorView?.enclosingScrollView,
                  let window = scrollView.window,
                  let beginFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
                  let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                  let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
                  let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue
            else { return }

            // 창 아래쪽에서 키보드가 가리는 높이. 화면 밖(내려간 상태)이면 0.
            let beginOverlap = max(0, window.bounds.maxY - beginFrame.minY)
            let endOverlap = max(0, window.bounds.maxY - endFrame.minY)
            let delta = endOverlap - beginOverlap

            if delta < 0 {
                // 키보드가 내려갈 때: 하단 인셋이 줄어 새 최하단이 위로 올라오므로, 그 아래로 넘어간
                // 오프셋을 새 최하단으로 되돌린다. 안 그러면 콘텐츠 아래에 빈 공간이 남는다.
                let maxOffset = scrollView.contentSize.height + scrollView.adjustedContentInset.bottom - scrollView.bounds.height
                guard scrollView.contentOffset.y > maxOffset else { return }
                let target = CGPoint(x: scrollView.contentOffset.x, y: maxOffset)
                let options = UIView.AnimationOptions(rawValue: UInt(curveRaw) << 16)
                UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState]) {
                    scrollView.contentOffset = target
                }
                return
            }
            guard delta > 0, duration > 0 else { return }

            // 알림이 오는 시점에 하단 인셋은 이미 새 값으로 바뀌어 있다. 변화 직전 인셋은 역산한다.
            let insetAfter = scrollView.adjustedContentInset.bottom
            let insetBefore = insetAfter - delta
            let contentHeight = scrollView.contentSize.height
            let boundsHeight = scrollView.bounds.height
            let bottomOffsetBefore = contentHeight + insetBefore - boundsHeight
            let bottomOffsetAfter = contentHeight + insetAfter - boundsHeight

            // 직전에 최하단 근처를 보고 있었는지. 위쪽을 읽던 중이면 건드리지 않는다.
            guard bottomOffsetBefore - scrollView.contentOffset.y <= bottomTolerance else { return }

            // 키보드 높이만큼 옮기되, 새 최하단을 넘지 않는다.
            let targetY = min(scrollView.contentOffset.y + delta, bottomOffsetAfter)
            let target = CGPoint(x: scrollView.contentOffset.x, y: targetY)
            let options = UIView.AnimationOptions(rawValue: UInt(curveRaw) << 16)
            UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState]) {
                scrollView.contentOffset = target
            }
        }
    }
}

private extension UIView {
    /// 자신을 감싸는 가장 가까운 `UIScrollView`.
    var enclosingScrollView: UIScrollView? {
        var current: UIView? = superview
        while let view = current {
            if let scrollView = view as? UIScrollView { return scrollView }
            current = view.superview
        }
        return nil
    }
}

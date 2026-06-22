enum DotPhase: CaseIterable {
    case atMin   // 진입 애니메이션: linear(0.375s) → hold 구간
    case atPeak  // 진입 애니메이션: easeInOut(0.4375s) → rise 구간
    case atHold  // 진입 애니메이션: easeInOut(0.4375s) → fall 구간
}

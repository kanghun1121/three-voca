import SwiftUI

import DesignSystem

struct AppearanceSettingView: View {
    @AppStorage(AppearanceMode.storageKey) private var appearanceMode: AppearanceMode = .system
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Text("화면 모드")
                .typography(DesignSystemTypography.Pretendard.extraBold26)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.horizontal, 26)
                .padding(.bottom, 30)

            VStack(spacing: 0) {
                ForEach(AppearanceMode.allCases) { mode in
                    if mode != AppearanceMode.allCases.first {
                        Rectangle()
                            .fill(DesignSystemColor.Border.default)
                            .frame(height: 1)
                    }
                    AppearanceOptionRow(
                        title: mode.title,
                        isSelected: appearanceMode == mode,
                        action: { appearanceMode = mode }
                    )
                }
            }
            .padding(.horizontal, 26)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystemColor.Background.base)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    "뒤로",
                    systemImage: "chevron.left",
                    action: dismiss.callAsFunction
                )
                .typography(DesignSystemTypography.Content.bodySemiBold)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
            }
        }
    }
}

private struct AppearanceOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .typography(DesignSystemTypography.Pretendard.medium16)
                    .foregroundStyle(DesignSystemColor.Foreground.strong)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .typography(DesignSystemTypography.Pretendard.semiBold16)
                        .foregroundStyle(DesignSystemColor.Accent.selectedBlueText)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 18)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingView()
    }
}

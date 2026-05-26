import SwiftUI

struct StepRow: View {
    let index: Int
    let title: String
    let subtitle: String
    let eta: String
    var version: String? = nil
    let status: StepStatus
    let action: () -> Void

    @EnvironmentObject var model: InstallerModel

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            indexBlock
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 10) {
                    Text(title.uppercased())
                        .font(Theme.label(12))
                        .tracking(2.0)
                        .foregroundColor(Theme.ink)
                    if let version = version {
                        Text(version)
                            .font(Theme.code(10))
                            .foregroundColor(Theme.inkMute)
                    }
                    Text("~ \(eta)")
                        .font(Theme.label(9))
                        .tracking(1.4)
                        .foregroundColor(Theme.inkFaint)
                    statusGlyph
                }
                Text(subtitle)
                    .font(Theme.body(12))
                    .foregroundColor(Theme.inkMute)
                    .lineLimit(2)
            }
            Spacer()
            actionButton
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    private var indexBlock: some View {
        ZStack {
            Rectangle()
                .strokeBorder(Theme.ink, lineWidth: 1)
                .frame(width: 28, height: 28)
            Text("\(index)")
                .font(Theme.display(16, weight: .medium))
                .foregroundColor(Theme.ink)
        }
    }

    @ViewBuilder private var statusGlyph: some View {
        switch status {
        case .unknown:
            label(", ", fg: Theme.inkFaint, bg: Theme.paperDeep)
        case .missing:
            label("MISSING", fg: Theme.accent, bg: Theme.accent.opacity(0.12))
        case .installed:
            label("INSTALLED", fg: Theme.paper, bg: Theme.ink)
        case .working(let s):
            HStack(spacing: 6) {
                ProgressView().controlSize(.mini)
                Text(s.uppercased())
                    .font(Theme.label(9)).tracking(1.4)
                    .foregroundColor(Theme.inkMute)
            }
        case .failed:
            label("FAILED", fg: Theme.accent, bg: Theme.accent.opacity(0.12))
        }
    }

    private func label(_ s: String, fg: Color, bg: Color) -> some View {
        Text(s)
            .font(Theme.label(9)).tracking(1.4)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .foregroundColor(fg)
            .background(bg)
    }

    @ViewBuilder private var actionButton: some View {
        switch status {
        case .installed:
            Button(action: action) {
                Text("Re-deploy").font(Theme.label(11)).tracking(1.4)
                    .padding(.vertical, 8).padding(.horizontal, 14)
                    .foregroundColor(Theme.inkMute)
                    .overlay(Rectangle().strokeBorder(Theme.paperEdge, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(model.isBusy)
        case .working:
            EmptyView()
        default:
            Button(action: action) {
                Text("Install").font(Theme.label(11)).tracking(1.4)
                    .padding(.vertical, 8).padding(.horizontal, 14)
                    .foregroundColor(Theme.paper)
                    .background(Theme.ink)
            }
            .buttonStyle(.plain)
            .disabled(model.isBusy
                      || (model.deviceStatus != .online && model.deviceStatus != .authed))
        }
    }
}

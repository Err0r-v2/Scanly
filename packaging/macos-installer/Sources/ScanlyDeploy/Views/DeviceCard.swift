import SwiftUI

struct DeviceCard: View {
    @EnvironmentObject var model: InstallerModel

    var body: some View {
        HStack(spacing: 18) {
            tabletGlyph
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    Text("DEVICE")
                        .font(Theme.label(10)).tracking(2.0)
                        .foregroundColor(Theme.inkFaint)
                    pill
                }
                Text(model.host)
                    .font(Theme.display(22))
                    .foregroundColor(Theme.ink)
                Text(model.deviceMeta)
                    .font(Theme.body(12))
                    .foregroundColor(Theme.inkMute)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button(action: { model.showingPassword = true }) {
                Image(systemName: "key.fill")
                    .font(.system(size: 13))
                    .foregroundColor(model.password.isEmpty ? Theme.accent : Theme.inkMute)
                    .padding(10)
                    .overlay(Rectangle().strokeBorder(Theme.ink, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .help("Set developer password")
        }
        .padding(18)
        .background(Theme.paper)
        .overlay(Rectangle().strokeBorder(Theme.ink, lineWidth: 1))
    }

    // Hand-drawn tablet outline matching Scanly's Canvas-glyph idiom.
    private var tabletGlyph: some View {
        ZStack {
            // outer frame
            Rectangle()
                .strokeBorder(Theme.ink, lineWidth: 2)
                .frame(width: 56, height: 78)
            // screen inset
            Rectangle()
                .strokeBorder(Theme.inkMute, lineWidth: 1)
                .padding(.horizontal, 6)
                .padding(.vertical, 8)
                .frame(width: 56, height: 78)
        }
    }

    private var pill: some View {
        Text(pillText.uppercased())
            .font(Theme.label(9)).tracking(1.6)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .foregroundColor(pillFg)
            .background(pillBg)
    }

    private var pillText: String {
        switch model.deviceStatus {
        case .unknown:      return "scanning"
        case .offline:      return "offline"
        case .online:       return "online"
        case .authChecking: return "authenticating"
        case .authed:       return "ready"
        case .authFailed:   return "auth failed"
        }
    }
    private var pillBg: Color {
        switch model.deviceStatus {
        case .offline, .unknown: return Theme.paperDeep
        case .online:            return Theme.highlight.opacity(0.18)
        case .authChecking:      return Theme.paperDeep
        case .authed:            return Theme.ink
        case .authFailed:        return Theme.accent.opacity(0.18)
        }
    }
    private var pillFg: Color {
        switch model.deviceStatus {
        case .authed:            return Theme.paper
        case .authFailed:        return Theme.accent
        default:                 return Theme.inkMute
        }
    }
    private var dotColor: Color {
        switch model.deviceStatus {
        case .offline, .unknown: return Theme.paperEdge
        case .authFailed:        return Theme.accent
        default:                 return Theme.ink
        }
    }
}

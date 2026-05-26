import SwiftUI

struct NoticeBanner: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Rectangle().strokeBorder(Theme.highlight, lineWidth: 1.5)
                    .frame(width: 28, height: 28)
                Text("!")
                    .font(Theme.display(18, weight: .bold))
                    .foregroundColor(Theme.highlight)
            }
            Text(text)
                .font(Theme.body(13))
                .foregroundColor(Theme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Theme.highlight.opacity(0.10))
        .overlay(Rectangle().strokeBorder(Theme.highlight.opacity(0.5), lineWidth: 1))
    }
}

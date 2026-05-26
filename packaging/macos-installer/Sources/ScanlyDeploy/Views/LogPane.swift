import SwiftUI

struct LogPane: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("CONSOLE").font(Theme.label(10)).tracking(2.0)
                    .foregroundColor(Theme.inkFaint)
                Rectangle().fill(Theme.paperEdge).frame(height: 1)
            }
            ScrollViewReader { proxy in
                ScrollView {
                    HStack {
                        Text(text.isEmpty ? ", " : text)
                            .font(Theme.code(11))
                            .foregroundColor(Theme.inkSoft)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .id("logtail")
                        Spacer(minLength: 0)
                    }
                }
                .background(Theme.paper)
                .overlay(Rectangle().strokeBorder(Theme.ink, lineWidth: 1))
                .onChange(of: text) { _ in
                    proxy.scrollTo("logtail", anchor: .bottom)
                }
            }
        }
    }
}

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: InstallerModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            Theme.paper.ignoresSafeArea()
            HStack(spacing: 0) {
                leftPane
                    .frame(width: 540)
                    .padding(.horizontal, 44)
                    .padding(.top, 56)
                    .padding(.bottom, 28)
                Divider().background(Theme.paperEdge)
                rightPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.paperDeep)
            }
        }
        .task { await model.probe() }
        .sheet(isPresented: $model.showingPassword) { passwordSheet }
    }

    private var leftPane: some View {
        VStack(alignment: .leading, spacing: 32) {
            header
            DeviceCard()
            stepsBlock
            Spacer(minLength: 0)
            primaryAction
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SCANLY · DEPLOY")
                .font(Theme.label(11))
                .tracking(2.4)
                .foregroundColor(Theme.inkFaint)
            Text("Install on a fresh RMPP")
                .font(Theme.display(38, weight: .regular))
                .foregroundColor(Theme.ink)
                .lineSpacing(2)
            Text("Bootstraps XOVI · AppLoad · Scanly · no command line required.")
                .font(Theme.body(13))
                .foregroundColor(Theme.inkMute)
                .padding(.top, 4)
        }
    }

    private var stepsBlock: some View {
        VStack(spacing: 0) {
            StepRow(index: 1, title: "XOVI",
                    subtitle: "The hook that lets third-party apps run alongside the official UI.",
                    eta: "2-3 min",
                    status: model.xoviStatus) {
                Task { await model.installXOVI() }
            }
            Divider().background(Theme.paperEdge).padding(.leading, 56)
            StepRow(index: 2, title: "AppLoad",
                    subtitle: "Adds Scanly's tile to your home screen, like a normal app.",
                    eta: "10 s",
                    status: model.appLoadStatus) {
                Task { await model.installAppLoad() }
            }
            Divider().background(Theme.paperEdge).padding(.leading, 56)
            StepRow(index: 3, title: "Scanly",
                    subtitle: "The manga reader itself. Tap its tile to open.",
                    eta: "10 s",
                    status: model.scanlyStatus) {
                Task { await model.installScanly() }
            }
        }
        .background(Theme.paper)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(Theme.ink, lineWidth: 1)
        )
    }

    private var primaryAction: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Button(action: { Task { await model.installEverythingNeeded() } }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.to.line")
                        Text("Install everything missing")
                            .tracking(1.5)
                    }
                    .font(Theme.label(12))
                    .padding(.vertical, 14)
                    .padding(.horizontal, 22)
                    .background(actionEnabled ? Theme.ink : Theme.paperEdge)
                    .foregroundColor(Theme.paper)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!actionEnabled)

                Button(action: { Task { await model.probe() } }) {
                    Text("Re-scan")
                        .font(Theme.label(12))
                        .tracking(1.5)
                        .foregroundColor(Theme.ink)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 22)
                        .background(Theme.paper)
                        .contentShape(Rectangle())
                        .overlay(Rectangle().strokeBorder(Theme.ink, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(model.deviceStatus == .offline)

                Button(action: { Task { await model.restartXochitl() } }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11))
                        Text("Restart XOVI")
                            .tracking(1.5)
                    }
                    .font(Theme.label(12))
                    .foregroundColor(Theme.ink)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)
                    .background(Theme.paper)
                    .contentShape(Rectangle())
                    .overlay(Rectangle().strokeBorder(Theme.ink, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(model.deviceStatus == .offline || model.isBusy)
            }
            Text("Restart XOVI - in case AppLoad doesn't appear after install.")
                .font(Theme.body(11))
                .foregroundColor(Theme.inkFaint)
                .padding(.leading, 2)
        }
    }

    private var actionEnabled: Bool {
        (model.deviceStatus == .online || model.deviceStatus == .authed)
            && !model.isBusy
    }

    private var rightPane: some View {
        VStack(spacing: 16) {
            if let notice = model.notice {
                NoticeBanner(text: notice)
            }
            LogPane(text: model.log)
        }
        .padding(28)
    }

    private var cornerMark: some View {
        Group {
            if let icon = NSImage(named: "AppIcon") {
                Image(nsImage: icon)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 32, height: 32)
            } else {
                Rectangle().fill(Theme.ink).frame(width: 16, height: 16)
            }
        }
    }

    private var passwordSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DEVELOPER PASSWORD")
                    .font(Theme.label(10)).tracking(2.0)
                    .foregroundColor(Theme.inkFaint)
                Text("Read it off the tablet.")
                    .font(Theme.display(22))
                    .foregroundColor(Theme.ink)
            }

            instructionsBlock

            SecureField("•••••••••••", text: $model.password)
                .textFieldStyle(.plain)
                .font(Theme.code(14))
                .padding(12)
                .background(Theme.paperDeep)
                .overlay(Rectangle().strokeBorder(Theme.ink, lineWidth: 1))

            HStack(spacing: 12) {
                Link(destination: URL(string:
                    "https://support.remarkable.com/s/article/Developer-mode")!) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 11))
                        Text("OFFICIAL DOCS")
                            .font(Theme.label(10)).tracking(1.6)
                    }
                    .foregroundColor(Theme.inkMute)
                }
                Spacer()
                Button("Cancel") {
                    model.showingPassword = false
                }
                .buttonStyle(.plain)
                .font(Theme.label(12))
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .foregroundColor(Theme.inkMute)
                Button("Continue") {
                    model.showingPassword = false
                    Task { await model.probe() }
                }
                .buttonStyle(.plain)
                .font(Theme.label(12)).tracking(1.5)
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background(model.password.isEmpty ? Theme.paperEdge : Theme.ink)
                .foregroundColor(Theme.paper)
                .disabled(model.password.isEmpty)
            }
        }
        .padding(28)
        .frame(width: 520)
        .background(Theme.paper)
    }

    private var instructionsBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            instructionStep(
                n: 1,
                title: "Enable Developer Mode",
                path: "Settings → General → Paper Tablet → Software → Advanced → Developer Mode",
                note: "Toggle ON, accept the warning. The tablet reboots into developer mode."
            )
            instructionStep(
                n: 2,
                title: "Plug the tablet in",
                path: "USB-C cable.",
                note: "The installer reaches the device at 10.11.99.1 over the USB-Ethernet link."
            )
            instructionStep(
                n: 3,
                title: "Read the password",
                path: "Settings → Help → Copyrights and licenses",
                note: "Scroll to the very bottom, the root password is printed there."
            )
        }
        .padding(14)
        .background(Theme.paperDeep)
        .overlay(Rectangle().strokeBorder(Theme.paperEdge, lineWidth: 1))
    }

    private func instructionStep(n: Int, title: String, path: String, note: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Rectangle().strokeBorder(Theme.ink, lineWidth: 1)
                    .frame(width: 22, height: 22)
                Text("\(n)").font(Theme.display(13, weight: .medium))
                    .foregroundColor(Theme.ink)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(Theme.label(10)).tracking(1.6)
                    .foregroundColor(Theme.ink)
                Text(path)
                    .font(Theme.code(11))
                    .foregroundColor(Theme.inkSoft)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                Text(note)
                    .font(Theme.body(11))
                    .foregroundColor(Theme.inkMute)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

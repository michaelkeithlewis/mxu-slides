import PresenterCore
import SwiftUI

/// Top-bar timecode reader: the incoming timecode, coloured by lock state.
/// Shown when a timecode input is chosen; View > Show Timecode in Top Bar hides it.
struct TimecodeChip: View {
    static let visibleKey = "shell.timecodeChipVisible"

    let follower: TimecodeFollower

    @Environment(\.openSettings) private var openSettings

    var body: some View {
        let reading = follower.timecodeReading
        let status = TimecodeFollower.status(reading, follows: follower.follows, noTimecode: follower.noTimecode)
        let tint = tint(reading)
        Button {
            SettingsRouter.shared.pending = .midi
            openSettings()
        } label: {
            HStack(spacing: 5) {
                Circle()
                    .fill(tint ?? Color.secondary.opacity(0.5))
                    .frame(width: 6, height: 6)
                Text(reading.label.map { $0.text(dropFrame: reading.rate == .fps2997DropFrame) } ?? "--:--:--:--")
                    .font(.system(size: 11, weight: .medium).monospacedDigit())
                    .foregroundStyle(tint == nil ? Color.secondary : Color.primary)
                    .fixedSize()
            }
            .headerItemLabel()
        }
        .buttonStyle(.plain)
        .headerItemBackground(tint: tint)
        .help("Timecode: \(status.word). Click for timecode settings.")
        .accessibilityLabel("Timecode")
        .accessibilityValue(status.word)
    }

    private func tint(_ reading: TimecodeClock.Reading) -> Color? {
        if follower.noTimecode || follower.problem != nil { return .red }
        switch reading.state {
        case .locked: return .green
        case .freewheel: return .orange
        default: return nil
        }
    }
}

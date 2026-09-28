import SwiftUI

/// Stagger words received together; single streamed words arrive immediately without replaying earlier words.
struct WordReveal: View {
    let text: String
    let animate: Bool
    let accent: Color
    var streaming = false
    @State private var words: [String] = []
    @State private var batchStart = 0
    @State private var batchSize = 0
    private var interval: Double { min(0.12, 1.2 / Double(max(batchSize - 1, 1))) }

    var body: some View {
        CenteredWords(spacing: ReplyText.containsChinese(text) ? 0 : 7) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                ArrivingWord(text: word, animate: animate, accent: accent,
                             delay: Double(max(0, index - batchStart)) * interval,
                             breathing: streaming && index == words.count - 1)
            }
        }
        .font(OracleTypography.serif(.title2, text: text))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
        .accessibilityIdentifier("answer")
        .onChange(of: text, initial: true) { _, value in
            let received = ReplyText.units(value)
            batchStart = min(words.count, received.count)
            batchSize = received.count - batchStart
            words = received
        }
        .onChange(of: streaming) { old, new in
            if old && !new && UIAccessibility.isVoiceOverRunning {
                UIAccessibility.post(notification: .announcement, argument: text)
            }
        }
    }
}

private struct ArrivingWord: View {
    let text: String
    let animate: Bool
    let accent: Color
    let delay: Double
    let breathing: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var arrived = false
    @State private var glow = false
    var body: some View {
        Text(text)
            .foregroundStyle(Palette.ink)
            .opacity(arrived || !animate || reduceMotion ? 1 : 0)
            .offset(y: arrived || !animate || reduceMotion ? 0 : 4)
            .blur(radius: arrived || !animate || reduceMotion ? 0 : 2)
            .shadow(color: accent.opacity(glow ? 0.9 : 0), radius: 9)
            .modifier(EchoBreath(accent: accent, active: breathing))
            .task {
                guard animate && !reduceMotion else { arrived = true; return }
                // Capture this batch's delay once; later prefixes must not reschedule this word.
                let arrivalDelay = delay
                do { if arrivalDelay > 0 { try await Task.sleep(for: .seconds(arrivalDelay)) } }
                catch { return }
                glow = true
                withAnimation(.easeOut(duration: 0.24)) { arrived = true }
                do { try await Task.sleep(for: .milliseconds(220)) } catch { return }
                withAnimation(.easeOut(duration: 0.4)) { glow = false }
            }
    }
}

struct EchoBreath: ViewModifier {
    let accent: Color
    let active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ViewBuilder func body(content: Content) -> some View {
        if active && !reduceMotion {
        content.phaseAnimator([false, true]) { view, raised in
            view
                .offset(y: active && !reduceMotion && raised ? -2 : 0)
                .shadow(color: accent.opacity(active ? (raised && !reduceMotion ? 0.7 : 0.35) : 0),
                        radius: raised && !reduceMotion ? 9 : 4)
        } animation: { _ in .easeInOut(duration: 1.8) }
        } else {
            content.shadow(color: active ? accent.opacity(0.35) : .clear, radius: 4)
        }
    }
}

/// Wrap only received words; stable token identities preserve their arrival state.
struct CenteredWords: Layout {
    var spacing: CGFloat = 7
    private struct Row { var indices: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }
    private func rows(_ subviews: Subviews, width: CGFloat) -> [Row] {
        var output: [Row] = []
        var row = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.init(width: width, height: nil))
            if !row.indices.isEmpty && row.width + spacing + size.width > width {
                output.append(row); row = Row()
            }
            if !row.indices.isEmpty { row.width += spacing }
            row.indices.append(index)
            row.width += min(size.width, width)
            row.height = max(row.height, size.height)
        }
        if !row.indices.isEmpty { output.append(row) }
        return output
    }
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        let lines = rows(subviews, width: width)
        return .init(width: width, height: lines.reduce(0) { $0 + $1.height } + CGFloat(max(lines.count - 1, 0)) * 8)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(subviews, width: bounds.width) {
            var x = bounds.midX - row.width / 2
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.init(width: bounds.width, height: nil))
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: .init(width: min(size.width, bounds.width), height: size.height))
                x += min(size.width, bounds.width) + spacing
            }
            y += row.height + 8
        }
    }
}

import SwiftUI

struct MultiThumbSlider: View {
    @Binding var values: [Double]                 // normalized or domain values
    let bounds: ClosedRange<Double>               // e.g., 0...1 or 0...100
    let minSeparation: Double                     // e.g., 0.05 in [0,1] space
    let step: Double?                             // set nil for continuous
    let trackHeight: CGFloat = 6
    let thumbDiameter: CGFloat = 28

    var body: some View {
        GeometryReader { geo in
            let w = max(geo.size.width - thumbDiameter, 1) // leave room for thumb radius
            ZStack {
                Capsule()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(height: trackHeight)
                    .frame(maxHeight: .infinity, alignment: .center)

                ForEach(values.indices, id: \.self) { i in
                    let x = xPosition(for: values[i], width: w)
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: thumbDiameter, height: thumbDiameter)
                        .shadow(radius: 1)
                        .position(x: x + thumbDiameter / 2, y: geo.size.height / 2)
                        .gesture(dragGesture(index: i, trackWidth: w))
                        .accessibilityLabel("Threshold \(i + 1)")
                        .accessibilityValue(Text(String(format: "%.3f", values[i])))
                }
            }
            .padding(.horizontal, thumbDiameter / 2)
        }
        .frame(height: max(thumbDiameter, trackHeight))
    }

    private func dragGesture(index: Int, trackWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { g in
                let localX = max(0, min(trackWidth, g.location.x - thumbDiameter / 2))
                var newValue = value(forX: localX, width: trackWidth)

                // snapping
                if let step, step > 0 {
                    newValue = (newValue / step).rounded() * step
                }

                // enforce ordering and min separation
                let lower = index == 0
                    ? bounds.lowerBound
                    : values[index - 1] + minSeparation
                let upper = index == values.count - 1
                    ? bounds.upperBound
                    : values[index + 1] - minSeparation

                values[index] = min(max(newValue, lower), upper)
            }
    }

    // Mapping
    private func xPosition(for value: Double, width: CGFloat) -> CGFloat {
        let t = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return CGFloat(t) * width
    }

    private func value(forX x: CGFloat, width: CGFloat) -> Double {
        let t = Double(x / max(width, 1))
        return bounds.lowerBound + t * (bounds.upperBound - bounds.lowerBound)
    }
}

// Example usage
struct ContentView: View {
    @State private var thresholds: [Double] = [0.1, 0.3, 0.6, 0.8]

    var body: some View {
        VStack(spacing: 24) {
            MultiThumbSlider(
                values: $thresholds,
                bounds: 0...1,
                minSeparation: 0.05,
                step: 0.01
            )
            Text(thresholds.map { String(format: "%.2f", $0) }.joined(separator: ", "))
                .monospaced()
        }
        .padding()
    }
}

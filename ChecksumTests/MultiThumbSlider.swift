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
                
                // For logarithmic scale, we need to adjust snapping to work in log space
                if let step, step > 0 {
                    // Convert step to log space for consistent snapping
                    let logStep = log10(1 + step / bounds.lowerBound) // Relative step in log space
                    let logValue = log10(newValue / bounds.lowerBound)
                    let snappedLogValue = (logValue / logStep).rounded() * logStep
                    newValue = bounds.lowerBound * pow(10, snappedLogValue)
                }
                
                // enforce ordering and min separation (using proportional separation for log scale)
                let lower = index == 0
                ? bounds.lowerBound
                : values[index - 1] * (1 + minSeparation / bounds.lowerBound)
                let upper = index == values.count - 1
                ? bounds.upperBound
                : values[index + 1] / (1 + minSeparation / bounds.lowerBound)
                
                values[index] = min(max(newValue, lower), upper)
            }
    }
    
    // Logarithmic Mapping
    private func xPosition(for value: Double, width: CGFloat) -> CGFloat {
        // Convert to logarithmic space
        let logLower = log10(bounds.lowerBound)
        let logUpper = log10(bounds.upperBound)
        let logValue = log10(value)
        
        // Normalize in log space
        let t = (logValue - logLower) / (logUpper - logLower)
        return CGFloat(t) * width
    }
    
    private func value(forX x: CGFloat, width: CGFloat) -> Double {
        // Normalize position to [0,1]
        let t = Double(x / max(width, 1))
        
        // Convert to logarithmic space
        let logLower = log10(bounds.lowerBound)
        let logUpper = log10(bounds.upperBound)
        let logValue = logLower + t * (logUpper - logLower)
        
        // Convert back to linear space
        return pow(10, logValue)
    }


    // Helper function to format bytes in human-readable format
    static func formatBytes(_ bytes: Double) -> String {
        let units = ["B", "KB", "MB", "GB"]
        let log = log10(bytes)
        let unitIndex = Int(log / 3)
        let unit = units[min(unitIndex, units.count - 1)]
        let value = bytes / pow(1000, Double(unitIndex))
        return String(format: "%.0f %@", value, unit)
    }
}


//// Example usage
#Preview {
    @Previewable @State var thresholds: [Double] = [512, 8192, 1048576, 268435456, 17179869184]

    VStack(spacing: 24) {
        MultiThumbSlider(
            values: $thresholds,
            bounds: 512...17179869184, // 512 bytes to 16 GB
            minSeparation: 64,         // Smaller separation for log scale
            step: nil                  // No stepping for smooth log scale
        )
        VStack(spacing: 8) {
            Text("Values:")
                .font(.headline)
            Text(thresholds.map { MultiThumbSlider.formatBytes($0) }.joined(separator: ", "))
                .monospaced()
                .font(.caption)
        }
        }
        .padding()
}



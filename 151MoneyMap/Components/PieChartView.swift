//
//  PieChartView.swift
//  151MoneyMap
//

import SwiftUI

struct PieChartView: View {
    let data: [(category: TransactionCategory, amount: Double)]

    private let sliceColors: [Color] = [.moneyExpense, .moneyIncome, .moneyAccent, .orange, .purple, .pink]

    var body: some View {
        let total = data.reduce(0) { $0 + $1.amount }

        ZStack {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let startAngle = angleFor(index: index, total: total)
                let endAngle = angleFor(index: index + 1, total: total)

                PieSlice(startAngle: startAngle, endAngle: endAngle)
                    .fill(sliceColors[index % sliceColors.count])
            }

            VStack {
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(formatCurrency(total))
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
            }
        }
    }

    private func angleFor(index: Int, total: Double) -> Angle {
        guard total > 0 else { return .zero }
        let cumulative = data.prefix(index).reduce(0) { $0 + $1.amount }
        let percentage = cumulative / total
        return Angle(degrees: percentage * 360)
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
        path.closeSubpath()
        return path
    }
}

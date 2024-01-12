//
//  ContentView.swift
//  Timelines
//
//  Created by Connor McClanahan on 05/12/2023.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        CircularWheelView(categories: ["Category 1", "Category 2", "Category 3", "Category 4", "Category 5", "Category 6", "Category 7", "Category 8", "Category 9", "Category 10"])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct CircularWheelView: View {
    let categories: [String]
    @State private var rotation: Angle = .zero
    @State private var selectedCategoryIndex: Int = 0
    @State private var circlePatterns: [String: [(CGPoint, CGPoint)]] = [:]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(categories[selectedCategoryIndex])
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                RandomCirclesView(pattern: circlePatterns[categories[selectedCategoryIndex], default: []])
                    .frame(height: geometry.size.height / 3)

                Spacer(minLength: geometry.size.width / 2)

                ZStack {
                    ForEach(0..<categories.count, id: \.self) { index in
                        CategoryView(label: categories[index], isSelected: index == selectedCategoryIndex)
                            .frame(width: geometry.size.width / CGFloat(categories.count), height: 50)
                            .offset(y: -geometry.size.width / 2)
                            .rotationEffect(Angle(degrees: Double(index) * (360 / Double(categories.count))))
                            .onTapGesture {
                                selectedCategoryIndex = index
                                updateRotation()
                                generatePatternForCategory(index)
                            }
                    }
                    ArrowIndicatorView()
                        .frame(width: 30, height: 15)
                }
                .frame(width: geometry.size.width, height: geometry.size.width)
                .rotationEffect(rotation)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let vector = CGVector(dx: gesture.location.x - geometry.size.width / 2, dy: gesture.location.y - geometry.size.width / 2)
                            let angle = atan2(vector.dy, vector.dx)
                            rotation = Angle(radians: Double(angle))
                            updateSelectedCategory()
                            generatePatternForCategory(selectedCategoryIndex)
                        }
                )
                .offset(y: geometry.size.width / 4)
            }
        }
        .onAppear {
            categories.forEach { category in
                circlePatterns[category] = generateRandomPattern()
            }
        }
    }

    private func updateSelectedCategory() {
        let total = categories.count
        let degreesPerCategory = 360 / total
        let currentRotation = Int(rotation.degrees) % 360
        let offsetIndex = Int((Double(currentRotation) / Double(degreesPerCategory)).rounded())
        selectedCategoryIndex = (total - offsetIndex) % total
    }

    private func updateRotation() {
        let degreesPerCategory = 360 / Double(categories.count)
        rotation = Angle(degrees: Double(selectedCategoryIndex) * degreesPerCategory)
    }

    private func generatePatternForCategory(_ index: Int) {
        let category = categories[index]
        circlePatterns[category] = generateRandomPattern()
    }

    private func generateRandomPattern() -> [(CGPoint, CGPoint)] {
        var pattern: [(CGPoint, CGPoint)] = []
        let numberOfLines = Int.random(in: 1...4)
        for _ in 0..<numberOfLines {
            let startPoint = CGPoint(x: CGFloat.random(in: 0...300), y: CGFloat.random(in: 0...300))
            let endPoint = CGPoint(x: CGFloat.random(in: 0...300), y: CGFloat.random(in: 0...300))
            pattern.append((startPoint, endPoint))
        }
        return pattern
    }
}

struct RandomCirclesView: View {
    var pattern: [(CGPoint, CGPoint)]

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for line in pattern {
                    let startPoint = CGPoint(x: line.0.x * size.width / 300, y: line.0.y * size.height / 300)
                    let endPoint = CGPoint(x: line.1.x * size.width / 300, y: line.1.y * size.height / 300)
                    context.stroke(Path { path in
                        path.move(to: startPoint)
                        path.addLine(to: endPoint)
                    }, with: .color(.black), lineWidth: 2)

                    context.fill(Path(ellipseIn: CGRect(center: startPoint, size: CGSize(width: 30, height: 30))), with: .color(.black))
                    context.fill(Path(ellipseIn: CGRect(center: endPoint, size: CGSize(width: 30, height: 30))), with: .color(.black))
                }
            }
        }
    }
}

struct CategoryView: View {
    var label: String
    var isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.blue : Color.gray)
                .opacity(isSelected ? 1.0 : 0.5)
            Text(label)
                .foregroundColor(.white)
                .padding(.horizontal, 50)
        }
    }
}

struct ArrowIndicatorView: View {
    var body: some View {
        Triangle()
            .fill(Color.red)
            .frame(width: 30, height: 15)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

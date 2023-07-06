//
//  CDView.swift
//  CD
//
//  Created by Daniel Kuntz on 7/3/23.
//

import SwiftUI

struct ShapeWithHole: Shape {
    let cutout: CGSize
    
    func path(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)
        let hole = Circle().path(in: CGRect(origin: CGPoint(x: rect.midX - cutout.width / 2, y: rect.midY - cutout.height / 2), size: cutout)).reversed
        path.addPath(hole)
        return path
    }
}

extension Path {
    var reversed: Path {
        let reversedCGPath = UIBezierPath(cgPath: cgPath)
            .reversing()
            .cgPath
        return Path(reversedCGPath)
    }
}

struct CircularTextView: View {
    var title: String
    var radius: Double

    @State private var letterWidths: [Int:Double] = [:]

    var lettersOffset: [(offset: Int, element: Character)] {
        return Array(title.enumerated())
    }

    var body: some View {
        ZStack {
            ForEach(lettersOffset, id: \.offset) { index, letter in // Mark 1
                VStack {
                    Text(String(letter))
                        .font(.system(size: 5, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow)
                        .kerning(5)
                        .background(LetterWidthSize()) // Mark 2
                        .onPreferenceChange(WidthLetterPreferenceKey.self, perform: { width in  // Mark 2
                            letterWidths[index] = width
                        })
                    Spacer() // Mark 1
                }
                .rotationEffect(fetchAngle(at: index)) // Mark 3
            }
        }
        .frame(width: 107, height: 107)
        .rotationEffect(.degrees(280))
    }

    func fetchAngle(at letterPosition: Int) -> Angle {
        let times2pi: (Double) -> Double = { $0 * 2 * .pi }

        let circumference = times2pi(radius)

        let finalAngle = times2pi(letterWidths.filter{$0.key <= letterPosition}.map(\.value).reduce(0, +) / circumference)

        return .radians(finalAngle)
    }
}

struct WidthLetterPreferenceKey: PreferenceKey {
    static var defaultValue: Double = 0
    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = nextValue()
    }
}

struct LetterWidthSize: View {
    var body: some View {
        GeometryReader { geometry in
            Color
                .clear
                .preference(key: WidthLetterPreferenceKey.self,
                            value: geometry.size.width)
        }
    }
}

struct CDView: View {
    let size: CGFloat = 350.0
    @StateObject private var manager = MotionManager()
    @State private var p: CGFloat = 0.42
    @State private var timer: Timer?

    private let shaderFunction = ShaderFunction(library: .default, name: "cd")

    var body: some View {
        ZStack {
            Color(white: 0.0)

            Circle()
                .frame(width: size - 50.0, height: size - 50.0)
                .foregroundColor(.white)
                .clipShape(ShapeWithHole(cutout: CGSize(width: 200.0, height: 200.0)))
                .blur(radius: 50.0)
                .opacity(0.5)
                .offset(x: manager.roll * -80.0, y: manager.pitch * 80.0)

            ZStack {
                Group {
                    Circle()
                        .foregroundColor(.white.opacity(0.3))
                        .frame(width: size+12, height: size+12)
                        .clipShape(ShapeWithHole(cutout: CGSize(width: 150.0, height: 150.0)))
                        .shadow(color: .black, radius: 5)

                    Circle()
                        .foregroundColor(Color.black.opacity(0.9))
                        .frame(width: size+4, height: size+4)
                        .clipShape(ShapeWithHole(cutout: CGSize(width: 110.0, height: 110.0)))

                    Circle()
                        .foregroundColor(.white.opacity(0.15))
                        .frame(width: size+12, height: size+12)
                        .clipShape(ShapeWithHole(cutout: CGSize(width: 40.0, height: 40.0)))

                    Circle()
                        .stroke(Color.black.opacity(0.9), lineWidth: 1.0)
                        .frame(width: size+12, height: size+12)

                    Circle()
                        .stroke(Color.black, lineWidth: 1.0)
                        .frame(width: 40.0, height: 40.0)

                    Circle()
                        .stroke(Color.black.opacity(0.2), lineWidth: 2.0)
                        .frame(width: 80.0, height: 80.0)

                    Circle()
                        .stroke(Color.black, lineWidth: 16.0)
                        .frame(width: 110.0, height: 110.0)
                }

                Circle()
                    .foregroundColor(.white)
                    .frame(width: size+12, height: size+12)
                    .colorEffect(
                        Shader(function: shaderFunction,
                               arguments: [
                                .float2(Float(size),
                                        Float(size)),
                                .float((manager.pitch * 0.02) + 0.02)
                               ])
                    )
                    .blur(radius: 10.0)
                    .contrast(3.4)
                    .opacity(0.4)
                    .mask(Circle())
                    .clipShape(ShapeWithHole(cutout: CGSize(width: 110.0, height: 110.0)))

                Circle()
                    .foregroundColor(.white)
                    .frame(width: size+2, height: size+2)
                    .colorEffect(
                        Shader(function: shaderFunction,
                               arguments: [
                                .float2(Float(size),
                                        Float(size)),
                                .float((manager.pitch * 0.02) + 0.01)
                               ])
                    )
                    .blur(radius: 10.0)
                    .contrast(3.4)
                    .brightness(0.2)
                    .mask(Circle())
                    .clipShape(ShapeWithHole(cutout: CGSize(width: 110.0, height: 110.0)))

                Circle()
                    .foregroundColor(.white)
                    .frame(width: size, height: size)
                    .colorEffect(
                        Shader(function: shaderFunction,
                               arguments: [
                                .float2(Float(size),
                                        Float(size)),
                                .float(((manager.pitch + manager.roll + 0.4) * 0.06))
                               ])
                    )
                    .blur(radius: 28.0)
                    .contrast(3.7)
                    .mask(Circle())
                    .clipShape(ShapeWithHole(cutout: CGSize(width: 110.0, height: 110.0)))
                    .rotationEffect(.degrees((manager.pitch + manager.roll) * 20.0))

                Circle()
                    .stroke(Color.black.opacity(0.5), lineWidth: 1.0)
                    .frame(width: 117.0, height: 117.0)

                CircularTextView(title: "SWIFT.SHADER", radius: 80.0)
                    .rotationEffect(.degrees((manager.pitch + manager.roll)*20.0))
            }
            .drawingGroup()
            .rotation3DEffect(.degrees(manager.pitch * 20.0), axis: (1, 0, 0))
            .rotation3DEffect(.degrees(manager.roll * 20.0), axis: (0, 1, 0))
            .gesture(DragGesture().onChanged({ gesture in
                manager.pitch = gesture.translation.height / 100
                manager.roll = gesture.translation.width / 100
            }))

            VStack {
                Spacer()
                Text(String(manager.pitch))
                Text(String(manager.roll))
                Text(String(((manager.pitch + manager.roll) * 0.02) - 0.01))
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
    }
}

#Preview {
    CDView()
}

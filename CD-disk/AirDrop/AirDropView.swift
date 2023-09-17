//
//  ContentView.swift
//  Airdrop Demo
//
//  Created by Daniel Kuntz on 7/30/23.
//

import SwiftUI

struct AirDropView: View {

    @State private var timer: Timer?
    @State private var t: Float = 0.0

    private let shaderFunction = ShaderFunction(library: .default, name: "airdrop")

    var body: some View {
        VStack {
            Image("Fadi Avada")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(x: 1.0, y: -1.0)
                .layerEffect(
                    Shader(function: shaderFunction,
                           arguments: [
                            .float(t),
                            .float2(Float(UIScreen.main.bounds.width),
                                    Float(UIScreen.main.bounds.height))
                           ]), maxSampleOffset: CGSize(width: 800.0, height: 800.0)
                )
        }
        .ignoresSafeArea()
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                t = (t + 0.01).truncatingRemainder(dividingBy: 2.0)
            })
        }
    }
}

#Preview {
    AirDropView()
}

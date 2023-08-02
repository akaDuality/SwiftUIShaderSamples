//
//  Badge.swift
//  CD-disk
//
//  Created by Mikhail Rubanov on 07.07.2023.
//

import SwiftUI

#Preview {
    Badge()
}

struct Badge: View {
    let size: CGFloat = 350.0
    @State private var p: CGFloat = 0.42
    @State private var timer: Timer?
    
    @State private var vOffset: CGFloat = 1
    private let shaderFunction = ShaderFunction(library: .default, name: "cd")
    
    let startDate = Date()
    var body: some View {
        ZStack {
            Color(white: 0.0)
            
            TimelineView(.animation) { _ in
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: size+12, height: size+12)
                    .colorEffect(
                        ShaderLibrary.animatedGradient(.float2(Float(size),
                                                    Float(size)),
                                            .float(startDate.timeIntervalSinceNow)
                        )
                    )
                    .drawingGroup()
                    .gesture(DragGesture().onChanged({ gesture in
                        vOffset = gesture.translation.height / 100
                    }))
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
    }
}

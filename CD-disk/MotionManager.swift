//
//  MotionManager.swift
//  CD
//
//  Created by Daniel Kuntz on 7/3/23.
//

import SwiftUI
import CoreMotion

final class MotionManager: ObservableObject {
    @Published var pitch: Double = 0.3
    @Published var roll: Double = 0.3

    private var manager: CMMotionManager

    init() {
        self.manager = CMMotionManager()
        self.manager.deviceMotionUpdateInterval = 1/60
        self.manager.startDeviceMotionUpdates(to: .main) { [weak self] (motionData, error) in
            guard error == nil else {
                print(error!)
                return
            }

            if let motionData = motionData {
                self?.pitch = motionData.attitude.pitch
                self?.roll = motionData.attitude.roll
            }
        }
    }
}

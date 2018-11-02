//
//  MotionManager.swift
//  ARKitDemo
//
//  Created by Nathan Lamb on 10/24/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import Foundation
import CoreMotion
import Accelerate

// Watches the stability of the device
class MotionManager: CMMotionManager {
    let motion = CMMotionManager()
    var timer: Timer?

    // Gyroscope coordinates
    private var x = [Double]()
    private var y = [Double]()
    private var z = [Double]()
    
    // Determines if phone is stable or moving
    func isStable() -> Bool {

        var xMean: Double = 0.0
        var xSDev: Double = 0.0

        var yMean: Double = 0.0
        var ySDev: Double = 0.0

        var zMean: Double = 0.0
        var zSDev: Double = 0.0

        // Gets the standard deviation of the last 20 location points of the gyroscope
        vDSP_normalizeD(x, 1, nil, 1, &xMean, &xSDev, vDSP_Length(x.count))
        vDSP_normalizeD(y, 1, nil, 1, &yMean, &ySDev, vDSP_Length(y.count))
        vDSP_normalizeD(z, 1, nil, 1, &zMean, &zSDev, vDSP_Length(z.count))

        // If the standard deviations is less than 0.1, the phone is stable
        return xSDev + ySDev + zSDev < 0.1
    }

    // Begins capturing the phones gyroscope coordinates, saves the last 60 values from past second
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        guard self.motion.isAccelerometerAvailable else { return }
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
            
            // Captures the gyroscope coordinates 60 times a second
            self.timer = Timer(fire: Date(), interval: 1.0 / 60.0, repeats: true) { [weak self] timer in
                // Get the accelerometer data.
                guard
                    let `self` = self,
                    let data = self.motion.accelerometerData
                    else { return }
                self.x.append(data.acceleration.x)
                self.y.append(data.acceleration.y)
                self.z.append(data.acceleration.z)
                
                // These counts should be the same
                assert(self.x.count == self.y.count && self.y.count == self.z.count)
                
                // Ensures we only have 60 capture points
                while self.x.count > 60 || self.y.count > 60 || self.z.count > 60 {
                    self.x.removeFirst()
                    self.y.removeFirst()
                    self.z.removeFirst()
                }
                
                // The counts should still be the same and now less than or equal to 60
                assert(self.x.count == self.y.count && self.y.count == self.z.count && self.z.count <= 60)
            }
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
        }
    }
}

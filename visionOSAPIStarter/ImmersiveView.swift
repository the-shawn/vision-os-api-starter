//
//  ImmersiveView.swift
//  visionOSAPIStarter
//
//  Created by Nien Lam on 10/19/23.
//  Copyright © 2023 Line Break, LLC. All rights reserved.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State var viewModel: ViewModel
    
    let sphere = SphereEntity(name: "sphere", radius: 0.5, imageName: "checker.png")

    let box = BoxEntity(name: "box", width: 0.8, height: 0.8, depth: 0.8, imageName: "checker.png")

    var body: some View {
        RealityView { content in
            // Position and add sphere to scene.
            sphere.position.x = -0.6
            sphere.position.y = 0.5
            sphere.position.z = -1.7
            content.add(sphere)

            // Position and add box to scene.
            box.position.x = 0.6
            box.position.y = 0.4
            box.position.z = -1.7
            content.add(box)

        } update: { content in
            // Scale sphere up and down.
            let scale = viewModel.sliderValue * 2
            sphere.scale = [scale, scale, scale]

            // Add/remove spiral staircase.
            box.children.removeAll()
            var lastBoxEntity = box
            for _ in 0..<Int(viewModel.sliderValue * 10) {
                // Create and position new entity.
                let newEntity = lastBoxEntity.clone(recursive: false)
                newEntity.position.x = 0.8
                newEntity.position.y = 0.3
                newEntity.position.z = 0

                // Rotate on y-axis by 45 degrees.
                newEntity.orientation = simd_quatf(angle: .pi / 4, axis: [0, 1, 0])

                // Add to last entity in tree.
                lastBoxEntity.addChild(newEntity)
                
                // Set last entity used.
                lastBoxEntity = newEntity
            }
        }
    }
}

#Preview {
    ImmersiveView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}

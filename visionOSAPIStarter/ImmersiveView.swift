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

    var body: some View {
        RealityView { content in
            // Position and add sphere to scene.
            sphere.position.x = 0
            sphere.position.y = 0.5
            sphere.position.z = -1.7
            content.add(sphere)
            
        } update: { content in
            // Scale sphere up and down.
            let scale = viewModel.sliderValue * 2
            sphere.scale = [scale, scale, scale]
        }
    }
}

#Preview {
    ImmersiveView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}

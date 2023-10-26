//
//  visionOSAPIStarterApp.swift
//  visionOSAPIStarter
//
//  Created by Nien Lam on 10/19/23.
//  Copyright © 2023 Line Break, LLC. All rights reserved.
//

import SwiftUI

@main
struct visionOSAPIStarterApp: App {
    @State var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        WindowGroup(id: "origin") {
            OriginView()
        }
        WindowGroup(id: "render") {
            RenderView()
        }
        .defaultSize(CGSize(width: 400, height: 500))

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(viewModel: viewModel)
        }
    }
}

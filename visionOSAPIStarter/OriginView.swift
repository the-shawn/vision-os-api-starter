//
//  Created by Nien Lam on 10/5/23.
//  Copyright © 2023 Line Break, LLC. All rights reserved.
//

import SwiftUI
import RealityKit


struct OriginView: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 20) {
                VStack(spacing:20){
                    Image(uiImage: UIImage(named: "origin")!)
                        .resizable()
                        .frame(width: 300, height: 300)
                    
                    Button("Generate your dream product") {
                        openWindow(id: "render")
                    }
                    }
                }
            }
        }
    }


#Preview {
    OriginView()
}

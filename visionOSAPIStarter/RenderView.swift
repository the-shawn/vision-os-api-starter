//
//  Created by Nien Lam on 10/5/23.
//  Copyright © 2023 Line Break, LLC. All rights reserved.
//

import SwiftUI
import RealityKit


struct RenderView: View {
    
    
    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 20) {
                VStack(spacing:20){
                    Image(uiImage: UIImage(named: "rendered")!)
                        .resizable()
                        .frame(width: 300, height: 300)
                    }
                }
            }
        }
    }


#Preview {
    OriginView()
}

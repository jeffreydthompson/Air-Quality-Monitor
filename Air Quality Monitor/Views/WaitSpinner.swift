//
//  WaitSpinner.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/19/21.
//

import SwiftUI

struct WaitSpinner: View {
    
    @State var colorToggler: Bool = false
    @State var startAngle: CGFloat = 0.0
    @State var endAngle: CGFloat = 0.0
    
    private var color = Color(.sRGB, red: 0.2, green: 0.3, blue: 0.7, opacity: 1.0)
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let localSize = min(geometry.size.height, geometry.size.width)

            ZStack {
                
                Circle()
                    .stroke(colorToggler ? Color.gray : color, style: StrokeStyle(lineWidth: localSize * 0.3))
                
                Circle()
                    .trim(from: startAngle, to: endAngle)
                    .stroke(colorToggler ? color : Color.gray, style: StrokeStyle(lineWidth: localSize * 0.3, lineCap: .round))

            }
            .animation(Animation.spring(response: 1.0, dampingFraction: 1.0, blendDuration: 0.1).repeatForever(autoreverses: false))
            .onAppear() {
                endAngle = 1.0
                colorToggler.toggle()
            }
        }
    }
}

struct WaitSpinner_Previews: PreviewProvider {
    static var previews: some View {
        WaitSpinner().frame(width: 100, height: 100, alignment: .center)
    }
}

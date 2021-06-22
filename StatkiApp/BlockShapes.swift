//
//  BlockShapes.swift
//  STATKI_SwiftUI
//
//  Created by Peter A. Jankowski on 4/25/21.
//

import SwiftUI

struct CustomCapsule: Shape {
    
    var inset: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = (rect.height / 2) - inset
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let start = CGPoint(
            x: center.x - (rect.width/2) + inset + radius,
            y: center.y
        )
        let point1 = CGPoint(
            x: center.x + (rect.width/2) - inset,
            y: center.y + (rect.height/2) - inset
        )
        let point2 = CGPoint(
            x: center.x + (rect.width/2) - inset,
            y: center.y - (rect.height/2) + inset
        )
        let point3 = CGPoint(
            x: center.x - (rect.width/2) + inset + radius,
            y: center.y - (rect.height/2) + inset
        )
        
        var p = Path()
        p.addArc(center: start,
                 radius: radius,
                 startAngle: Angle.degrees(-90),
                 endAngle: Angle.degrees(-270),
                 clockwise: true)
        p.addLine(to: point1)
        p.addLine(to: point2)
        p.addLine(to: point3)
        return p
    }
}


struct MiddleBlock: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0).opacity(0)
            Rectangle().inset(by: 5).fill(Color.red)
        }
    }
}

struct EndBlock: View {
    let rotation: Angle
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0).opacity(0)
            CustomCapsule(inset: 5).rotation(rotation).fill(Color.red)
        }
    }
}

struct SingleBlock: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0).opacity(0)
            Circle().inset(by: 5).fill(Color.red)
        }
    }
}

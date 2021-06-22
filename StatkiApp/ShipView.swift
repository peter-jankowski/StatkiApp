//
//  ShipView.swift
//  STATKI_SwiftUI
//
//  Created by Peter A. Jankowski on 5/10/21.
//

import SwiftUI

struct Ship: View {
        
    @EnvironmentObject var viewModel: ViewModel
    
    var size: CGSize
    var horizOffset: Int
    var vertOffset: Int {
        return 4 - length
    }
    let length: Int
    var blocklength: CGFloat

    
    @State private var steadyStateOffset: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero
    
    private var offset: CGSize {
        steadyStateOffset + gestureOffset
    }
        
    @State private var shipOffset: CGSize = .zero
    @State var location: CGPoint
    
    @State private var rotation: Angle = .zero
    @State private var isDragging = false
    
    @State private var isRotated: Bool = false
    
    @State private var isRotating: Bool = false
    @State private var aboutToRotate: Bool = false
    
    @State private var blocklocations: [(Int,Int)] = []
    @State private var atstart: Bool = true
    @State private var wiggle: Bool = false
    @State private var wiggleAngle: Angle = .zero
    @State private var wiggleRotation: Angle = .zero
    
    
    private func roundlocation(point: CGPoint) -> (Int,Int) {
        let x = point.x
        let y = point.y
        let xround = Int(x / blocklength)
        let yround = Int(y / blocklength)
        return (yround,xround)
    }
    
    private func calculatecoord(point: CGPoint) -> (Int,Int) {
        let (yround,xround) = roundlocation(point: point)
        
        let x = (CGFloat(xround) * blocklength) + (0.5 * blocklength) - blocklength * CGFloat(point.x <= 0 ? 1 : 0)
                + (CGFloat(horizOffset) * blocklength)
        let y = (CGFloat(yround) * blocklength) + (0.5 * blocklength)
                - blocklength + (CGFloat(vertOffset) * blocklength)
        
        let xcoord = (x / blocklength)
        let ycoord = (y / blocklength) * -1
        
        let roundx = Int(floor(xcoord))
        let roundy = Int(floor(ycoord))
        
        return (9 - roundy, roundx)
    }
    
    private func checknowavesorships(point: CGPoint) -> Bool {
        let coords1 = calculatecoord(point: point)
        let emptyboard: [[Int]] = viewModel.emptyboard
        
        var pointsarray: [Int] = []
        
        for i in 0..<length {
            if coords1.1 + i < 10 {
                pointsarray.append(emptyboard[coords1.0][coords1.1 + i])
            } else {
                pointsarray.append(2)
            }
        }
        
        let result = pointsarray.allSatisfy { $0 == 0 }

        return result
    }
    
    private func offset_point_converter(offset: CGSize, length: Int, isRotated: Bool) -> (Int, Int) {
        
        let x = offset.width
        let y = offset.height
        
        let xround = Int(round(x / blocklength))
        let yround = Int(round(y / blocklength))
        
        var xshift = horizOffset - 1
        var yshift = 4 - length
        
        if isRotated && length == 4 {
            xshift += 1
            yshift -= 1
        }
        
        return (xround + xshift, 10 - ((yround + yshift) * -1))
    }
    
    private func lastpoint(point: (Int, Int), length: Int, isRotated: Bool) -> (Int, Int) {
        var x = point.0
        var y = point.1
        
        if isRotated {
            y += (length - 1)
        } else {
            x += (length - 1)
        }
        return (x,y)
    }
    
    private func listofpoints(point: (Int, Int), length: Int, isRotated: Bool) -> [(Int, Int)] {
        var list:[(Int, Int)] = []
        
        var x = point.0
        var y = point.1
        
        if isRotated {
            for _ in 0..<(length) {
                list.append((x,y))
                y += 1
            }
        } else {
            for _ in 0..<(length) {
                list.append((x,y))
                x += 1
            }
        }
        return list
    }
    
    private func addship(list: [(Int, Int)]) {
        var emptyboard: [[Int]] = viewModel.emptyboard

        for i in 0..<list.count {
            let (x,y) = list[i]
            emptyboard[y][x] = 2
        }
    }
    
    private func removeship(list: [(Int, Int)]) {
        var emptyboard: [[Int]] = viewModel.emptyboard

        for i in 0..<list.count {
            let (x,y) = list[i]
            emptyboard[y][x] = 0
        }
    }
    
    private func checkfit(point: (Int,Int)) -> Bool {
        let x = point.0
        let y = point.1
        
        let yRange = 0...9
        let xRange = 0...9
        
        if xRange.contains(x) && yRange.contains(y) {
            return true
        } else {
            return false
        }
    }
    
    private func checkfit_list(list: [(Int,Int)]) -> Bool {
        let emptyboard: [[Int]] = viewModel.emptyboard
        let range = 0...9
        var pointsarray: [Int] = []
        
        for i in 0..<list.count {
            let (x,y) = list[i]
            
            if range.contains(x) && range.contains(y) {
                pointsarray.append(emptyboard[y][x])
            } else {
                pointsarray.append(2)
            }
        }
        
        let result = pointsarray.allSatisfy { $0 == 0 }
        
        return result
    }
    
    private func snap(offset: CGSize, dragging: Bool) {
        
        var rotationoffset: CGFloat = 0
        let halfblock = CGFloat(0.5) * blocklength
        
        let specialcondition: Bool = (dragging && isRotated && (length % 2 == 0))
        
        let x = (specialcondition ? offset.width + halfblock : offset.width)
        let y = (specialcondition ? offset.height - halfblock : offset.height)
                        
        let xround = round((x + 1) / blocklength)
        let yround = round((y - 1) / blocklength)
        
        switch length {
        case 4:
            rotationoffset = halfblock
        case 3:
            rotationoffset = 0
        case 2:
            rotationoffset = halfblock
        default:
            rotationoffset = 0
        }
        
        let xoffset = CGFloat(xround) * blocklength
        let yoffset = CGFloat(yround) * blocklength
        
        let xdiff = x - xoffset - (specialcondition ? halfblock : 0)
        let ydiff = y - yoffset + (specialcondition ? halfblock : 0)
        
        if atstart == false {
            viewModel.removeship(points: blocklocations)
        }
        
        if !isRotated {
            
            let size = CGSize(width: xoffset, height: yoffset)
            let firstpoint = offset_point_converter(offset: size, length: length, isRotated: isRotated)
            
            let list = listofpoints(point: firstpoint, length: length, isRotated: isRotated)
            
            if checkfit_list(list: list) || atstart == true {
                location = CGPoint(x: location.x - xdiff, y: location.y - ydiff)
                
                if atstart == false {
                    viewModel.addship(points: list)
                }
                blocklocations = list
                if dragging {
                    withAnimation(Animation.spring()) {
                        self.steadyStateOffset = CGSize(width: xoffset, height: yoffset)
                    }
                } else {
                    self.steadyStateOffset = CGSize(width: xoffset, height: yoffset)
                }
            } else {
                location = CGPoint(x: CGFloat(length) * halfblock, y: halfblock)
                withAnimation(Animation.easeInOut(duration: 0.50)) {
                    self.steadyStateOffset = CGSize(width: 0, height: 0)
                }
                atstart = true
            }
        } else {
            let size = CGSize(width: xoffset - rotationoffset + halfblock + 1, height: yoffset + rotationoffset - halfblock)
            let firstpoint = offset_point_converter(offset: size, length: length, isRotated: isRotated)
            let list = listofpoints(point: firstpoint, length: length, isRotated: isRotated)
                        
            if checkfit_list(list: list) || atstart == true {
                
                location = CGPoint(x: location.x - xdiff - rotationoffset, y: location.y - ydiff + rotationoffset)
                if atstart == false {
                    viewModel.addship(points: list)
                }
                blocklocations = list
                if dragging {
                    withAnimation(Animation.spring()) {
                        self.steadyStateOffset = CGSize(width: xoffset - rotationoffset, height: yoffset + rotationoffset)
                    }
                } else {
                    self.steadyStateOffset = CGSize(width: xoffset - rotationoffset, height: yoffset + rotationoffset)
                }
            } else {
                isRotating = true
                withAnimation(Animation.easeInOut(duration: 0.50)) {
                    isRotated = !isRotated
                    if rotation == Angle.degrees(90) {
                        rotation = Angle.zero
                    }
                    location = CGPoint(x: CGFloat(length) * halfblock, y: halfblock)
                    self.steadyStateOffset = CGSize(width: 0, height: 0)
                }
                atstart = true
            }
        }
    }
    
    private func rotatedpoints(firstpoint: (Int,Int), secondpoint: (Int,Int),
                               length: Int, isRotated: Bool) -> ((Int,Int),(Int,Int)) {
        
        let (first_x,first_y) = firstpoint
        let (second_x,second_y) = secondpoint
        
        var first_rotated = (0,0)
        var second_rotated = (0,0)
        
        switch length {
        case 4:
            if !isRotated {
                first_rotated = (first_x + 1, first_y - 1)
                second_rotated = (second_x - 2, second_y + 2)
            } else {
                first_rotated = (first_x - 1, first_y + 1)
                second_rotated = (second_x + 2, second_y - 2)
            }
        case 3:
            if !isRotated {
                first_rotated = (first_x + 1, first_y - 1)
                second_rotated = (second_x - 1, second_y + 1)
            } else {
                first_rotated = (first_x - 1, first_y + 1)
                second_rotated = (second_x + 1, second_y - 1)
            }
        case 2:
            if !isRotated {
                first_rotated = firstpoint
                second_rotated = (second_x - 1, second_y + 1)
            } else {
                first_rotated = firstpoint
                second_rotated = (second_x + 1, second_y - 1)
            }
        default:
            first_rotated = firstpoint
            second_rotated = secondpoint
        }
        return (first_rotated, second_rotated)
    }
    
    
    private func rotatedfirstpoint(firstpoint: (Int,Int), length: Int, isRotated: Bool) -> ((Int,Int)) {
        
        let (first_x,first_y) = firstpoint
        
        var first_rotated = (0,0)
        
        switch length {
        case 4:
            if !isRotated {
                first_rotated = (first_x + 1, first_y - 1)
            } else {
                first_rotated = (first_x - 1, first_y + 1)
            }
        case 3:
            if !isRotated {
                first_rotated = (first_x + 1, first_y - 1)
            } else {
                first_rotated = (first_x - 1, first_y + 1)
            }
        case 2:
            first_rotated = firstpoint
        default:
            first_rotated = firstpoint
        }
        return first_rotated
    }
    
    
    var body: some View {
        
        var wiggleRotation = (wiggle == true ? Angle.radians(0) : Angle.radians(2 * .pi))
        
        let singleTapGesture = TapGesture(count: 1).onEnded {
                                    
            viewModel.removeship(points: blocklocations)
            
            var size = CGSize.zero
            let halfblock = CGFloat(0.5) * blocklength
            let rotationoffset = (length % 2 == 0 ? halfblock : 0)
            
            if !isRotated {
                size = CGSize(width: offset.width, height: offset.height)
            } else {
                size = CGSize(width: offset.width - rotationoffset + halfblock + 1,
                              height: offset.height + rotationoffset - halfblock - 1)
            }
            
            let firstpoint = offset_point_converter(offset: size, length: length, isRotated: isRotated)
        
            let first_rotated = rotatedfirstpoint(firstpoint: firstpoint, length: length, isRotated: isRotated)
            let list_rotatedpoints = listofpoints(point: first_rotated, length: length, isRotated: !isRotated)

            if checkfit_list(list: list_rotatedpoints) || atstart == true {

                isRotating = true

                withAnimation(Animation.easeInOut(duration: 0.15)) {
                    isRotated = !isRotated
                    if rotation == Angle.zero {
                        rotation = Angle.degrees(90)
                        snap(offset: offset, dragging: false)
                    } else {
                        rotation = Angle.zero
                        snap(offset: offset, dragging: false)
                    }
                }
            } else {
                isRotating = true

                withAnimation(Animation.easeInOut(duration: 0.15)) {
                    wiggle.toggle()
                    if wiggleRotation == Angle.radians(0) {
                        wiggleRotation = Angle.radians(2 * .pi)
                    } else {
                        wiggleRotation = Angle.radians(0)
                    }
                }
                viewModel.addship(points: blocklocations)
            }
        }
        
        ZStack {
        HStack(spacing: 0) {
            switch length {
            case 1:
                SingleBlock()
            case 2:
                Group {
                    EndBlock(rotation: Angle(degrees: 0))
                    EndBlock(rotation: Angle(degrees: 180))
                }
            case 3:
                Group {
                    EndBlock(rotation: Angle(degrees: 0))
                    MiddleBlock()
                    EndBlock(rotation: Angle(degrees: 180))
                }
            case 4:
                Group {
                    EndBlock(rotation: Angle(degrees: 0))
                    MiddleBlock()
                    MiddleBlock()
                    EndBlock(rotation: Angle(degrees: 180))
                }
            default:
                Circle()
            }
        }
        .padding(0)
        .offset(x: (isRotated == false ? offset.width : offset.height),
                y: (isRotated == false ? offset.height : -offset.width))
        .opacity(isRotating == false ? 1 : 0)
        .rotationEffect(isRotated == false ? Angle.zero : Angle.degrees(90))
        
        .gesture(DragGesture(minimumDistance: 1)
            .updating($gestureOffset) { latestDragGestureValue, gestureOffset, transaction in
                gestureOffset = latestDragGestureValue.translation
            } .onEnded { finalDragGestureValue in
                atstart = false
                let translation = finalDragGestureValue.translation
                self.steadyStateOffset = self.steadyStateOffset + finalDragGestureValue.translation
                
                location = CGPoint(x: location.x + translation.width,
                                   y: location.y + translation.height)
                snap(offset: offset, dragging: true)
                
            }
        )
        .gesture(singleTapGesture)
        
        HStack(spacing: 0) {
            switch length {
            case 1:
                SingleBlock()
            case 2:
                Group {
                    EndBlock(rotation: Angle(degrees: 0))
                    EndBlock(rotation: Angle(degrees: 180))
                }
            case 3:
                Group {
                    EndBlock(rotation: Angle(degrees: 0))
                    MiddleBlock()
                    EndBlock(rotation: Angle(degrees: 180))
                }
            case 4:
                Group {
                    EndBlock(rotation: Angle(degrees: 0))
                    MiddleBlock()
                    MiddleBlock()
                    EndBlock(rotation: Angle(degrees: 180))
                }
            default:
                Circle()
            }
        }
        .onAnimationCompleted(for: wiggleRotation.degrees) {
            isRotating = false
            aboutToRotate = false
        }
        
        .rotationEffect(isRotated == false ? Angle.zero : Angle.degrees(90))
        .onAnimationCompleted(for: rotation.degrees) {
                isRotating = false
                aboutToRotate = false
            }
        .opacity(isRotating == true ? 1 : 0)
        .position(location)
        .modifier(ShakeEffect(rotation: (wiggle ? 1 : 0)))
        }
    }
    
    // MARK: - Drawing Constants
    var inset: CGFloat = 5
}

struct ShakeEffect: GeometryEffect {
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(rotationAngle: 1/25 * sin(rotation * 2 * .pi)))
    }
    
    var rotation: CGFloat
    var animatableData: CGFloat {
        get { rotation }
        set { rotation = newValue }
    }
}



struct ShipView: View {

    @EnvironmentObject var viewModel: ViewModel
    
    var size: CGSize
    var width: CGFloat
    
    var body: some View {
        
        let shipblocklength = ((width - 12) / 11)
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Ship(size: size, horizOffset: 0, length: 4, blocklength: shipblocklength
                           , location: CGPoint(x: 2 * shipblocklength, y: 0.5 * shipblocklength))
                    .frame(width: shipblocklength * 4, height: shipblocklength)
                Spacer()
            }
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<2) { i in
                    Ship(size: size, horizOffset: i * 3, length: 3, blocklength: shipblocklength
                               , location: CGPoint(x: 1.5 * shipblocklength, y: 0.5 * shipblocklength))
                        .frame(width: shipblocklength * 3, height: shipblocklength)
                }
                Spacer()
            }
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<3) { i in
                    Ship(size: size, horizOffset: i * 2, length: 2, blocklength: shipblocklength
                                , location: CGPoint(x: 1.0 * shipblocklength, y: 0.5 * shipblocklength))
                        .frame(width: shipblocklength * 2, height: shipblocklength)
                }
                Spacer()
            }
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<4) { i in
                    Ship(size: size, horizOffset: i, length: 1, blocklength: shipblocklength
                                , location: CGPoint(x: 0.5 * shipblocklength, y: 0.5 * shipblocklength))
                        .frame(width: shipblocklength * 1, height: shipblocklength)
                }
                Spacer()
            }
        }
        .padding(0)
    }
}

//
//  GameBoardView.swift
//  STATKI_SwiftUI
//
//  Created by Peter A. Jankowski on 4/17/21.
//

import SwiftUI
import Foundation

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var gameID = UUID()
}


struct GameView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    var isCorrect: Bool {
        return viewModel.isCorrect
    }
    @State private var isFinished: Bool = false
    
    var body: some View {
        let board: [[Int]] = viewModel.board
        let emptyboard: [[Int]] = viewModel.emptyboard
        let left_num: [Int] = viewModel.horizontalsum
        let top_num: [Int] = viewModel.verticalsum
        
        GeometryReader { geometry in
                        
            VStack(spacing: 0) {
                HStack {
                    Image("Statki_Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150.0)
                        .padding(EdgeInsets(
                                    top: 0,
                                    leading: 10,
                                    bottom: 10,
                                    trailing: 0))
                    Spacer()
                    Button {
                        withAnimation(Animation.spring()) {
            
                            AppState.shared.gameID = UUID()
                        }
                    } label: {
                        Text("New Game")
                            .font(.system(size: 15))
                            .foregroundColor(Color.white)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .padding(EdgeInsets(
                                        top: 0,
                                        leading: 0,
                                        bottom: 2,
                                        trailing: 2))
                            .offset(x: 0, y: -3)
                    }
                    .padding(10)
                }
                Group {
                    ArrayView(array: board, emptyboard: emptyboard, left_num: left_num, top_num: top_num, viewModel: viewModel)
                    ShipView(size: geometry.size, width: geometry.size.width)
                }
            }
        }
        .overlay(
            ZStack {
                Rectangle().fill(Color.black).opacity(viewModel.isFinished ? 0.50 : 0)
                    .clipShape(Rectangle().offset(y: 50))
                    .animation(Animation.easeInOut(duration: 0.50))
                Image("checkmark").resizable().frame(width: 150, height: 150).offset(x: 20, y: -50)
                    .clipShape(Rectangle().offset(x: (viewModel.isFinished && viewModel.isCorrect ? 20 : -130), y: -50))
                    .animation(Animation.easeInOut(duration: 0.50).delay(0.75))
                Image("redx").resizable().frame(width: 150, height: 150).offset(x: 13, y: -45)
                    .clipShape(Rectangle().offset(x: (viewModel.isFinished && !viewModel.isCorrect ? 13 : -137), y: -45))
                    .animation(Animation.easeInOut(duration: 0.50).delay(0.75))
            }
            .allowsHitTesting(false)
        )
        .transition(AnyTransition.opacity.animation(.easeInOut))
    }

    // MARK: - Drawing Constants
    var tilespacing: CGFloat = 0
}

struct ArrayView: View {
    
    var array: [[Int]]
    var emptyboard: [[Int]]
    let left_num: [Int]
    let top_num: [Int]
    let viewModel: ViewModel
    
    @State private var gesturePanOffset: CGSize = .zero
    
    var body: some View {
        VStack (spacing: 0) {
            HStack (spacing: 0) {
                RoundedRectangle(cornerRadius: 0).opacity(0).aspectRatio(1, contentMode: .fit)
                ForEach(0..<10) { index_x in
                    NumView(num: String(top_num[index_x]))
                }
                Spacer(minLength: 12)
            }
            ForEach(0..<10) { index_y in
                HStack (spacing: 0) {
                    NumView(num: String(left_num[index_y]))
                    ForEach(0..<10) { index_x in
                        GeometryReader { geometry in
                            CardView(array: array, emptyboard: emptyboard, y: index_y, x: index_x, viewModel: viewModel)
                                .onTapGesture {
                                    withAnimation(Animation.easeInOut(duration: 0.10)) {
                                        viewModel.changevalue(num: emptyboard[index_y][index_x], ycoord: index_y, xcoord: index_x)
                                    }
                            }
                                .gesture(DragGesture()
                                .onChanged { latestDragGestureValue in
                                    
                                    withAnimation(Animation.easeInOut(duration: 0.20)) {
                                        viewModel.changevalue(num: emptyboard[index_y][index_x], ycoord: index_y, xcoord: index_x)
                                    }
                                    viewModel.markselected(ycoord: index_y, xcoord: index_x)
                                    
                                    let size = geometry.size
                                    
                                    gesturePanOffset = latestDragGestureValue.translation
            
                                    let ydistance = Int((gesturePanOffset.height) / size.height)
                                    let xdistance = Int((gesturePanOffset.width) / size.width)
                                    withAnimation(Animation.easeInOut(duration: 0.20)) {
                                        viewModel.changevalue(num: emptyboard[index_y][index_x],
                                                              ycoord: index_y + ydistance,
                                                              xcoord: index_x + xdistance)
                                    }
                                    viewModel.markselected(ycoord: index_y + ydistance, xcoord: index_x + xdistance)
                                }
                                .onEnded { value in
                                    viewModel.wipeselected()
                                }
                            )
                        }
                    }
                    Spacer(minLength: 12)
                }
            }
        } .fixedSize(horizontal: false, vertical: true)
    }
}

struct NumView: View {
    var num: String
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 0).opacity(0).aspectRatio(1, contentMode: .fit)
            Text(num)
        }
    }
}

struct CardView: View {
    
    var array: [[Int]]
    var emptyboard: [[Int]]
    var y: Int
    var x: Int
    let viewModel: ViewModel
    var revealedboardnum: Int {
        return viewModel.revealedboard[y][x]
    }
    var emptyboardnum: Int {
        return emptyboard[y][x]
    }
    
    
    static func calculateneighbors(array: [[Int]], y: Int, x: Int) -> (Int, Int, Int, Int) {
        var up = 0
        var down = 0
        var left = 0
        var right = 0
        
        if y > 0 {
            up = array[y-1][x]
        }
        if y < (array.count - 1) {
            down = array[y+1][x]
        }
        if x > 0 {
            left = array[y][x-1]
        }
        if x < (array.count - 1) {
            right = array[y][x+1]
        }
        
        return (up,down,left,right)
    }
    
    static func totalneighbors(array: [[Int]], y: Int, x: Int) -> Int {
        
        var total = 0
        let neighbors = calculateneighbors(array: array, y: y, x: x)
        let up_neighbor = neighbors.0
        let down_neighbor = neighbors.1
        let left_neighbor = neighbors.2
        let right_neighbor = neighbors.3
        
        total = up_neighbor + down_neighbor + left_neighbor + right_neighbor
        
        return total
    }
    
    static func pickenddirection(array: [[Int]], y: Int, x: Int) -> String {
        
        var direction = ""
        let neighbors = calculateneighbors(array: array, y: y, x: x)
        let (up, down, left, right) = neighbors
        
        if y > 0 {
            if up == 1 {
                direction =  "up"
            }
        }
        if y < (array.count - 1) {
            if down == 1 {
                direction =  "down"
            }
        }
        if x > 0 {
            if left == 1 {
                direction =  "left"
            }
        }
        if x < (array.count - 1) {
            if right == 1 {
                direction =  "right"
            }
        }
        
        return direction
    }
    
    private func listofblocks() -> ( [(Int, Int)] , [(Int, Int)] ) {
        var listships: [(Int,Int)] = []
        var listwaves: [(Int,Int)] = []
        
        for y in 0...9 {
            for x in 0...9 {
                if viewModel.board[y][x] == 1 {
                    listships.append((y,x))
                } else {
                    listwaves.append((y,x))
                }
            }
        }
        return (listships,listwaves)
    }
    
    private func randomblocks(listblocks: [(Int, Int)], count: Int) -> [(Int, Int)] {
        var locallistblocks = listblocks
        var selectedrandomblocks: [(Int,Int)] = []
        
        for _ in 1...count {
            let randomindex = Int.random(in: 0..<locallistblocks.count)
            let value = locallistblocks[randomindex]
            locallistblocks.remove(at: randomindex)
            selectedrandomblocks.append(value)
        }
        return selectedrandomblocks
    }
    
    
    var body: some View {
        
        let num_neighbors = CardView.totalneighbors(array: array, y: y, x: x)
        let direction = CardView.pickenddirection(array: array, y: y, x: x)
        
        ZStack{
            RoundedRectangle(cornerRadius: cornerRadius).fill(Color.blue).opacity(0.50).aspectRatio(1, contentMode: .fit)

            RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: 1).aspectRatio(1, contentMode: .fit)
            
            if revealedboardnum == 2 {
                if num_neighbors == 0 {
                    Circle().inset(by: inset).fill(Color.red)
                        .padding(.vertical, 0)
                        .border(Color.white, width: 2)
                } else if num_neighbors == 2 {
                    Rectangle().inset(by: inset)
                        .fill(Color.red)
                        .border(Color.white, width: 2)
                } else {
                    switch direction {
                    case "up":
                        CustomCapsule(inset: inset)
                            .rotation(Angle(degrees: 270))
                            .fill(Color.red)
                            .border(Color.white, width: 2)
                    case "down":
                        CustomCapsule(inset: inset)
                            .rotation(Angle(degrees: 90))
                            .fill(Color.red)
                            .border(Color.white, width: 2)
                    case "left":
                        CustomCapsule(inset: inset)
                            .rotation(Angle(degrees: 180))
                            .fill(Color.red)
                            .border(Color.white, width: 2)
                    case "right":
                        CustomCapsule(inset: inset)
                            .fill(Color.red)
                            .border(Color.white, width: 2)
                    default:
                        Circle().fill(Color.orange)
                    }
                }
            } else {
                if revealedboardnum == 1 || emptyboardnum == 1  {
                    Circle().inset(by: inset).fill(Color.blue).opacity(1.0)
                        .border(Color.white.opacity(revealedboardnum == 1 ? 1 : 0), width: 2)
                }
            }
        }
    }
    
    // MARK: - Drawing Constants
    var tilepadding: CGFloat = 0
    var cornerRadius: CGFloat = 0
    var inset: CGFloat = 5
    
}



//
//  GameBoardViewModel.swift
//  STATKI_SwiftUI
//
//  Created by Peter A. Jankowski on 4/17/21.
//

import SwiftUI
import Foundation

class ViewModel: ObservableObject {
    @Published private var model: Model = ViewModel.createBoardGame()
    
    private static func createBoardGame() -> Model {
        return Model()
    }
    
    // MARK: - Access to the Model
    var board: [[Int]] {
        model.board
    }
    
    var emptyboard: [[Int]] {
        model.emptyboard
    }
    
    var emptyboolboard: [[Bool]] {
        model.emptyboolboard
    }
    
    var solutionboard: [[Int]] {
        model.solutionboard
    }
    
    var horizontalsum: [Int] {
        model.horizontalsum
    }
    
    var verticalsum: [Int] {
        model.verticalsum
    }
    
    var revealedships: [(Int,Int)] {
        model.revealedships
    }
    
    var revealedwaves: [(Int,Int)] {
        model.revealedwaves
    }
    
    var revealedboard: [[Int]] {
        model.revealedboard
    }
    
    var isFinished: Bool {
        model.isFinished
    }
    
    var isCorrect: Bool {
        model.isCorrect
    }
    
    func increment(board: [[Int]]) -> [[Int]] {
        Model.incrementboard(board: board)
    }
    
    func resetgame() {
        model = ViewModel.createBoardGame()
    }
    
    func markselected(ycoord: Int, xcoord: Int) {
        model.markselected(coords: (ycoord, xcoord))
    }
    
    func changevalue(num: Int, ycoord: Int, xcoord: Int) {
        model.waveblockchange(num: num, coords: (ycoord, xcoord))
    }
    
    func wipeselected() {
        model.wipeselected()
    }
    
    func resetGame() {
        model = ViewModel.createBoardGame()
    }
    
    func newGame() -> ViewModel {
        return ViewModel()
    }
    
    func checkfit(point: (Int,Int)) -> Bool {
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
    
    func addship(points: [(Int,Int)]) {
        for i in 0..<points.count {
            let (x,y) = points[i]
            if checkfit(point: (x,y)) {
                model.addshipblock(y: y, x: x)
            }
        }
        model.updateemptyboard()
    }
    
    func removeship(points: [(Int,Int)]) {
        for i in 0..<points.count {
            let (x,y) = points[i]
            if checkfit(point: (x,y)) {
                model.removeshipblock(y: y, x: x)
            }
        }
        model.updateemptyboard()
    }
    
    func updateemptyboard() {
        model.updateemptyboard()
    }
}

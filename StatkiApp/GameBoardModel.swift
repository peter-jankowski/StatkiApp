//
//  GameBoardModel.swift
//  STATKI_SwiftUI
//
//  Created by Peter A. Jankowski on 4/17/21.
//

import SwiftUI
import Foundation

struct Model {
    
    var board: [[Int]]
    var verticalsum: [Int]
    var horizontalsum: [Int]
    var solutionboard: [[Int]]
    var emptyboard: [[Int]]
    var emptyboolboard: [[Bool]]
    var revealedships: [(Int,Int)]
    var revealedwaves: [(Int,Int)]
    var revealedboard: [[Int]]
    var isFinished: Bool = false
    var isCorrect: Bool = false
    
    init() {
        let gridinstance = GridGenerator()
        board = gridinstance.generateboard()
        verticalsum = gridinstance.verticalsum(x: board)
        horizontalsum = gridinstance.horizontalsum(y: board)
        solutionboard = Model.incrementboard(board: board)
        emptyboard = Model.emptyboard(board: board)
        emptyboolboard = Model.emptyboolboard(board: board)
        let (listships,listwaves) = Model.listofblocks(board: board)
        revealedships = Model.randomblocks(listblocks: listships, count: 7)
        revealedwaves = Model.randomblocks(listblocks: listwaves, count: 7)
        revealedboard = Model.emptyboard(board: board)
        revealedboard = revealinfo(board: revealedboard, ships: revealedships, waves: revealedwaves)
    }
    
    static func incrementboard(board: [[Int]]) -> [[Int]] {
        var increment_board = board
        for i in 0..<board.count {
            for j in 0..<board.count {
                increment_board[i][j] += 1
            }
        }
        return increment_board
    }
    
    static func emptyboard(board: [[Int]]) -> [[Int]] {
        let row = Array(repeating: 0, count: board.count)
        let array =  Array(repeating: row, count: board.count)
        return array
    }
    
    static func emptyboolboard(board: [[Int]]) -> [[Bool]] {
        let row = Array(repeating: false, count: board.count)
        let array =  Array(repeating: row, count: board.count)
        return array
    }
    
    static func randcoord(board: [[Int]]) -> (Int,Int) {
        let xcoord = Int.random(in: 0..<board.count)
        let ycoord = Int.random(in: 0..<board.count)
        return (ycoord, xcoord)
    }
    
    static func accessvalue(board: [[Int]], coords: (Int, Int)) -> Int {
        let (ycoord, xcoord) = coords
        return board[ycoord][xcoord]
    }
    
    static func revealinfo(location: (Int, Int), board: inout [[Int]], value: Int) {
        let (ycoord, xcoord) = location
        board[ycoord][xcoord] = value
    }
    
    static func revealer(board: inout [[Int]]) {
        for _ in 0..<3 {
            let randominfo = randcoord(board: board)
            let value = accessvalue(board: board, coords: randominfo)
            revealinfo(location: randominfo, board: &board, value: value)
        }
    }
    
    mutating func markselected(coords: (Int, Int)) {
        let (ycoord, xcoord) = coords
        let ycondition = ycoord >= 0 && ycoord <= 9
        let xcondition = xcoord >= 0 && xcoord <= 9
        if ycondition && xcondition {
            emptyboolboard[ycoord][xcoord] = true
        }
    }
    
    // CHANGE TO NOT RELY ON 10
    mutating func wipeselected() {
        for i in 0..<10 {
            for j in 0..<10 {
                emptyboolboard[i][j] = false
            }
        }
    }
    
    mutating func waveblockchange(num: Int, coords: (Int, Int)) {
        let (ycoord, xcoord) = coords
        let ycondition = ycoord >= 0 && ycoord <= 9
        let xcondition = xcoord >= 0 && xcoord <= 9
        
        if ycondition && xcondition {
            let selected = emptyboolboard[ycoord][xcoord]
            if !selected {
                if (emptyboard[ycoord][xcoord] == 0 || emptyboard[ycoord][xcoord] == 3) && revealedboard[ycoord][xcoord] == 0 {
                    emptyboard[ycoord][xcoord] = 1
                } else if emptyboard[ycoord][xcoord] == 1 {
                    emptyboard[ycoord][xcoord] = 0
                }
            }
        }
    }
    
    mutating func waveblockchangenum(num: Int, coords: (Int, Int)) {
        let (ycoord, xcoord) = coords
        let ycondition = ycoord >= 0 && ycoord <= 9
        let xcondition = xcoord >= 0 && xcoord <= 9
        let value = abs(num - 1)
        
        if ycondition && xcondition {
            let selected = emptyboolboard[ycoord][xcoord]
            if !selected {
                if emptyboard[ycoord][xcoord] == num {
                    emptyboard[ycoord][xcoord] = value
                }
            }
        }
    }
    
    mutating func addshipblock(y: Int, x: Int) {
        emptyboard[y][x] = 2
    }
    
    func change3to0(value: Int) -> Int {
        var returnvalue = 0
        if value == 3 {
            returnvalue = 0
        } else {
            returnvalue = value
        }
        return returnvalue
    }
    
    mutating func removeshipblock(y: Int, x: Int) {
        let range = 0...9
        emptyboard[y][x] = 0
        
        if range.contains(y+1) {
            emptyboard[y+1][x] = change3to0(value: emptyboard[y+1][x])
        }
        if range.contains(y-1) {
            emptyboard[y-1][x] = change3to0(value: emptyboard[y-1][x])
        }
        if range.contains(x+1) {
            emptyboard[y][x+1] = change3to0(value: emptyboard[y][x+1])
        }
        if range.contains(x-1) {
            emptyboard[y][x-1] = change3to0(value: emptyboard[y][x-1])
        }
    }
    
    func change0to3(value: Int) -> Int {
        var returnvalue = 0
        if value == 0 {
            returnvalue = 3
        } else {
            returnvalue = value
        }
        return returnvalue
    }
    
    mutating func updateemptyboard() {
        let range = 0...9
        for y in 0...9 {
            for x in 0...9 {
                if emptyboard[y][x] == 2 {
                    if range.contains(y+1) {
                        emptyboard[y+1][x] = change0to3(value: emptyboard[y+1][x])
                    }
                    if range.contains(y-1) {
                        emptyboard[y-1][x] = change0to3(value: emptyboard[y-1][x])
                    }
                    if range.contains(x+1) {
                        emptyboard[y][x+1] = change0to3(value: emptyboard[y][x+1])
                    }
                    if range.contains(x-1) {
                        emptyboard[y][x-1] = change0to3(value: emptyboard[y][x-1])
                    }
                }
            }
        }
        isFinished = checkfinished()
        if checkfinished() {
            let boardtocheck = emptyboardconverter(old: emptyboard)
            isCorrect = checkcorrectness(board: boardtocheck)
        }
    }
    
    mutating func checkfinished() -> Bool {
        var sum = 0
        for y in 0...9 {
            for x in 0...9 {
                if emptyboard[y][x] == 2 {
                    sum += 1
                }
            }
        }
        return (sum == 20)
    }
    
    func transpose(old: [[Int]]) -> [[Int]] {
        
        var new = Array(repeating: Array(repeating: 0, count: old.count), count: old.count)
        
        for first in 0 ..< old.count {
            for second in 0 ..< old.count {
                new[first][second] = old[second][first]
            }
        }
        return new
    }
    
    func horizontalsum(y: [[Int]]) -> [Int] {
        
        var ylist = [Int]()
        
        for row in 0 ..< y.count {
            let currentrow = y[row]
            let s = currentrow.reduce(0, +)
            ylist.append(s)
        }
        return ylist
    }
    
    func verticalsum(x: [[Int]]) -> [Int] {
        let transposed = transpose(old: x)
        return horizontalsum(y: transposed)
    }
    
    mutating func emptyboardconverter(old: [[Int]]) -> [[Int]] {
        var new = Array(repeating: Array(repeating: 0, count: old.count), count: old.count)
        
        for i in 0 ..< old.count {
            for j in 0 ..< old.count {
                if old[i][j] == 2 {
                    new[i][j] = 1
                }
            }
        }
        return new
    }
    
    func checkcorrectness(board: [[Int]]) -> Bool {
        var resultlist: [Bool] = []
        
        let hsum_gameboard = horizontalsum(y: board)
        let vsum_gameboard = verticalsum(x: board)
        
        for i in 0..<horizontalsum.count {
            resultlist.append(hsum_gameboard[i] == horizontalsum[i])
            resultlist.append(vsum_gameboard[i] == verticalsum[i])
        }
        let result = resultlist.allSatisfy { $0 == true }
        return result
    }
    
    
    static func listofblocks(board: [[Int]]) -> ( [(Int, Int)] , [(Int, Int)] ) {
        var listships: [(Int,Int)] = []
        var listwaves: [(Int,Int)] = []
        
        for y in 0...9 {
            for x in 0...9 {
                if board[y][x] == 1 {
                    listships.append((y,x))
                } else {
                    listwaves.append((y,x))
                }
            }
        }
        return (listships,listwaves)
    }
    
    static func randomblocks(listblocks: [(Int, Int)], count: Int) -> [(Int, Int)] {
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
    
    mutating func revealinfo(board: [[Int]], ships: [(Int, Int)], waves: [(Int, Int)]) -> [[Int]] {
        var localboardcopy = board
        
        for i in 0..<ships.count {
            let (y,x) = ships[i]
            localboardcopy[y][x] = 2
        }
        for i in 0..<waves.count {
            let (y,x) = waves[i]
            localboardcopy[y][x] = 1
        }
        return localboardcopy
    }
    
}

//
//  RandomGridGenerator.swift
//  STATKI_SwiftUI
//
//  Created by Peter A. Jankowski on 4/17/21.
//

import Foundation

struct GridGenerator {
        
    var ships = ["A": 4, "B": 3, "C": 3, "D": 2, "E": 2, "F": 2, "G": 1, "H": 1, "I": 1, "J": 1]
     
    var board = Array(repeating: Array(repeating: 0, count: 12), count: 12)
     
    func boardinitialize(board: inout [[Int]]) {
         
        let dimensions = 10
        let size = (dimensions + 2)
        
        for n in 0 ..< size {
            board[0][n] = -1
            board[size - 1][n] = -1
            board[n][0] = -1
            board[n][size - 1] = -1
        }
        board[size - 1][size - 1] = -1
     }
    
    func neighborcheck_simplest(c: [Int], direction: Int, size:  Int, board: [[Int]]) -> Bool {
        
        var y = c[0]
        var x = c[1]
        var sizecount = size
        
        let localboardcopy = board

        if direction == 0 {

            while sizecount > 0 {
                let up = localboardcopy[y - 1][x]
                let down = localboardcopy[y + 1][x]
                let left = localboardcopy[y][x - 1]
                let right = localboardcopy[y][x + 1]
                
                if up == 1 || down == 1 || left == 1 || right == 1 {
                    return false
                } else {
                    x += 1
                    sizecount -= 1
                }
            }
            return true
        }

        else {

            while sizecount > 0 {
                let up = localboardcopy[y - 1][x]
                let down = localboardcopy[y + 1][x]
                let left = localboardcopy[y][x - 1]
                let right = localboardcopy[y][x + 1]
                if up == 1 || down == 1 || left == 1 || right == 1 {
                    return false
                } else {
                    y += 1
                    sizecount -= 1
                }
            }
            return true
        }
    }

    
    func checkfit(c: [Int], direction: Int, size: Int, board: [[Int]]) -> Bool {
        let y = c[0]
        let x = c[1]
        
        let localboardcopy = board
            
        if direction == 0 {
            for n in 1 ..< size {
                if localboardcopy[y][x + n] == -1 {
                    return false
                }
            }
            return true
        }
        else {
            for n in 1 ..< size {
                if localboardcopy[y + n][x] == -1 {
                    return false
                }
            }
            return true
        }
    }
    
    let number_1to10 = Int.random(in: 1...10)
    
    let number_1or0 = Int.random(in: 0...1)
    
    func place_ships(board: inout [[Int]], ships: inout [String: Int]) {
                
        for (_, size) in ships {
            var ship_not_placed = true
            while ship_not_placed {
                let direction = Int.random(in: 0...1)
                
                if direction == 0 {

                    let x = Int.random(in: 1...(10-size))
                    let y = Int.random(in: 1...10)
                    let c = [y,x]
                    let placement = board[y][x]
                    let cresult = checkfit(c: c, direction: direction, size: size, board: board)
                    let nresult = neighborcheck_simplest(c: c, direction: direction, size: size, board: board)
                    
                    if placement == 0 && nresult == true && cresult == true {
                        for ship in 0 ..< size {
                            board[y][x] = 1
                            board[y][x+ship] = 1
                        }
                        ship_not_placed = false
                    }
                }

                else {
                    let x = Int.random(in: 1...10)
                    let y = Int.random(in: 1...(10-size))
                    let c = [y,x]
                    let placement = board[y][x]
                    let cresult = checkfit(c: c, direction: direction, size: size, board: board)
                    let nresult = neighborcheck_simplest(c: c, direction: direction, size: size, board: board)
                    
                    if placement == 0 && nresult == true && cresult == true {
                        for ship in 0 ..< size {
                            board[y][x] = 1
                            board[y+ship][x] = 1
                        }
                        ship_not_placed = false
                    }

                }
            }
        }
    }
    
    func board_visualize(board: inout [[Int]]) {
        
        var board_new = [[]]
        
        let dimensions = 10
        
        for row in 1 ... dimensions {
            board_new.append([])
            for col in 1 ... dimensions {
                board_new[row-1].append(board[row][col])
            }
        }
        board_new.removeLast()
        board = (board_new as? [[Int]])!
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

    func verticalsum(x: [[Int]]) -> [Int] {
        let transposed = transpose(old: x)
        return horizontalsum(y: transposed)
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
    
    func generateboard() -> [[Int]] {
        var localboard = board
        var localships = ships
        boardinitialize(board: &localboard)
        place_ships(board: &localboard, ships: &localships)
        board_visualize(board: &localboard)
        return localboard
    }

}

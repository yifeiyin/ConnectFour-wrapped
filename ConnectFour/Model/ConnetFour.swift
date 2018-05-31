//
//  ConnetFour.swift
//  ConnectFour
//
//  Created by YinYifei on 2018-02-18.
//  Copyright © 2018 Yifei Yin. All rights reserved.
//

import Foundation

class ConnectFour : CustomStringConvertible {
    
    static let Height = 6
    static let numberOfTubes = 7
    
    var description: String {
        var output = ""
        for altitude in stride(from: ConnectFour.Height - 1, through: 0, by: -1) {
            output += "(X,\(altitude)): "
            for tubeIndex in 0..<ConnectFour.numberOfTubes {
                var status = ""
                let content = board[tubeIndex][altitude]
                switch content {
                case .occupied(let player) where player == .A: status = "[A]"
                case .occupied(let player) where player == .B: status = "[B]"
                case .empty: status = "[ ]"
                default: fatalError("Unexpected value in var description.get")
                }
                output += "\(status) "
            }
            output += "\n"
        }
        output += "       "
        for tubeIndex in 0..<ConnectFour.numberOfTubes {
            output += " \(tubeIndex)  "
        }
        output += "\n"
        return output
    }
    
    enum Players {
        case A
        case B
    }
    
    enum CellState : Equatable {
        case empty
        case occupied (Players)
        
        static func ==(lhs: ConnectFour.CellState, rhs: ConnectFour.CellState) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty): return true
            case let (.occupied(a), .occupied(b)): return a == b
            default: return false
            }
        }
    }
    
    enum Status {
        case playerInTurn (Players)
        case someoneWins (Players)
        case ties
    }
    
    lazy private(set) var board = [[CellState]](repeating: [CellState](repeating: .empty, count: ConnectFour.Height), count: ConnectFour.numberOfTubes)

    private(set) var gameStatus: Status = .playerInTurn(.A)
    
    var isGameEnded: Bool {
        return gameStatus == .someoneWins(.A) ||
            gameStatus == .someoneWins(.B) ||
            gameStatus == .ties
    }
    
    var winner: Players? {
        switch gameStatus {
        case .someoneWins(let winner): return winner
        default: return nil
        }
    }
    
    var currentPlayerInTurn: Players? {
        switch gameStatus {
        case .playerInTurn(let player): return player
        default: return nil
        }
    }
    
    func ClearTube(at index: Int) {
        board[index] = [CellState](repeating: .empty, count: ConnectFour.Height)
    }
    
    func ResetGame() {
        board = [[CellState]](repeating: [CellState](repeating: .empty, count: ConnectFour.Height), count: ConnectFour.numberOfTubes)
        gameStatus = .playerInTurn(.A)
    }

    func isPushable(at tubeIndex: Int) -> Bool {
        if tubeIndex < 0, tubeIndex > ConnectFour.numberOfTubes { fatalError("Unexpected value for func isPushable") }
        if isGameEnded { return false }
        
        for index in 0..<ConnectFour.Height {
            if board[tubeIndex][index] == .empty {
                return true
            }
        }
        return false
    }
    
    func Push(at tubeIndex: Int) {
        if !isPushable(at: tubeIndex){ return }
        
        for altitude in 0..<ConnectFour.Height {
            if board[tubeIndex][altitude] == .empty {
                board[tubeIndex][altitude] = .occupied(currentPlayerInTurn!)
                break
            }
        }
        
        SwitchPlayer()
        CheckIfAnyoneWins()
    }
    
    func CheckIfAnyoneWins() {
        for indexCode in 0..<WinningCoordinateCombinations.numberOfCases {
            let coordinates = WinningCoordinateCombinations.getCoordinates(indexCode: indexCode)
            var tubeIndices = Array(repeating: 0, count: 4)
            var altitudeIndices = Array(repeating: 0, count: 4)
            var states = [CellState]()
            for index in 0..<4 {
                ( tubeIndices[index] , altitudeIndices[index] ) = coordinates[index]
                states.append(board[tubeIndices[index]][altitudeIndices[index]])
            }
            if states[0] == states[1],
                states[1] == states[2],
                states[2] == states[3] {
                switch states[0] {
                case .occupied(let player):
                    gameStatus = .someoneWins(player)
                    return
                case .empty:
                    break
                }
            }
        }
    }
    
    struct WinningCoordinateCombinations {
        static let numberOfCases = 69
        static func getCoordinates(indexCode i: Int) -> [( Int,  Int)]
        {
            switch i {
            case 0..<24: // going left and right case
                let code = i - 0
                let altitudeIndex = code / 4
                let tubeIndex = code % 4
                var out = [(Int, Int)]()
                out.append((tubeIndex+0, altitudeIndex))
                out.append((tubeIndex+1, altitudeIndex))
                out.append((tubeIndex+2, altitudeIndex))
                out.append((tubeIndex+3, altitudeIndex))
                return out
            case 24..<45: // going up and down case
                let code = i - 24
                let tubeIndex = code / 3
                let altitudeIndex = code % 3
                var out = [(Int, Int)]()
                out.append((tubeIndex, altitudeIndex+0))
                out.append((tubeIndex, altitudeIndex+1))
                out.append((tubeIndex, altitudeIndex+2))
                out.append((tubeIndex, altitudeIndex+3))
                return out
            case 45..<57: // going diagonal desending
                let code = i - 45
                let altitudeIndex = 3 + code / 4
                let tubeIndex = code % 4
                var out = [(Int, Int)]()
                out.append((tubeIndex+0, altitudeIndex-0))
                out.append((tubeIndex+1, altitudeIndex-1))
                out.append((tubeIndex+2, altitudeIndex-2))
                out.append((tubeIndex+3, altitudeIndex-3))
                return out
            case 57..<69: // going diagonal ascending
                let code = i - 57
                let altitudeIndex = code / 4
                let tubeIndex = code % 4
                var out = [(Int, Int)]()
                out.append((tubeIndex+0, altitudeIndex+0))
                out.append((tubeIndex+1, altitudeIndex+1))
                out.append((tubeIndex+2, altitudeIndex+2))
                out.append((tubeIndex+3, altitudeIndex+3))
                return out
            default: fatalError("Unexpect value while getting Winning CordianteCombinations")
            }
        }
    }
    
    private func SwitchPlayer() {
        switch gameStatus {
        case .playerInTurn(let currentPlayer):
            if currentPlayer == .A {
                gameStatus = .playerInTurn(.B)
            } else if currentPlayer == .B {
                gameStatus = .playerInTurn(.A)
            } else {
                fatalError("error: Unexpected value in func SwitchPlayer")
            }
        default:
            fatalError("error: unexpected value in func currentPlayer")
        }
    }
    
}

extension ConnectFour.Status : Equatable {
    static func ==(lhs: ConnectFour.Status, rhs: ConnectFour.Status) -> Bool {
        switch (lhs, rhs) {
        case let (.playerInTurn(a), .playerInTurn(b)),
             let (.someoneWins(a), .someoneWins(b)): return a == b
        case (.ties, .ties): return true
        default: return false
        }
    }
}

//
//  ConnecToGameRequest.swift
//  Chepuha
//
//  Created by LofoD on 30.05.2021.
//

import Foundation

struct ConnectToGameRequest: Codable {
    var gameCode: String
    var player: Player
}

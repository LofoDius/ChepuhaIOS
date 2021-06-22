//
//  PlayersList.swift
//  Chepuha
//
//  Created by LofoD on 23.05.2021.
//

import SwiftUI

struct PlayersList: View {
    @State var players: Array<PlayerCard>
    
    var body: some View {
        List (players) { player in
            PlayerRow(player: player)
        }
    }
}

struct PlayersList_Previews: PreviewProvider {
    static var previews: some View {
        Text("teds")
    }
}

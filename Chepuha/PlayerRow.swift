//
//  PlayerRow.swift
//  Chepuha
//
//  Created by LofoD on 23.05.2021.
//

import SwiftUI

struct PlayerRow: View {
    var player: PlayerCard
    @Binding var showIcon: Bool
    
    var body: some View {
        HStack () {
            if self.showIcon {
                Image("PlayerIcon")
                    .resizable()
                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                Text(player.name)
                    .font(Font.custom("Pangolin-Regular", size: 24))
                
                Spacer()
            } else {
                Text(player.name)
                    .font(Font.custom("Pangolin-Regular", size: 24))
                    .padding(.leading, 50)
                
                Spacer()
            }
        }
    }
}

struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        PlayerRow(player: PlayerCard(name: "test", id: UUID.init()), showIcon: .constant(false))
    }
}

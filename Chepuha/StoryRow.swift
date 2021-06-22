//
//  StoryRow.swift
//  Chepuha
//
//  Created by LofoD on 08.06.2021.
//

import SwiftUI

struct StoryRow: View {
    @State var text: String
    @State var author: String
    
    var showAuthor: (_ author: String) -> Void
    
    var body: some View {
        
        HStack {
            Text(text)
                .font(Font.custom("Pangolin-Regular", size: 24))
                .multilineTextAlignment(.leading)
                .padding(.leading)
                .onLongPressGesture {
                    showAuthor(author)
                }
        }
        .padding(.vertical)
    }
}

struct StoryRow_Previews: PreviewProvider {
    static var previews: some View {
        StoryRow(text: "abracadabrasdf;goihsdf;jvb;sdiufbvlisfgdliuhgsldfiuhg", author: "test", showAuthor: {_ in print("hui")})
    }
}

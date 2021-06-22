//
//  StoryView.swift
//  Chepuha
//
//  Created by LofoD on 08.06.2021.
//

import SwiftUI
import AlertToast

struct StoryView: View {
    var player: Player
    var gameCode: String
    @State var isShowingAuthor = false
    @State var author: String = ""
    @State var isLoaded = false
    @ObservedObject var controller = LinesListController()
    @Environment(\.rootPresentationMode) var rootPresentationMode: Binding<RootPresentationMode>
    
    var body: some View {
        VStack {
            Text("История")
                .font(Font.custom("Pangolin-Regular", size: 42))
            
            
            if isLoaded == false {
                Text("Подгружаем ответики...")
                    .font(Font.custom("Pangolin-Regular", size: 32))
            } else {
                List() {
                    ForEach(controller.lines) { line in
                        StoryRow(text: line.text, author: line.author, showAuthor: showAuthor)
                    }
                }
                
                Button(action: {self.rootPresentationMode.wrappedValue.dismiss()}) {
                    Text("В меню")
                        .foregroundColor(.white)
                        .font(Font.custom("Pangolin-Regular", size: 20))
                } .padding()
                .background(Color.init("ButtonColor"))
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                .padding(.vertical)
            }
        }.toast(isPresenting: $isShowingAuthor) {
            AlertToast(displayMode: .alert, type: .regular, title: "автор: \(author)", custom: AlertToast.AlertCustom.custom(backgroundColor: nil, titleColor: nil, subTitleColor: nil, titleFont: Font.custom("Pangolin-regular", size: 24), subTitleFont: nil))
        }
        .navigationBarHidden(true)
        .onAppear {
            isLoaded = controller.getStory(player: player, gameCode: gameCode)
        }
    }
    
    func showAuthor(author: String) {
        isShowingAuthor = false
        self.author = author
        isShowingAuthor = true
    }
}

class LinesListController: ObservableObject {
    @Published var lines: [StoryLineCard] = []
    var story: Story = Story(answers: [])
    func getStory(player: Player, gameCode: String) -> Bool {
        APIRequests.getStory(playerID: player.id, gameCode: gameCode) {
            result in
            switch result {
            case .failure(let error): print(error)
            case .success(let response): do {
                if (response.code == 0) {
                    self.story = response.story!
                    self.fillLines()
                } else {
                    print("[GetStory]: non zero code!")
                }
            }
            }
        }
        
        return true
    }
    
    func fillLines() {
        DispatchQueue.main.async {
            for i in 0..<self.story.answers.count {
                self.lines.append(StoryLineCard(text: self.story.answers[i].text, author: self.story.answers[i].author))
            }
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView(player: Player(name: "test", id: UUID()), gameCode: "asd")
    }
}

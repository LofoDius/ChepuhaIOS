//
//  ContentView.swift
//  Chepuha
//
//  Created by LofoD on 17.05.2021.
//

import SwiftUI
import AlertToast

struct LabelledDivider: View {
    
    let label: String
    let horizontalPadding: CGFloat
    let color: Color
    
    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .gray) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }
    
    var body: some View {
        HStack {
            line
            Text(label).foregroundColor(color)
                .font(Font.custom("Pangolin-Regular", size: 20))
            line
        }
    }
    
    var line: some View {
        VStack { Divider().background(color) }.padding(horizontalPadding)
    }
}

struct CustomTextField: View {
    var placeHolder: String
    @Binding var value: String
    @Binding var isConnecting: Bool
    
    var connect: () -> Void
    
    var lineColor: Color
    var width: CGFloat
    
    var body: some View {
        VStack {
            TextField(self.placeHolder, text: $value)
                .frame(width: 80, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .font(Font.custom("Pangolin-Regular", size: 24))
                .multilineTextAlignment(.center)
                .autocapitalization(.none)
                .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
                .onChange(of: value) {
                    if isConnecting == true {
                        return
                    }
                    
                    if $0.count < 3 {
                        return
                    } else if $0.count == 3 {
                        isConnecting = true
                        connect()
                    }
                    else {
                        value = value.subString(from: 0, to: 4)
                    }
                }
            
            
            Rectangle().frame(width: 50, height: self.width)
        }
    }
    
    
}


struct ContentView: View {
    
    @State private var username = ""
    @State private var gameCode = ""
    @State private var selection: String? = nil
    @State private var noUsernameError = false
    @State private var createdGameCode = ""
    @State private var player: Player = Player(name: "", id: UUID.init())
    @State var isConnecting = false
    @State var isStarter = false
    @State var connectingError = false
    @State var isActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack (alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/)
                {
                    Text("ЧЕПУХА")
                        .font(Font.custom("Pangolin-Regular", size: 48))
                        .padding(.bottom)
                    
                    TextField("Имя", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(Font.custom("Pangolin-Regular", size: 24))
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                        .autocapitalization(.none)
                    
                    CustomTextField(placeHolder: "Код", value: $gameCode, isConnecting: $isConnecting, connect: connect, lineColor: Color.init("ButtonColor"), width: 1)
                    
                    LabelledDivider(label: "или", horizontalPadding: 5)
                    
                    NavigationLink(
                        destination: WaitingRoomView(createdGameCode: $createdGameCode, isStarter: $isStarter, player: $player), tag: "waitingRoom", selection: $selection) {
                        Button(action: {
                            if (username == "") {
                                noUsernameError.toggle()
                                return
                            }
                            player.name = username
                            isStarter = true
                            
                            APIRequests.createGame(player: player) {
                                result in
                                switch result {
                                case .success(let response): do {
                                    createdGameCode = response.gameCode
                                    selection = "waitingRoom"
                                }
                                case .failure(let error): do {
                                    print("An error occured (start game): \(error)")
                                }
                                }
                            }
                        })
                        {
                            Text("Создать игру")
                                .foregroundColor(.white)
                                .font(Font.custom("Pangolin-Regular", size: 20))
                        } .padding()
                        .background(Color.init("ButtonColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        
                    }
                    .isDetailLink(false)
                    NavigationLink(
                        destination: self,
                        isActive: $isActive,
                        label: {
                            Text("Navigate")
                                .frame(height: 0)
                        }).isDetailLink(false)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .toast(isPresenting: $noUsernameError) {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: "А где имя? 🤔", custom: AlertToast.AlertCustom.custom(backgroundColor: Color.red, titleColor: nil, subTitleColor: nil, titleFont: Font.custom("Pangolin-Regular", size: 24), subTitleFont: nil))
        }
        .toast(isPresenting: $connectingError) {
            AlertToast(displayMode: .alert, type: .regular, title: "Не удалось подключиться!")
        }
        .environment(\.rootPresentationMode, self.$isActive)
        .onAppear {
            gameCode = ""
        }
        
    }
    
    func connect() {
        if (username == "") {
            noUsernameError = true
            return
        }
        isStarter = false
        player.name = username
        APIRequests.connectToGame(player: player, gameCode: gameCode) {
            result in
            switch result {
            case .failure(let error): do {
                print(error)
                isConnecting = false
                connectingError.toggle()
            }
            case .success(let response): do {
                print("here")
                if response.code == 0 {
                    createdGameCode = gameCode.lowercased()
                    selection = "waitingRoom"
                    isConnecting = false
                } else {
                    print(response)
                    isConnecting = false
                }
            }
            }
        }
    }
    
}

extension String {
    func subString(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex..<endIndex])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



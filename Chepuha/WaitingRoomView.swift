//
//  WaitingRoomView.swift
//  Chepuha
//
//  Created by LofoD on 23.05.2021.
//

import SwiftUI
import SwiftStomp
import AlertToast

struct WaitingRoomView: View, SwiftStompDelegate{
    
    
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        print("CONNECTED")
        stompClinet.subscribe(to: "/topic/connectedPlayers/\(createdGameCode)")
        stompClinet.subscribe(to: "/topic/gameStarted/\(createdGameCode)")
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        
    }
    
    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
        print("NEW FUCKING MESSAGE RECEIVED: \(message as! String)")
        if (destination == "/topic/gameStarted/\(createdGameCode)") {
            if (message as! String) == "\nStarted" {
                selection = "gameStarted"
            }
        } else {
            do {
                let data = (message as! String).data(using: .utf8)!
                let newPlayer = try JSONDecoder().decode(Player.self, from: data)
                
                players.addPlayer(newPlayer: PlayerCard(name: newPlayer.name, id: newPlayer.id))
            } catch {
                print("[onMessageReceived] decoding Error: \(error)")
            }
        }
    }
    
    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        
    }
    
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        
    }
    
    func onSocketEvent(eventName: String, description: String) {
        
    }
    
    @ObservedObject var players = PlayersListController()
    @State var canStartGame = false
    @Binding var createdGameCode: String
    @Binding var isStarter: Bool
    @State var selection: String? = ""
    @State var notEnoughPlayersError = false
    var stompClinet: SwiftStomp = SwiftStomp(host: URL(string: "ws://localhost:8080/connections")!)
    @Binding var player: Player
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Text("Ожидаем игроков")
                        .font(Font.custom("Pangolin-Regular", size: 42))
                        .fontWeight(.bold)
                    
                    Text("Код: " + createdGameCode)
                        .font(Font.custom("Pangolin-Regular", size: 32))
                        .padding(.bottom)
                    
                    List() {
                        ForEach(players.connectedPlayers) { p in
                            PlayerRow(player: p, showIcon: .constant(player.id == p.id))
                        }
                    }.padding(.leading, -16)
                    
                }
                
                if self.$isStarter.wrappedValue {
                    NavigationLink(
                        destination: EnterAnswerView(gameCode: $createdGameCode, player: player),
                        tag: "gameStarted",
                        selection: $selection) {
                        Button(action: {
                            if players.connectedPlayers.count < 2 {
                                notEnoughPlayersError.toggle()
                                return
                            }
                            
                            APIRequests.startGame(gameCode: createdGameCode) {
                                result in
                                switch result {
                                case .failure(let error): print(error)
                                case .success(let response): do {
                                    if (response.code == 0) {
                                        selection = "gameStarted"
                                    } else {
                                        print("[StartGame]: non zero code")
                                    }
                                }
                                }
                            }
                            
                        }) {
                            Text("Все здесь!")
                                .font(Font.custom("Pangolin-Regular", size: 20))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.init("ButtonColor"))
                        .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                        .shadow(color: .black, radius: 3, x: 0.0, y: 0.5)
                    }.isDetailLink(false)
                    .padding(30)
                    
                }
                else {
                    NavigationLink(
                        destination: EnterAnswerView(gameCode: $createdGameCode, player: player),
                        tag: "gameStarted",
                        selection: $selection) {
                        Text("s")
                            .frame(height: 0)
                    }.isDetailLink(false)
                }
            }
            .toast(isPresenting: $notEnoughPlayersError, alert: {
                AlertToast(displayMode: .banner(.slide), type: .regular, title: "Одному играть не получиться!🥸", custom: AlertToast.AlertCustom.custom(backgroundColor: Color.red, titleColor: Color.white, subTitleColor: Color.white, titleFont: Font.custom("Pangolin-Regular", size: 24), subTitleFont: nil))
            })
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                print("onAppear code: \(createdGameCode)")
                stompClinet.delegate = self
                stompClinet.autoReconnect = true
                stompClinet.connect()
                players.updateList(gameCode: createdGameCode)
            }
        }
    }
    
}


class PlayersListController: ObservableObject {
    
    @Published var connectedPlayers: [PlayerCard] = []
    
    func addPlayer(newPlayer: PlayerCard) {
        connectedPlayers.append(newPlayer)
    }
    
    func updateList(gameCode: String) {
        APIRequests.getConnectedPlayers(gameCode: gameCode) { result in
            switch result {
            case .success(let players): do {
                DispatchQueue.main.sync {
                    self.connectedPlayers = players
                }
                
            }
            
            case .failure(let error): print("getConnectedPlayers: \(error)")
            }
        }
    }
}

struct WaitingRoomView_Previews: PreviewProvider {
    
    static var previews: some View {
        WaitingRoomView(createdGameCode: .constant("hui"), isStarter: .constant(true), player: .constant(Player(name: "huui", id: UUID.init())))
    }
}

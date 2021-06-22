//
//  EnterAnswerView.swift
//  Chepuha
//
//  Created by LofoD on 02.06.2021.
//

import SwiftUI
import SwiftUIX
import SwiftStomp
import AlertToast

struct EnterAnswerView: View, SwiftStompDelegate {
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        stompClient.subscribe(to: "/topic/question/\(gameCode)")
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        
    }
    
    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
        do {
            let data = Data((message as! String).utf8)
            let q = try JSONDecoder().decode(QuestionRespnose.self, from: data)
            
            if (q.code == 0) {
                if q.question == "game ended" {
                    selection = "story"
                    return
                }
            
                question = q.question
                questionNumber = q.questionNumber
                isWaiting = false
            } else {
                print("question received: \(message as! String)")
            }
        } catch {
            print("question received: \(message as! String)")
        }
    }
    
    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        
    }
    
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        
    }
    
    func onSocketEvent(eventName: String, description: String) {
        
    }
    
    
    @State var question: String = "Кто?"
    @State var answer: String = ""
    @State var questionNumber: Int = 0
    
    @State var isEditing: Bool = true
    @State var selection: String? = ""
    @Binding var gameCode: String
    @State var emptyAnswerError = false
    @State var isWaiting = false
    var player: Player
    @State var oldQuestionNumber: Int = 0
    let url = "ws://localhost:8080/connections"
    var stompClient: SwiftStomp
    
    init(gameCode: Binding<String>, player: Player) {
        self._gameCode = gameCode
        stompClient = SwiftStomp(host: URL(string: url)!)
        self.player = player
    }
    
    var body: some View {
        VStack {
            if isWaiting {
                Text("Ожидаем остальных игроков...")
                    .padding()
                    .font(Font.custom("Pangolin-Regular", size: 32))
                    .multilineTextAlignment(.center)
                
                NavigationLink(
                    destination: StoryView(player: player, gameCode: gameCode),
                    tag: "story",
                    selection: $selection) {
                    Text("mock")
                        .frame(height: 0)
                }
            } else {
                Spacer()
                Text(question)
                    .font(Font.custom("Pangolin-Regular", size: 32))
                    .padding()
                
                TextField("Жду смешнявку", text: $answer, isEditing: $isEditing, onCommit: {
                    if answer.isEmpty {
                        emptyAnswerError = true
                    } else {
                        sendAnswer()
                    }
                })
                .initialContentAlignment(.center)
                .multilineTextAlignment(.center)
                .font(Font.custom("Pangolin-Regular", size: 32))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                NavigationLink(
                    destination: StoryView(player: player, gameCode: gameCode),
                    tag: "story",
                    selection: $selection) {
                    Button(action: {
                        if answer.isEmpty {
                            emptyAnswerError = true
                        } else {
                            sendAnswer()
                        }
                    }) {
                        Text("Отправить")
                            .font(Font.custom("Pangolin-Regular", size: 20))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.init("ButtonColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .padding(.vertical)
                }.isDetailLink(false)
                Spacer()
                
            }
        }
        .toast(isPresenting: $emptyAnswerError, alert: {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: "А где смешнявка?😡", custom: AlertToast.AlertCustom.custom(backgroundColor: Color.red, titleColor: Color.white, subTitleColor: Color.white, titleFont: Font.custom("Pangolin-Regular", size: 24), subTitleFont: nil))
        })
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            stompClient.delegate = self
            stompClient.autoReconnect = true
            stompClient.connect()
        }
        
    }
    
    func sendAnswer() {
        oldQuestionNumber = questionNumber
        APIRequests.sendAnswer(answer: Answer(questionNumber: questionNumber, text: answer, author: player.name), gameCode: gameCode, completion: {
            result in
            switch result {
            case .success(let response): do {
                if (response.code == 1) {
                    print("[Send Answer] received code 1")
                } else if oldQuestionNumber == questionNumber {
                    isWaiting = true
                }
            }
            case .failure(let error): do {
                print("[Send Answer] error: \(error)")
            }
            }
        })
        answer = ""
    }
}

struct EnterAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        EnterAnswerView(gameCode: .constant("hui"), player: Player(name: "test", id: UUID()))
    }
}



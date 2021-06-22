//
//  APIRequests.swift
//  Chepuha
//
//  Created by LofoD on 30.05.2021.
//

import Foundation

enum APIError: Error {
    case decodingError
    case encodingError
    case otherError
}


struct APIRequests {
    private static let url = "http://localhost:8080"
    
    static func createGame(player: Player, completion: @escaping(Result<StartGameResponse, APIError>) -> Void) {
        guard let requestURL = URL(string: (url + "/create")) else {
            return
        }
        
        do {
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = try JSONEncoder().encode(StartGameRequest(starter: player))
            request.timeoutInterval = 20
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(StartGameResponse.self, from: data)
                        completion(.success(json))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                }
            }.resume()
        } catch {
            completion(.failure(.otherError))
        }
    }
    
    static func startGame(gameCode: String, completion: @escaping(Result<BaseResponse, APIError>) -> Void) {
        guard let requestURL = URL(string: (url + "/start/\(gameCode)")) else {
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse.self, from: data)
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    static func getConnectedPlayers(gameCode: String, completion: @escaping(Result<[PlayerCard], APIError>) -> Void) {
        guard let requestURL = URL(string: (url + "/connectedPlayers/\(gameCode)")) else {
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONDecoder().decode([Player].self, from: data)
                    var cards: [PlayerCard] = []
                    
                    for player in json {
                        cards.append(PlayerCard(name: player.name, id: player.id))
                    }
                    
                    completion(.success(cards))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    static func sendAnswer(answer: Answer, gameCode: String, completion: @escaping(Result<BaseResponse, APIError>) -> Void) {
        guard let requestURL = URL(string: (url + "/message")) else {
            return
        }
        
        do {
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = try JSONEncoder().encode(AnswerRequest(answer: answer, gameCode: gameCode))
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONDecoder().decode(BaseResponse.self, from: data)
                    completion(.success(json))
                } catch {
                    print(data)
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
        } catch {
            completion(.failure(.encodingError))
        }
    }
    
    static func getStory(playerID: UUID, gameCode: String, completion: @escaping(Result<StoryResponse, APIError>) -> Void) {
        guard let requsetURL = URL(string: (url + "/story")) else {
            return
        }
        
        do {
            var request = URLRequest(url: requsetURL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = try JSONEncoder().encode(StoryRequest(playerID: playerID, gameCode: gameCode))
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let storyResponse = try JSONDecoder().decode(StoryResponse.self, from: data)
                        completion(.success(storyResponse))
                    }catch{
                        completion(.failure(.decodingError))
                    }
                }
            }.resume()
        } catch {
            completion(.failure(.encodingError))
        }
    }
    
    static func connectToGame(player: Player, gameCode: String, completion: @escaping(Result<BaseResponse, APIError>) -> Void) {
        guard let requestURL = URL(string: (url + "/connect")) else {
            return
        }
        
        do {
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = try JSONEncoder().encode(ConnectToGameRequest(gameCode: gameCode, player: player))
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(BaseResponse.self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                }
            }.resume()
            
        } catch {
            completion(.failure(.encodingError))
        }
    }
    
}

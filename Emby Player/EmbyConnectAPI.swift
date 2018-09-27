//
//  EmbyConnectAPI.swift
//  Emby Player
//
//  Created by Mats Mollestad on 25/09/2018.
//  Copyright © 2018 Mats Mollestad. All rights reserved.
//

import Foundation

class EmbyConnectAPI {
    
    enum Errors: Error {
        case invalidUrl
    }
    
    let baseUrl = URL(string: "https://connect.emby.media/")!
    static let shared = EmbyConnectAPI()
    
    private let applicationHeader = NetworkRequestHeaderValue(header: "X-Application", value: "Emby Player SPAM/1.0.0")
    
    func login(with request: LoginRequest, completion: @escaping (NetworkRequesterResponse<EmbyConnectLogin>) -> Void) {
        let url = baseUrl.appendingPathExtension("service/user/authenticate")
        
        var headers = NetworkRequester.defaultHeader
        headers.insert(applicationHeader)
        
        NetworkRequester().post(at: url, body: request, completion: completion)
    }
    
    func fetchServers(for connectLogin: EmbyConnectLogin, completion: @escaping (NetworkRequesterResponse<String>) -> Void) {
        let urlPath = baseUrl.appendingPathExtension("service/servers")
        guard var urlComponents = URLComponents(url: urlPath, resolvingAgainstBaseURL: false) else {
            completion(.failed(Errors.invalidUrl))
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: connectLogin.user.id)]
        guard let url = urlComponents.url else {
            completion(.failed(Errors.invalidUrl))
            return
        }
        
        let connectTokenHeader = NetworkRequestHeaderValue(header: "X-Connect-UserToken", value: connectLogin.accessToken)
        var headers = NetworkRequester.defaultHeader
        headers.insert(applicationHeader)
        headers.insert(connectTokenHeader)
        
        NetworkRequester().get(at: url, header: headers, completion: completion)
    }
}

//
// NetworkHelper.swift
// SessionTest
//
// Created by 김근수 on 2020/08/07.
// Copyright © 2020 김근수. All rights reserved.
//
import Foundation
struct TestObject: Codable {
    var userId: String?
    var sentence: String?
}

/// Singleton Instance for network
class NetworkHelper {
    public static let shared: NetworkHelper = NetworkHelper()
//    private let baseUrl = "http://49.50.166.93/hello"
    private let baseUrl = "http://0.0.0.0/hello"
    private init() { }
    func getData(userId: String, sentence: String, completion: @escaping (TestObject) -> Void) {
        // Create Session
        let defaultSession = URLSession(configuration: .default)
        //    let requestString = baseUrl + message
        guard let url = URL(string: "\(baseUrl)") else {
            print("URL is nil")
            return
        }
        // Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let dict = ["userId": userId, "sentence":sentence] as [String: Any]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return
        }
        //        let body = "userId=\(userId)&sentence=\(sentence)".data(using: .utf8, allowLossyConversion: false)
        request.httpBody = jsonData
        // dataTask
        let dataTask = defaultSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            // getting Data Error
            guard error == nil else {
                print("Error occur: \(String(describing: error))")
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            let decoder = JSONDecoder()
            guard let testObject = try? decoder.decode(TestObject.self, from: data) else{
                print("Error occur: \(String(describing: error?.localizedDescription))")
                return
            }
            completion(testObject)
        }
        
        dataTask.resume()
    }
}

//
// NetworkHelper.swift
// SessionTest
//
// Created by 김근수 on 2020/08/07.
// Copyright © 2020 김근수. All rights reserved.
//
import Foundation
/// Singleton Instance for network
class NetworkHelper {
    public static let shared: NetworkHelper = NetworkHelper()
    private let baseUrl = "https://m3z89i7n7f.execute-api.us-east-1.amazonaws.com/default/relay"
    private init() { }
    func getData(message: String, completion: @escaping (TestObject) -> Void) {
        // Create Session
        let defaultSession = URLSession(configuration: .default)
        let requestString = baseUrl + message

        let encodedString = requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: "\(encodedString)") else {
            print("URL is nil")
            return
        }
        // Request
        let request = URLRequest(url: url)
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

struct TestObject: Codable {
    var userId: String?
    var sentence: String?
}

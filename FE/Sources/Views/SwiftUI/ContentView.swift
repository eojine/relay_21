//
//  ContentView.swift
//  CoreMLRecommender
//
//  Created by Anupam Chugh on 15/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import SwiftUI
import Combine
import CoreML


struct ContentView: View {
    @ObservedObject var topRecommendations = Recommender()
    
    @available(iOS 13.0.0, *)
    var body: some View {
        NavigationView {
            List(topRecommendations.hobbies) { hobby in
                VStack (alignment: .leading) {
                    Text(hobby.name)
                    Text("\(hobby.score)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
                }
            }.navigationBarTitle("Steven Deutsch", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



public class Recommender: ObservableObject {
    
    @Published var hobbies = [Hobby]()
    
    init(){
        print(load())
    }
    
    func load() -> [Hobby] {
        do{
            let recommender = HobbyRecommender()
            
            let ratings : [String: Double] = getUserInterest()
            let input = HobbyRecommenderInput(items: ratings, k: 5, restrict_: [], exclude: [])
            
            let result = try recommender.prediction(input: input)
            var tempHobbies = [Hobby]()
            
            for str in result.recommendations{
                let score = result.scores[str] ?? 0
                tempHobbies.append(Hobby(name: "\(str)", score: score))
            }
            self.hobbies = tempHobbies
            
            
            
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
        return self.hobbies
    }
    
    func getUserInterest() -> [String : Double] {
        let userName: MockUser = SampleData.shared.senders[1] // steven
        let interests = userName.interests
        var dict = [String : Double]()
        interests.forEach{
            dict[$0] = 1.0
        }
        return dict
    }
}

struct Hobby: Identifiable {
    public var id = UUID()
    public var name: String
    public var score: Double
    
}

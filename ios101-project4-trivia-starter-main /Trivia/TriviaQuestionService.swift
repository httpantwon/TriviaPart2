//
//  TriviaQuestionService.swift
//  TriviaPart2
//
//  Created by Antwon Walls on 3/18/24.
//

import Foundation

struct TriviaResponse: Decodable {
    /* responseCode property presents a status code returned by the API to indicate the status of the request. A common practice in APIs is to use HTTP status code 200 for success, 404 for not found, 500 for server error, etc.
     
       By making responseCode optional, the decoding process will not fail if the
       key is missing from the JSON response */
    let responseCode: Int?
    /* Contains an array of TriviaQuestion objects, which are the actual trivia questions retrieved from the API*/
    let results: [TriviaQuestion]
}


struct TriviaQuestion: Decodable {
    let type: String
    let difficulty: String
    let category: String
    let question: String
    let correctAnswer: String?
    let incorrectAnswers: [String]?
}

class TriviaQuestionService {
    static let shared = TriviaQuestionService()
    private let apiURL = "https://opentdb.com/api.php" // Base URL
    
    private init() { // Private initializer to enforce singleton
        
    }
    
    /*To fetch trivia questions from the API, this method will make a network request to the API and parse the response. Attempts to decode the JSON response from the API into a TriviaResponse object. The responseCode is expected to be present in the JSON response*/
    func fetchTriviaQuestions(amount: Int, difficulty: String, type: String, triviaViewController: TriviaViewController, completion: @escaping ([TriviaViewController.TriviaStruct]?, Error?) -> Void) {
        // Construct URL with query parameters
        var urlComponents = URLComponents(string: apiURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "difficulty", value: difficulty),
            URLQueryItem(name: "type", value: type)
        ]
        
        guard let url = urlComponents?.url else {
            print("Invalid URL")
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        print("Fetching questions from URL: \(url)")
        
        // Create a URL session
        let session = URLSession.shared
        
        // Make the network request that fetches data from the API asynchronously
        let task = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error { //if error is not nil (an error occured during the network request)
                    print("Error fetching data: \(error)")
                    completion(nil, error)
                    return
                }
            
            // Check for errors
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                /*Parse JSON response into TriviaResponse struct, which contains an array of TriviaQuestion objects and handles errors*/
                let decoder = JSONDecoder()
                let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
                
                /*Extract trivia questions from the response, directly creating instances of
                  TriviaViewController.TriviaStruct while mapping over triviaResponse.results*/
                var triviaQuestions = triviaResponse.results.map { result in
                    TriviaViewController.TriviaStruct(questionHeaderText: "", question: result.question, answerOption1: result.correctAnswer!, answerOption2: result.incorrectAnswers![0], answerOption3: result.incorrectAnswers![1], answerOption4: result.incorrectAnswers![2])
                }
                
                // Call completion handler with trivia questions
                completion(triviaQuestions, nil)
            } catch {
                print("Error decoding JSON: \(error)") // Print error message
                completion(nil, error)
            }
        }
            // Resume the task
            task.resume()
        }
    }



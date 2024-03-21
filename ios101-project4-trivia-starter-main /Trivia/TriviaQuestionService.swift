//
//  TriviaQuestionService.swift
//  TriviaPart2
//
//  Created by Antwon Walls on 3/18/24.
//

import Foundation

struct TriviaQuestion: Decodable {
    let type: String
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct TriviaResponse: Decodable {
    /* The responseCode property presents a status code returned by the API to indicate the status of the request. A common practice in APIs is to use HTTP status code 200 for success, 404 for not found, 500 for server error, etc. By making responseCode optional, the decoding process will not fail if the key is missing from the JSON response */
    let responseCode: Int?
                 
    /* Contains an array of TriviaQuestion objects, which are the actual trivia questions retrieved from the API */
    let results: [TriviaQuestion]
}

public class TriviaQuestionService {
    
    /* Initializes a shared property with a new instance of the TriviaQuestionService class */
    public static let shared = TriviaQuestionService()
    private let apiURL = "https://opentdb.com/api.php" // Base URL
    
    /* Ensures I can create instances of TriviaQuestionService using the default initializer syntax 'TriviaQuestionService()'. public keyword means I can use instances of it in other Swift files */
    public init() { // Public initializer to enforce singleton
        
    }
    
    /* To fetch trivia questions from the API, this method will make a network request to the API and parse the response. Attempts to decode the JSON response from the API into a TriviaResponse object. The responseCode is expected to be present in the JSON response */
    func fetchTriviaQuestions(amount: Int, difficulty: String, type: String, triviaViewController: TriviaViewController, completion: @escaping ([TriviaViewController.TriviaStruct]?, String?, Error?) -> Void) {
        
        /* Construct URL with query parameters. URLComponents allow me to break down a URL into its constituent parts (scheme, host, path, query parameters, etc.) and vice versa */
        var urlComponents = URLComponents(string: apiURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "difficulty", value: difficulty),
            URLQueryItem(name: "type", value: type)
        ]
        
        guard let url = urlComponents?.url else {
            print("Invalid URL")
            completion(nil, nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        /* Creates a URL session to perform network requests in the app. It provides an interface for downloading/uploading data from/to remote locations such as APIs */
        let session = URLSession.shared
        
        // Make the network request that fetches data from the API asynchronously
        let task = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error { //check for errors
                print("Error fetching data: \(error)")
                completion(nil, nil, error)
                return
            }
            
        // Check for errors
        guard let data = data else {
            print("No data received")
            completion(nil, nil, NSError(domain: "No data received", code: 0, userInfo: nil))
            return
        }
        
        do {
            /*Parse JSON response into TriviaResponse struct, which contains an array of TriviaQuestion objects and handles errors*/
            let decoder = JSONDecoder()
            let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
        
            /*Extract trivia questions from the response, directly creating instances of TriviaViewController.TriviaStruct while mapping over triviaResponse.results*/
            let triviaQuestions = triviaResponse.results.map { result in
                let incorrect_answers = result.incorrect_answers
                return TriviaViewController.TriviaStruct(
                    questionHeaderText: "",
                    /*Decode HTML entities here*/
                    question: result.question.decodeHTMLEntities() ?? "",
                    correct_answer: result.correct_answer.decodeHTMLEntities() ?? "",
                    incorrect_answer1: incorrect_answers.indices.contains(0) ? incorrect_answers[0].decodeHTMLEntities() ?? "" : "",
                    incorrect_answer2: incorrect_answers.indices.contains(1) ? incorrect_answers[1].decodeHTMLEntities() ?? "" : "",
                    incorrect_answer3: incorrect_answers.indices.contains(2) ? incorrect_answers[2].decodeHTMLEntities() ?? "" : "", category: result.category.decodeHTMLEntities() ?? ""
                )
            }
                
            // Call completion handler with trivia questions
            if let firstCategory = triviaResponse.results.first?.category {
                completion(triviaQuestions, firstCategory, nil)
            } else {
                completion(nil, nil, NSError(domain: "No category found", code: 0, userInfo: nil))
            }
            
            } catch {
                print("Error decoding JSON: \(error)") // Print error message
                completion(nil, nil, error)
            }
        }
            // Resume the task
            task.resume()
        }
    }



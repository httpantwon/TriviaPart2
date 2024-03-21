//
//  TriviaViewController.swift
//  Trivia
//  This ViewController remains focused on managing the trivia game flow
//  Created by Antwon Walls on 3/7/24.
//

import UIKit

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension String {
    /*Method responsible for decoding HTML entities from a string. HTML entities are special sequences of characters that are used to represent characters that are difficult or impossible to type directly. For example, "&quot;" represents a double quote character ("), "&amp;" represents an ampersand (&), etc.*/
    /*To properly display text on my app, I need to decode these HTML entities back to their original characters*/
    func decodeHTMLEntities() -> String? {
        /*converts the string to data using UTF-8 encoding*/
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        do {
            /*creates an NSAttributedString from the data, specifying that it's HTML data. An NSAttributedString is a swift type that represents styled and formatted text. This attributed string can be used to display rich text in user interfaces, such as in labels, text views, or buttons*/
            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            return attributedString.string
        } catch {
            print("Error decoding HTML entities: \(error)")
            return nil
        }
    }
}

/*Contains the logic for displaying trivia questions, handling user input for answering questions, updating the game state, etc.*/
class TriviaViewController: UIViewController {
    /*Contains IBOutlets for displaying the trivia question number, question asked, and answer choices, IBActions for handling button taps when the user selects an answer, and handles presenting the game over popup when the game ends*/
    @IBOutlet weak var QuestionAsked: UILabel!
    @IBOutlet weak var questionHeader: UILabel!
    @IBOutlet weak var CategoryLabel: UILabel!
    
    /*IBOutlets allows me to reference the buttons
     in the code and modify its physical properties*/
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var answerButton4: UIButton!
    
    @IBAction func answerButton1(_ sender: UIButton) {
    }
    
    @IBAction func answerButton2(_ sender: UIButton) {
    }
    
    @IBAction func answerButton3(_ sender: UIButton) {
    }
    
    @IBAction func answerButton4(_ sender: UIButton) {
    }
    let triviaService = TriviaQuestionService()
    
    
    var correct_answer = ""
    var gameOverTitle = "Game Over!"
    var gameOverMessage = ""
    var clickCount = 0
    let maxClickCount = 5
    var correctCount = 0
    
    struct TriviaStruct {
        var questionHeaderText: String
        var question: String
        var correct_answer: String
        var incorrect_answer1: String
        var incorrect_answer2: String
        var incorrect_answer3: String
        var category: String
    }
    
    var triviaQuestions: [TriviaStruct] = [
        
    ]
    
    /*Computed property observer in Swift. Used to trigger the configure()
      method whenever the currentQuestionIndex is updated*/
    var currentQuestionIndex = 0 {
        /*Property observer that watches for changes to currentQuestionIndex*/
        didSet {
            //When currentQuestionIndex's value changes, didSet is executed*/
            configure()
        }
    }
    
    //Function checks if the game has ended (if the user has hit 3 questions)
    func checkGameEnd() -> Bool {
        return clickCount >= maxClickCount || currentQuestionIndex >= triviaQuestions.count
    }
    
    func setcorrect_answer() {
        guard let currentQuestion = triviaQuestions[safe: currentQuestionIndex] else {
            print("Error: Unable to set correct answer. Invalid question index.")
            return
        }
        
        // The correct answer is already set to the correct_answer field
        correct_answer = currentQuestion.correct_answer
        
        // Prints the correct answer to verify it's assigned correctly
        print("Correct answer: \(correct_answer)")
    }
    
    func showAlert(_ message: String) {
        gameOverMessage = "Final score: \(correctCount)/5"
        if (currentQuestionIndex == triviaQuestions.count - 1) {
            // Creates aUIAlertController with the specified title and message
            let restartAction = UIAlertController(title: gameOverTitle, message: gameOverMessage, preferredStyle: .alert)
            
            //Adds an action to the alert controller
            restartAction.addAction(UIAlertAction(title: "Restart", style: .default, handler: { action in
                self.resetGame() //resets the game when the user taps Restart button
            }))
            
            //presents the alert with animation
            self.present(restartAction, animated: true, completion: nil)
        }
    }
    
    /*When the user taps the restart button (after answering 3 questions), resets the game state*/
    @IBAction func resetGame() {
        print("Resetting game...")
        
        // Resets number of clicks and correct count after questions are fetched
        clickCount = 0
        correctCount = 0
        currentQuestionIndex = 0
        
        triviaService.fetchTriviaQuestions(amount: 5, difficulty: "easy", type: "multiple", triviaViewController: self) { [weak self] (questions, category, error) in
                if let error = error {
                    print("Error fetching trivia questions: \(error)")
                    // Handle the error, e.g., show an alert to the user
                } else if let questions = questions {
                    // Clear the existing triviaQuestions array
                    self?.triviaQuestions.removeAll()
                    
                    // Populate the triviaQuestions array with the fetched questions
                    self?.triviaQuestions.append(contentsOf: questions)
 
                    self?.configure()
                } else {
                    print("No questions fetched from the API.")
                }
            }
    }
    
    func configure() {
        print("Configuring UI with new questions...")
        
        // Guard statement to ensure currentQuestionIndex stays within bounds
        guard let currentQuestion = triviaQuestions[safe: currentQuestionIndex] else {
            print("Error: Current question is nil or out of bounds.")
            return
        }
        
        /*Sets questionHeaderText to the appropriate value based on the current question index*/
        let questionHeaderText = "Question: \(currentQuestionIndex + 1)/\(triviaQuestions.count)"
        
        // Print the current question to check its values
           print("Current question: \(currentQuestion)")
        
        // Perform UI updates on the main thread
        DispatchQueue.main.async { [weak self] in
            self?.questionHeader.text = questionHeaderText
            self?.CategoryLabel.text = currentQuestion.category
            self?.QuestionAsked.text = currentQuestion.question
            self?.answerButton1.setTitle(currentQuestion.correct_answer, for: .normal)
            self?.answerButton2.setTitle(currentQuestion.incorrect_answer1, for: .normal)
            self?.answerButton3.setTitle(currentQuestion.incorrect_answer2, for: .normal)
            self?.answerButton4.setTitle(currentQuestion.incorrect_answer3, for: .normal)
        }
       
        //Call setcorrect_answer before it's needed
        setcorrect_answer()
    }
    
    /*Triggered when the user taps an answer button. Updates the score when the user clicks on the button AND checks if
        the game has ended*/
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        // Guard statement to check if the game has ended
            if checkGameEnd() {
                // Show the game over alert if the game has ended
                showAlert(gameOverMessage)
                return // Exit the function early
            }
        
        //increment click count
        clickCount += 1
        
        /*Guard is used to safely unwrap an optional value. Essentialy, it
         first checks if the optional value is NOT nil. If NOT nil, safely
         unwraps it and assigns it to a non-optional variable*/
        guard let selectedAnswer = sender.titleLabel?.text else {
            return
        }
        
        if (selectedAnswer == correct_answer) {
            correctCount += 1
        }
        
        //Check if game has ended
        if (checkGameEnd()) {
            showAlert(gameOverMessage)
        } else {
            currentQuestionIndex += 1
            configure()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /*So I don't have to set the # of lines of text and infinitely
         wrap the words so that it doesn't clip across the screen*/
        QuestionAsked.numberOfLines = 0
        QuestionAsked.lineBreakMode = .byWordWrapping
        
        /*Sets the corner radius of each object to half of the height
         to create a circular shape, and make sure the view clips
         to the bounds to apply the rounded corners*/
        QuestionAsked.layer.cornerRadius = QuestionAsked.frame.height / 30
        QuestionAsked.clipsToBounds = true
        answerButton1.layer.cornerRadius = answerButton1.frame.height / 7.5
        answerButton1.clipsToBounds = true
        answerButton2.layer.cornerRadius = answerButton2.frame.height / 7.5
        answerButton2.clipsToBounds = true
        answerButton3.layer.cornerRadius = answerButton3.frame.height / 7.5
        answerButton3.clipsToBounds = true
        answerButton4.layer.cornerRadius = answerButton4.frame.height / 7.5
        answerButton4.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Perform any additional setup after loading the view.
        // Fetch trivia questions from the API when the view loads
        triviaService.fetchTriviaQuestions(amount: 5, difficulty: "easy", type: "multiple", triviaViewController: self) { [weak self] (questions, category, error) in
            if let error = error {
                print("Error fetching trivia questions: \(error)")
                
                // Handle the error, e.g., show an alert to the user
            } else if let questions = questions {
                // Populate the triviaQuestions array with the fetched questions
                self?.triviaQuestions = questions
                
                // Configure the UI with the fetched questions
                self?.configure()
            } else {
                print("No questions fetched from the API.")
            }
        }
    }
}

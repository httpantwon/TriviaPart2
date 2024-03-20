//
//  TriviaGameOverPopup.swift
//  Trivia
//  This ViewController handles the specific functionality related to displaying the game over popup.
//  Created by Antwon Walls on 3/8/24.
//

import UIKit

/*Contains the logic and UI elements specific to the gameover popup ONLY, such as IBOutlets for DISPLAYING the player's final score and the reset button, and IBActions for HANDLING button taps when the player chooses to restart the game*/
class TriviaGameOverPopup: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Adjust content insets to position the popup in the center of the screen
            let horizontalInset: CGFloat = 50 // Adjust as needed
            let verticalInset: CGFloat = 100 // Adjust as needed
            view.frame = CGRect(x: horizontalInset, y: verticalInset, width: view.frame.width - (2 * horizontalInset), height: view.frame.height - (2 * verticalInset))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

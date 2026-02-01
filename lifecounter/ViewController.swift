//
//  ViewController.swift
//  lifecounter
//
//  Created by Eric Chou on 2/1/26.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var player1LifeLabel: UILabel!
    @IBOutlet weak var player2LifeLabel: UILabel!
    
    var player1Life = 20
    var player2Life = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        player1LifeLabel.text = "\(player1Life)"
        player2LifeLabel.text = "\(player2Life)"
        
        if player1Life <= 0 {
            resultLabel.text = "Player 1 LOSES!"
            resultLabel.textColor = .red
            resultLabel.isHidden = false
        } else if player2Life <= 0 {
            resultLabel.text = "Player 2 LOSES!"
            resultLabel.textColor = .red
            resultLabel.isHidden = false
        } else {
            resultLabel.isHidden = true
        }
    }
    
    @IBAction func player1PlusTapped(_ sender: UIButton) {
        player1Life += 1
        updateUI()
    }
    
    @IBAction func player1Plus5Tapped(_ sender: UIButton) {
        player1Life += 5
        updateUI()
    }
    
    @IBAction func player1MinusTapped(_ sender: UIButton) {
        player1Life -= 1
        updateUI()
    }
    
    @IBAction func player1Minus5Tapped(_ sender: UIButton) {
        player1Life -= 5
        updateUI()
    }
    
    @IBAction func player2PlusTapped(_ sender: UIButton) {
        player2Life += 1
        updateUI()
    }
    
    @IBAction func player2Plus5Tapped(_ sender: UIButton) {
        player2Life += 5
        updateUI()
    }
    
    @IBAction func player2MinusTapped(_ sender: UIButton) {
        player2Life -= 1
        updateUI()
    }
    
    @IBAction func player2Minus5Tapped(_ sender: UIButton) {
        player2Life -= 5
        updateUI()
    }
}

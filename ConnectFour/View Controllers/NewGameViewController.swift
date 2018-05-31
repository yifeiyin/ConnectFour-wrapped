//
//  NewGameViewController.swift
//  ConnectFour
//
//  Created by YinYifei on 2018-05-08.
//  Copyright © 2018 Yifei Yin. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController {

    var game: ConnectFour?
    
    @IBAction func NewGame(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let _connectFourVC = storyboard.instantiateViewController(withIdentifier: "ConnectFourViewController")
        
        if let connectFourVC = _connectFourVC  as? ConnectFourViewController {
            if game == nil || (game?.isGameEnded)! {
                game = ConnectFour()
            }
            connectFourVC.game = game
            present(connectFourVC, animated: true)
        }
    }
    
}

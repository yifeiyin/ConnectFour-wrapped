//
//  ViewController.swift
//  ConnectFour
//
//  Created by YinYifei on 2018-02-16.
//  Copyright © 2018 Yifei Yin. All rights reserved.
//

import UIKit

class ConnectFourViewController: UIViewController {

    @IBOutlet weak var leftPlayerImageView: UIImageView!
    @IBOutlet weak var rightPlayerImageView: UIImageView!
    @IBOutlet weak var leftPlayerLabel: UILabel!
    @IBOutlet weak var rightPlayerLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet var tubeViews: [TubeView]!

    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(HandleLongPress))
            longPress.allowableMovement = 5
            longPress.minimumPressDuration = 0.0
            longPress.numberOfTapsRequired = 0
            longPress.numberOfTouchesRequired = 1
            stackView.addGestureRecognizer(longPress)
        }
    }
    
    @IBAction func GoBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func newGameButtonPushed(_ sender: Any) {
        struct newGameAnimationConstants {
            static let duration: TimeInterval = 0.3
            static let timeOffset: TimeInterval = 0.2
        }
// Alternative Animation, simpler, faster
//
//        for index in 0..<tubeViews.count {
//            UIView.transition(with: tubeViews[index],
//                              duration: newGameAnimationConstants.duration,
//                              options: [UIViewAnimationOptions.transitionCurlUp],
//                              animations: {
//                                [unowned self] in self.game.ClearTube(at: index)
//                                self.UpdateViewFromModel()
//                                }
//            )
//        }
//        game.ResetGame()
        func Animate(at index: Int) {
            if index >= tubeViews.count { return }
            UIView.transition(with: tubeViews[index],
                              duration: newGameAnimationConstants.duration,
                              options: [.transitionFlipFromLeft],
                              animations: { [unowned self] in
                                self.game.ClearTube(at: index)
                                self.UpdateViewFromModel()
                                },
                              completion: index == tubeViews.count ? {Bool in self.game.ResetGame() } : { (Bool) in Animate(at: index+1) }
            )
        }
        Animate(at: 0)
        
        UpdateViewFromModel()
    }
    
    @objc func HandleLongPress(_ sender: UITapGestureRecognizer) {
        var indexOfTubeTouchingLocal: Int?
        for index in 0..<tubeViews.count {
            if tubeViews[index].bounds.contains(sender.location(in: tubeViews[index])) {
                indexOfTubeTouchingLocal = index
            }
        }
        switch sender.state {
        case .began, .changed:
            indexOfTubeTouching = indexOfTubeTouchingLocal
        case .ended:
            if indexOfTubeTouchingLocal != nil {
                game.Push(at: indexOfTubeTouchingLocal!)
                UpdateViewFromModel()
            }
            indexOfTubeTouching = nil
        default: break
        }
    }
    
    private var indexOfTubeTouching: Int? {
        didSet {
            switch indexOfTubeTouching {
            case nil:
                for index in 0..<tubeViews.count {
                    tubeViews[index].backgroundColor = ColorConstants.unselected
                }
            default:
                for index in 0..<tubeViews.count {
                    if index == indexOfTubeTouching {
                        if let player = game.currentPlayerInTurn {
                            switch (player, game.isPushable(at: index)) {
                            case (.A, true): tubeViews[index].backgroundColor = ColorConstants.PlayerA.succeed
                            case (.A, false): tubeViews[index].backgroundColor = ColorConstants.PlayerA.failed
                            case (.B, true): tubeViews[index].backgroundColor = ColorConstants.PlayerB.succeed
                            case (.B, false): tubeViews[index].backgroundColor = ColorConstants.PlayerB.failed
                            }
                        }
                    } else {
                        tubeViews[index].backgroundColor = ColorConstants.unselected
                    }
                }
            }
        }
    }
    
    func UpdateViewFromModel() {
        for tubeIndex in 0..<tubeViews.count {
            tubeViews[tubeIndex].data = game.board[tubeIndex]
            tubeViews[tubeIndex].setNeedsDisplay()
        }
        switch game.gameStatus {
        case .playerInTurn(.A):
            leftPlayerImageView.image = UIImage(named:"Blue Selected")
            rightPlayerImageView.image = UIImage(named:"Green Unselected")
            promptLabel.text = "waiting for blue"
        case .playerInTurn(.B):
            leftPlayerImageView.image = UIImage(named:"Blue Unselected")
            rightPlayerImageView.image = UIImage(named:"Green Selected")
            promptLabel.text = "waiting for green"
        case .someoneWins(.A):
            leftPlayerImageView.image = UIImage(named:"Blue Selected")
            rightPlayerImageView.image = UIImage(named:"Green Unselected")
            promptLabel.text = "blue wins!"
        case .someoneWins(.B):
            leftPlayerImageView.image = UIImage(named:"Blue Unselected")
            rightPlayerImageView.image = UIImage(named:"Green Selected")
            promptLabel.text = "green wins!"
        case .ties:
            leftPlayerImageView.image = UIImage(named:"Blue Selected")
            rightPlayerImageView.image = UIImage(named:"Green Selected")
            promptLabel.text = "draws"
        }
        promptLabel.sizeToFit()
    }
    
    var game: ConnectFour!

    override func viewDidLoad() {
        super.viewDidLoad()
        var multiplier: CGFloat
        let width = tubeViews[0].bounds.maxX
        let diameter = width * Constants.DiameterToWidthRatio
        let dis = (width - diameter) / 2 // distance between the edge of the circle and the edge of the tubeView
        multiplier = (7*(2*dis+diameter)+6*(stackView.spacing))/(7*dis+6*diameter)  // The multiplier should be around 7.0/6.0 = 1.17
        let constraintOfStackViewAspectRatio =
            NSLayoutConstraint(item: stackView,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: stackView,
                               attribute: NSLayoutAttribute.height,
                               multiplier: multiplier,
                               constant: 0)
        stackView.addConstraint(constraintOfStackViewAspectRatio)
        UpdateViewFromModel()
        indexOfTubeTouching = nil
    }
}

extension ConnectFourViewController {
    private struct ColorConstants {
        static let unselected = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        struct PlayerA {
            static let succeed = #colorLiteral(red: 0, green: 0.7235352397, blue: 0.9667306542, alpha: 1)
            static let failed = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        struct PlayerB {
            static let succeed = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            static let failed = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
    }
    
    struct Constants {
        static let LineWidth: CGFloat = 6.0
        static let DiameterToWidthRatio: CGFloat = 0.7
    }
}

extension ConnectFour.Status : CustomStringConvertible {
    var description: String {
        switch self {
        case .playerInTurn(.A): return "current player: A(blue)"
        case .playerInTurn(.B): return "current player: B(green)"
        case .someoneWins(.A): return "A(blue) wins"
        case .someoneWins(.B): return "B(green) wins"
        case .ties: return "ties"
        }
    }
}


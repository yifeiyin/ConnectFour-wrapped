//
//  TubeView.swift
//  ConnectFour
//
//  Created by YinYifei on 2018-02-19.
//  Copyright © 2018 Yifei Yin. All rights reserved.
//

import UIKit

class TubeView: UIView {
    
    var data = Array(repeating: ConnectFour.CellState.empty, count: ConnectFour.Height)
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        for altitude in 0..<ConnectFour.Height {
            let centerX: CGFloat = bounds.maxX / 2.0
            let width: CGFloat = bounds.maxX
            let diameter: CGFloat = width * ConnectFourViewController.Constants.DiameterToWidthRatio
            let radius: CGFloat = diameter / 2
            let dis: CGFloat = (width - diameter) / 2 // distance between the edge of circle and the edge of the tube
            let centerY: CGFloat = bounds.maxY - (CGFloat(altitude) * (dis + diameter) + dis + radius)
            let center = CGPoint(x: centerX, y: centerY)
            
            let path = UIBezierPath()
            path.addArc(withCenter: center,
                        radius: bounds.maxX*ConnectFourViewController.Constants.DiameterToWidthRatio/2,
                        startAngle: 0,
                        endAngle: 2*CGFloat.pi,
                        clockwise: true)
            path.lineWidth = ConnectFourViewController.Constants.LineWidth
            let (fill, stroke) = getColorForFillAndStroke(ofcellState: data[altitude])
            fill.setFill()
            stroke.setStroke()
            path.stroke()
            path.fill()
        }
    }
    

}

extension TubeView {
    private func getColorForFillAndStroke(ofcellState cellState: ConnectFour.CellState) -> (UIColor, UIColor)
    {
        switch cellState {
        case .empty: return ( #colorLiteral(red: 0.9402408004, green: 0.9499949813, blue: 0.956296742, alpha: 1) , #colorLiteral(red: 0.8465040326, green: 0.8763965964, blue: 0.8895147443, alpha: 1) )
        case .occupied(.A): return ( #colorLiteral(red: 0.3647058824, green: 0.8078431373, blue: 0.9764705882, alpha: 1) , #colorLiteral(red: 0, green: 0.608522296, blue: 0.8547416329, alpha: 1) ) // blue
        case .occupied(.B): return ( #colorLiteral(red: 0.3536864519, green: 0.7271710634, blue: 0.3864591122, alpha: 1) , #colorLiteral(red: 0.2666389048, green: 0.613206923, blue: 0.300658226, alpha: 1) ) // green
        }
    }
}

//
//  ReviewTimesRing.swift
//  AppStoreReviewTime
//
//  Created by Arbel Israeli on 21/08/2016.
//  Copyright © 2016 arbel03. All rights reserved.
//

import UIKit

@IBDesignable
class ReviewTimesRing: UIView {

    func getCenter(rect: CGRect) -> CGPoint {
        return CGPoint(x: rect.width/2, y: rect.height/2)
    }
    
    func getGradient() -> CGGradient? {
        let colors = [UIColor(red: 255/255, green: 65/255, blue: 60/255, alpha: 1.0),
                      UIColor(red: 235/255, green: 50/255, blue: 115/255, alpha: 1.0),
                      UIColor(red: 210/255, green: 40/255, blue: 179/255, alpha: 1.0),
                      UIColor(red: 150/255, green: 30/255, blue: 140/255, alpha: 1.0),
                      UIColor(red: 30/255, green: 90/255, blue: 250/255, alpha: 1.0)
			].map {$0.cgColor}
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
		let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        return gradient
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
        // Drawing code
        let lineWidth: CGFloat = 5
		let outterArc = UIBezierPath(arcCenter: getCenter(rect: rect), radius: min(rect.width/2, rect.height/2), startAngle: 0 , endAngle: CGFloat(M_PI*2), clockwise: true)
		let innerArc = UIBezierPath(arcCenter: getCenter(rect: rect), radius: min(rect.width/2, rect.height/2)-1.5*lineWidth, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        
		outterArc.append(innerArc)
        outterArc.usesEvenOddFillRule = true
        outterArc.addClip()
        
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)
        
        let gradient = getGradient()
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: rect.width, y: rect.height)
		context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
    }

}

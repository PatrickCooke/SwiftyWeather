//
//  HourlyWeatherCell.swift
//  SwiftyWeather
//
//  Created by Patrick Cooke on 7/6/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

@IBDesignable
class HourlyWeatherCell: UICollectionViewCell {
 
    @IBOutlet weak var timeLabel    :UILabel!
    @IBOutlet weak var actTempLabel :UILabel!
    @IBOutlet weak var appTempLabel :UILabel!
    @IBOutlet weak var precipLabel  :UILabel!
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0 //MASK TO BOUNDS makes the corners which are cut off to show up as clear
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
    
}

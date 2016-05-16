//
//  Weather.swift
//  SwiftyWeather
//
//  Created by Patrick Cooke on 5/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class Weather: NSObject {
    var curTemp        :Double!
    var curAppTemp     :Double!
    var curIcon        :String!
    var curPrecip      :Double!
    var curSummary     :String!
    var curWind        :Double!
    var curHumid       :Double!
    var locLat         :Double!
    var locLon         :Double!
    var locCoord       :String!
}
//
//  TodayViewController.swift
//  SwiftyWeatherWidget
//
//  Created by Patrick Cooke on 6/28/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var dataManager = DataManager.sharedInstance
    var networkManager = NetworkManager.sharedInstance
    var dailyArray = [DailyWeather]()
    @IBOutlet weak var LocationLabel    :UILabel!
    @IBOutlet weak var currentTempLabel :UILabel!
    @IBOutlet weak var highLowLabel     :UILabel!
    @IBOutlet weak var precipLabel      :UILabel!
    @IBOutlet weak var summaryLabel     :UILabel!
    
    
    //MARK: - Get Current Weather Method
    
    //MARK: - Fill Info Method
    
    func blankEverything() {
        LocationLabel.text = ""
        currentTempLabel.text = ""
        highLowLabel.text = ""
        precipLabel.text = ""
        summaryLabel.text = ""
    }
    
    func fillEverythingOut() {
        if let currentCity = dataManager.currentWeather.curCity{
            LocationLabel.text = currentCity
        }
        if let currentTemp = dataManager.currentWeather.curTemp{
            let curTemp = Int(currentTemp)
            currentTempLabel.text = ("\(curTemp)°F")
        }
        if let dailyPrecip = dataManager.currentWeather.dailyforcast.first?.precipOdds {
            if let nowprecip = dataManager.currentWeather.curPrecip {
                let dprecip = Int(dailyPrecip * 100)
                let nprecip = Int(nowprecip * 100)
                precipLabel.text = "Now: \(nprecip), later: \(dprecip)%"
            }
            
            if let currentSummary = dataManager.currentWeather.curSummary {
                    if let hourlysummary = dataManager.currentWeather.hourlySummary {
                        summaryLabel.text = "The current weather is: " + currentSummary + ". Upcoming: " + hourlysummary
                }
            }
        }
        if let todayHigh = dataManager.currentWeather.dailyforcast.first?.dayMaxTemp {
            if let todayLow = dataManager.currentWeather.dailyforcast.first?.dayMinTemp {
                let high = Int(todayHigh)
                let low = Int(todayLow)
                highLowLabel.text = "\(high)/\(low)"
            }
        }
    }

    //MARK: - Making it look Ok
    
    func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsetsZero
    }
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blankEverything()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {


        completionHandler(NCUpdateResult.NewData)
    }
    
}

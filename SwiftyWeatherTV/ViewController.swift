//
//  ViewController.swift
//  SwiftyWeatherTV
//
//  Created by Patrick Cooke on 6/14/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var dataManager = DataManager.sharedInstance
    var networkManager = NetworkManager.sharedInstance
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var LocationLabel    :UILabel!
    @IBOutlet weak var currentTempLabel :UILabel!
    @IBOutlet weak var feelsLikeLabel   :UILabel!
    @IBOutlet weak var windSpeedLabel   :UILabel!
    @IBOutlet weak var precipLabel      :UILabel!
    @IBOutlet weak var iconImageView    :UIImageView!
    @IBOutlet weak var addressSearchTextField :UITextField!
    @IBOutlet weak var summaryTxtView   :UITextView!
    private var dailyArray = [DailyWeather]()
    @IBOutlet weak var highLowLabel     :UILabel!
    @IBOutlet weak var dailyCollectionView  :UICollectionView!
    
    
    //MARK: - CollectionView Methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dailyArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! DailyWeatherCell
        
        let selecteddate = dailyArray[indexPath.row]
        
        if let date = selecteddate.time {
            let date1 = NSDate(timeIntervalSince1970: date)
            let formatter = NSDateFormatter()
            formatter.dateFormat = "E"
            let dayOfWeek = formatter.stringFromDate(date1)
            if let todayHigh = selecteddate.dayMaxTemp {
                if let todayLow = selecteddate.dayMinTemp {
                    let high = Int(todayHigh)
                    let low = Int(todayLow)
                    cell.dateLabel.text = "\(dayOfWeek): \(high)°F/\(low)°F"
                }
            }
            
        }
        if let icon = selecteddate.dayIcon {
            cell.dateIcon.image = UIImage (named: icon)
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(200, 150)
    }
    

    private func performGeocode() {
        if networkManager.serverAvailable{
            if let address = addressSearchTextField.text {
                dataManager.geoCoder(address)
            } else {
                print("Hey type something first")
            }
        } else {
            print("server not available at get")
        }
    }
    
    @IBAction func getButtonPressed() {
        performGeocode()
        addressSearchTextField.text = ""
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        addressSearchTextField.resignFirstResponder()
        performGeocode()
        addressSearchTextField.text = ""
    }
    
    func fillEverythingOut() {
        if let currentCity = dataManager.currentWeather.curCity{
            LocationLabel.text = currentCity
        }
        if let currentTemp = dataManager.currentWeather.curTemp{
            let curTemp = Int(currentTemp)
            currentTempLabel.text = ("\(curTemp)°F")
        }
        if let apptemp = dataManager.currentWeather.curAppTemp {
            let estimateTemp = Int(apptemp)
            feelsLikeLabel.text = ("\(estimateTemp) °F")
        }
        if let windspeed = dataManager.currentWeather.curWind {
            let windspeed2 = Int(windspeed)
            windSpeedLabel.text = "\(windspeed2) mph"
        }
        
        if let dailyPrecip = dataManager.currentWeather.dailyforcast.first?.precipOdds {
            if let nowprecip = dataManager.currentWeather.curPrecip {
                let dprecip = Int(dailyPrecip * 100)
                let nprecip = Int(nowprecip * 100)
                precipLabel.text = "now: \(nprecip)%, later: \(dprecip)%"
            }
        }
        
        if let currentIcon = dataManager.currentWeather.curIcon {
            iconImageView.image = UIImage (named: currentIcon )
        }
        if let currentSummary = dataManager.currentWeather.curSummary {
            if let dailysummary = dataManager.currentWeather.dailySummary{
                if let hourlysummary = dataManager.currentWeather.hourlySummary {
                    summaryTxtView.text = "The current weather is: " + currentSummary + ". Upcoming: " + hourlysummary + " Forcast: " + dailysummary
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
    
    private func blankeverything() {
        LocationLabel.text = ""
        currentTempLabel.text = ""
        feelsLikeLabel.text = ""
        windSpeedLabel.text = ""
        precipLabel.text = ""
        iconImageView.image = nil
        summaryTxtView.text = ""
    }
    
    //MARK: - Data Methods
    
    func newDataRecv() {
        blankeverything()
        dailyArray = dataManager.currentWeather.dailyforcast
        fillEverythingOut()
        dailyCollectionView.reloadData()
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newDataRecv), name: "recvNewDataFromServer", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}




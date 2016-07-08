//
//  ViewController.swift
//  SwiftyWeather
//
//  Created by Patrick Cooke on 5/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var dataManager = DataManager.sharedInstance
    var networkManager = NetworkManager.sharedInstance
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var LocationLabel    :UILabel!
    @IBOutlet weak var currentTempLabel :UILabel!
    @IBOutlet weak var feelsLikeLabel   :UILabel!
    @IBOutlet weak var windSpeedLabel   :UILabel!
    @IBOutlet weak var precipLabel      :UILabel!
    @IBOutlet weak var iconImageView    :UIImageView!
    @IBOutlet weak var addressSearchBar :UISearchBar!
    @IBOutlet weak var summaryTxtView   :UITextView!
    private var locArray = [Locations]()
    private var dailyArray = [DailyWeather]()
    private var hourlyArray = [HourlyWeather]()
    @IBOutlet weak var locTableView     :UITableView!
    @IBOutlet weak var highLowLabel     :UILabel!
    var locationManager = CLLocationManager()
    @IBOutlet weak var dailyCollectionView  :UICollectionView!
    @IBOutlet weak var locationBarButton    :UIBarButtonItem!
    @IBOutlet weak var hourDaySegCtrl       :UISegmentedControl!

    
    //MARK: - CollectionView Methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch hourDaySegCtrl.selectedSegmentIndex {
        case 0:
            return dailyArray.count
        case 1:
            return hourlyArray.count
        default:
            return dailyArray.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch hourDaySegCtrl.selectedSegmentIndex {
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! DailyWeatherCell
            
            let selecteddate = dailyArray[indexPath.row]
            
            if let date = selecteddate.time {
                //            print("raw date format \(date)")
                let date1 = NSDate(timeIntervalSince1970: date)
                //            print("converted date: \(date1)")
                let formatter = NSDateFormatter()
                formatter.dateFormat = "E"
                let dayOfWeek = formatter.stringFromDate(date1)
                //            print(dayOfWeek)
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
        case 1:
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("hcell", forIndexPath: indexPath) as! HourlyWeatherCell
            
            let selectedcell = hourlyArray[indexPath.row]
            
            if let date = selectedcell.hourTime {
                //            print("raw date format \(date)")
                let date1 = NSDate(timeIntervalSince1970: date)
                //            print("converted date: \(date1)")
                let formatter = NSDateFormatter()
                formatter.dateFormat = "E h:mma"
                let dayOfWeek = formatter.stringFromDate(date1)
                //            print(dayOfWeek)
                cell.timeLabel.text = dayOfWeek
            }
            
            if let tempactual = selectedcell.hourActTemp {
                let actTempInt = Int(tempactual)
                cell.actTempLabel.text = "Temperature: \(actTempInt)°F"
            }
            
            if let tempFeels = selectedcell.hourAppTemp {
                let appTempInt = Int(tempFeels)
                    cell.appTempLabel.text = "Feels like: \(appTempInt)°F"
            }
            
            if let precip = selectedcell.hourPrecip {
                let precipInt = Int(precip * 100)
                if let type = selectedcell.hourPrecipType {
                    cell.precipLabel.text = "\(precipInt)% chance of \(type)"
                }
            }
            return cell
            
        default:
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! DailyWeatherCell
            return cell
        }
    }
        
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(125, 75)
    }
    
    @IBAction func changeCollectionView() {
        dailyCollectionView.reloadData()
    }
    
    //MARK: - Table Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let storedCity = locArray[indexPath.row]
        cell.textLabel!.text = storedCity.locDescription
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let objToDelete = locArray[indexPath.row]
            managedObjectContext.deleteObject(objToDelete)
            appDelegate.saveContext()
            loadLocArray()
            locTableView!.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let objectslected = locArray[indexPath.row]
        if let lat = objectslected.locLat {
            if let lon = objectslected.locLon {
                let coords = "\(lat),\(lon)"
                if let city = objectslected.locDescription {
//                print("Pre \(coords)")
                dataManager.getDataFromServer(coords, city: city)
                }
            }
        }
    }
    
    
    //MARK: - Interactivity
    
    func fetchEntries() -> [Locations]? {
        let fetchRequest = NSFetchRequest(entityName: "Locations")
//        print("fetch")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "locDescription", ascending: true)]
        do {
            let tempArray = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Locations]
            return tempArray
        }catch {
            return nil
        }
    }
    
    private func loadLocArray() {
         locArray = fetchEntries()!
    }
    
    @IBAction private func saveLocationPressed () {
        let entityDescription = NSEntityDescription.entityForName("Locations", inManagedObjectContext: managedObjectContext)!
        let searchedCity = Locations(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        searchedCity.locDescription = dataManager.currentWeather.curCity
        searchedCity.locLat = String(dataManager.currentWeather.locLat)
        searchedCity.locLon = String(dataManager.currentWeather.locLon)
        searchedCity.dateEntered = NSDate()
        appDelegate.saveContext()
        loadLocArray()
        locTableView!.reloadData()
        
    }
    
    private func performGeocode() {
        if networkManager.serverAvailable{
            if let address = addressSearchBar.text {
                dataManager.geoCoder(address)
            } else {
//                print("Hey type something first")
            }
        } else {
//            print("server not available at get")
        }
    }
    
    @IBAction private func getButtonPressed() {
        addressSearchBar.resignFirstResponder()
        performGeocode()
        addressSearchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        addressSearchBar.resignFirstResponder()
        performGeocode()
        addressSearchBar.text = ""
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
            precipLabel.text = "for now: \(nprecip), for later: \(dprecip)%"
        }
        if let currentIcon = dataManager.currentWeather.curIcon {
            iconImageView.image = UIImage (named: currentIcon)
            }
            
        if let currentSummary = dataManager.currentWeather.curSummary {
            if let dailysummary = dataManager.currentWeather.dailySummary{
                if let hourlysummary = dataManager.currentWeather.hourlySummary {
                        summaryTxtView.text = "The current weather is: " + currentSummary + ". Upcoming: " + hourlysummary + " Forcast: " + dailysummary
                    
                    }
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
    
    func blankeverything() {
        LocationLabel.text = ""
        currentTempLabel.text = ""
        feelsLikeLabel.text = ""
        windSpeedLabel.text = ""
        precipLabel.text = ""
        iconImageView.image = nil
        summaryTxtView.text = ""
    }
    
    //MARK: - Location Methods
    
    @IBAction func getLocation() {
        setUsersClosestCity()
    }

    func setUsersClosestCity() {
        if CLLocationManager.locationServicesEnabled() && UI_USER_INTERFACE_IDIOM() != .Pad {
            
            guard let loc = locationManager.location else {
                return
            }
            let locValue = loc.coordinate
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            geoCoder.reverseGeocodeLocation(location) {
                (placemarks, error) -> Void in
                let placeArray = placemarks as [CLPlacemark]!
                var placeMark: CLPlacemark! // Place details
                placeMark = placeArray?[0]
                if let city = placeMark.addressDictionary?["City"] as? NSString { // City
                    let coords = "\(locValue.latitude),\(locValue.longitude)"
                    self.dataManager.getDataFromServer(coords, city: city as String)
                }
            }
        }
    }

    //MARK: - Data Methods
    
    func newDataRecv() {
        blankeverything()
        dailyArray = dataManager.currentWeather.dailyforcast
        hourlyArray = dataManager.currentWeather.hourlyforcast
        fillEverythingOut()
        dailyCollectionView.reloadData()
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newDataRecv), name: "recvNewDataFromServer", object: nil)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            locationBarButton.enabled = false
            locationBarButton.tintColor = UIColor.clearColor()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadLocArray()
        locTableView.reloadData()
        setUsersClosestCity()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}


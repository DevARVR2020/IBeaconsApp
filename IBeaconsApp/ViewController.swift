//
//  ViewController.swift
//  IBeaconsApp
//
//  Created by Krishnaveni on 4/10/20.
//  Copyright © 2020 Krishnaveni. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController ,CBPeripheralManagerDelegate{

  @IBOutlet weak var beaconStatus: UILabel!
    
    let locationManager = CLLocationManager()
    let myBTManager = CBPeripheralManager()
    var lastStage = CLProximity.unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      // Define in iBeacon.swift locationmanager.delegate = self
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            self.setupBeacon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
            

        if peripheral.state == .poweredOff {
            print("Peripheral manager is off.")
            simpleAlert(title: "Beacon", message: "Turn On Your Device Bluetooh")
           
        } else if peripheral.state == .poweredOn {
            print("Peripheral manager is on.")
            simpleAlert(title: "Beacon", message: "Bluetooh Connected")
           
        }
        
    }

}
extension ViewController: CLLocationManagerDelegate {

        func setupBeacon() {

            locationManager.delegate = self
            
            // Enter Your iBeacon UUID
           // let uuid = NSUUID(uuidString: "bebbf6eb-a2cb-47be-aec5-8bb6a2c8ffda")!
         //   let uuid = NSUUID(uuidString: "37F8E091-26D9-4B92-8646-3AE9665288B6")!
            
            // Use identifier like your company name or website
            let uuid = UUID(uuid: UIDevice.current.identifierForVendor!.uuid)
            
                print(uuid)
            
            let identifier = "com.alphansotech"
            
            let Major:CLBeaconMajorValue = 100
            let Minor:CLBeaconMinorValue = 1
            
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid , major: Major, minor: Minor, identifier: identifier)
            
            print("beaconRegion\(beaconRegion)")
            // called delegate when Enter iBeacon Range
            beaconRegion.notifyOnEntry = true
            
            // called delegate when Exit iBeacon Range
            beaconRegion.notifyOnExit = true
            
            // Requests permission to use location services
            locationManager.requestAlwaysAuthorization()
            
            locationManager.requestState(for: beaconRegion)
            // Starts monitoring the specified iBeacon Region
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(in: beaconRegion)
            //locationManager.pausesLocationUpdatesAutomatically = false
        }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
            
        case .authorizedAlways:
            // Starts the generation of updates that report the user’s current location.
            locationManager.startUpdatingLocation()

        case .restricted:
            
            // Your app is not authorized to use location services.
            
            simpleAlert(title: "Permission Error", message: "Need Location Service Permission To Access Beacon")


        case .denied:
            
            // The user explicitly denied the use of location services for this app or location services are currently disabled in Settings.
            
            simpleAlert(title: "Permission Error", message: "Need Location Service Permission To Access Beacon")

        default:
            // handle .NotDetermined here
            
            // The user has not yet made a choice regarding whether this app can use location services.
             simpleAlert(title: "Permission Error", message: "Not Choosen")
            break
        }
    }
    
    func simpleAlert (title:String,message:String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
          
          // Tells the delegate that a iBeacon Area is being monitored
          
        locationManager.requestState(for: region)
      }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
          
          // Tells the delegate that the user entered in iBeacon range or area.
          
        simpleAlert(title: "Welcom", message: "Welcome to our store")

      }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
          
          // Tells the delegate that the user exit the iBeacon range or area.
          
        simpleAlert(title: "Good Bye", message: "Have a nice day")
          
      }
      
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
          
          switch  state {
              
          case .inside:
              //The user is inside the iBeacon range.
            locationManager.startRangingBeacons(in: region as! CLBeaconRegion)
              break
          case .outside:
              //The user is outside the iBeacon range.
            locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
              break
          default :
              // it is unknown whether the user is inside or outside of the iBeacon range.
              break
              
          }
      }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        // Tells the delegate that one or more beacons are in range.
       let foundBeacons = beacons
        
        if foundBeacons.count > 0 {
            
            if let closestBeacon = foundBeacons[0] as? CLBeacon {
                    
                    let proximityMessage: String!
                if lastStage != closestBeacon.proximity {
                    
                    lastStage = closestBeacon.proximity
                    
                    switch  lastStage {
                        
                    case .immediate:
                        proximityMessage = "Very close"
                        self.view.backgroundColor = UIColor.green
                        
                    case .near:
                        proximityMessage = "Near"
                        self.view.backgroundColor = UIColor.gray
                        
                    case .far:
                        proximityMessage = "Far"
                        self.view.backgroundColor = UIColor.black
                        
                        
                    default:
                        proximityMessage = "Where's the beacon?"
                        self.view.backgroundColor = UIColor.red
                        
                    }
                    var makeString = "Beacon Details:n"
                    makeString += "UUID = (closestBeacon.proximityUUID.UUIDString)n"
                    makeString += "Identifier = (region.identifier)n"
                    makeString += "Major Value = (closestBeacon.major.intValue)n"
                    makeString += "Minor Value = (closestBeacon.minor.intValue)n"
                    makeString += "Distance From iBeacon = \(String(describing: proximityMessage))"

                    self.beaconStatus.text = makeString
              }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(String(describing: region)) \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Location manager failed: \(error.localizedDescription)")
    }
    
}

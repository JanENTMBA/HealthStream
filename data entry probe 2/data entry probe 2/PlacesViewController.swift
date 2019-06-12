//
//  PlacesViewController.swift
//  data entry probe 2
//
//  Created by Jan Rombout on 28/05/2019.
//  Copyright © 2019 Rommed BV. All rights reserved.
//

import UIKit
import MapKit
import QuadratTouch


class PlacesViewController: UIViewController, CLLocationManagerDelegate
{

    @IBOutlet weak var mapView: MKMapView?
//  connection to mapView
    
    var locationManager:CLLocationManager?
    
    var client:Client?
    var session:Session?
    
    var places:[[String:Any]] = [[String:Any]]()
    
    var hasFinishedQuery:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
//  connection to delegate func locationManager
        
        if(locationManager != nil) {
            locationManager!.requestAlwaysAuthorization()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager!.distanceFilter = 50.0
            locationManager!.startUpdatingLocation()
        }
        setupFoursquare()
    }
    
    func  setupFoursquare() {
//      connect to Foursquare
        
        client = Client(clientID: "N221A2ZQDVGTKWL3GGWIB5M2E0NUKP0AMFDIBLNLQOPURCHQ", clientSecret: "C0MSQID3XP22WGZ5LGRF0LHSL2RNU105N0WS3OPYAXU3TMJ3", redirectURL: "")
        
        if client != nil {
            let configuration = Configuration(client: client!)
            Session.setupSharedSessionWithConfiguration(configuration)
        }
        session = Session.sharedSession()
    }
    
    func queryFoursquare(location:CLLocation)
    {
        if session == nil || hasFinishedQuery == false
        {
            return
        }
        
        places.removeAll()
        
        var parameters = location.parameters()
        parameters += [Parameter.categoryId:"4d4b7105d754a06374d81259"] // Only Food category
        parameters += [Parameter.radius:"100"]
        
        let searchTask = session!.venues.search(parameters) {
            (result) -> Void in
            if let response = result.response
            {
                print(response)
                
                var venues = response["venues"] as! [[String: AnyObject]]
                
                for venue in venues
                {
                    var name:String = venue["name"] as! String
                    
                    if  let location:[String:AnyObject] = venue["location"] as? [String:AnyObject],
                        let latitude:Double = location["lat"] as? Double,
                        let longitude:Double = location["lng"] as? Double,
                        let formattedAddress:[String] = location["formattedAddress"] as? [String]
                    {
                        var address = formattedAddress.joined(separator: " ")
                        
                        self.places.append([
                            "name": name,
                            "address": address,
                            "latitude": latitude,
                            "longitude": longitude
                            ])
                    }
                }
                
                print(self.places)
                
                self.hasFinishedQuery = true
            }
        }
        
        searchTask.start()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            if mapView != nil {
                let adjustedRegion = mapView!.regionThatFits(region)
                mapView!.setRegion(adjustedRegion, animated: true)
            }
            print(newLocation)
        }
    }


}

extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}

/*
 Client ID
 N221A2ZQDVGTKWL3GGWIB5M2E0NUKP0AMFDIBLNLQOPURCHQ
 Client Secret
 C0MSQID3XP22WGZ5LGRF0LHSL2RNU105N0WS3OPYAXU3TMJ3
 
 */

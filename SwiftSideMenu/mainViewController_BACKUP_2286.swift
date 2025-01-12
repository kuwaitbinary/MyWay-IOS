//
//  ViewController.swift
//  GgleMapSwift
//
//  Created by Abdullah Al Mashmoum on 8/13/15.
//  Copyright (c) 2015 Abdullah Al Mashmoum. All rights reserved.
//


import UIKit
import GoogleMaps
 

class mainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, ENSideMenuDelegate {


    var actionSheet = AHKActionSheet()
    
    var clearBtn:UIBarButtonItem = UIBarButtonItem()
    
    var favBool:Bool = false
    var favString:String = "Toggle Fav"
    
    @IBOutlet var favButton: UIButton!
    
    
    var placePicker: GMSPlacePicker?
    var placesClient: GMSPlacesClient?

    // Instantiate a pair of UILabels in Interface Builder
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    //Declaring variable and IBAction and Outlet
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    @IBAction func menuButton(sender: AnyObject) {
        toggleSideMenuView()
    }
        @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblLongLat: UILabel!
    
    var mapTasks = MapTasks()
    
    var locationMarker: GMSMarker!
    
    var originMarker: GMSMarker!
    
    var destinationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!
    
    var markersArray: Array<GMSMarker> = []
    
    var waypointsArray: Array<String> = []
    
    var travelMode = TravelModes.driving
 
    @IBOutlet weak var viewMap: GMSMapView!
    
    
    @IBOutlet weak var toggleTraffic: UISwitch!
  
    @IBOutlet weak var toggleFav: UISwitch!
    
    ///END of declaring variable
    
    
    
    //Turning on and off Traffic
    @IBAction func toggleTraffic(sender: AnyObject) {
        
        if  toggleTraffic.on {
            viewMap.trafficEnabled = true
        }else {
            viewMap.trafficEnabled = false
        }
        
    }
    //./Turining on and off Traffic
    
    @IBAction func navigate(sender: AnyObject) {
        
        var Lat = 29.2786584
        var Lng = 48.0681507
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            UIApplication.sharedApplication().openURL(NSURL(string:
              //  "comgooglemaps://?center=\(Lat),\(Lng)&zoom=14&views=traffic")!)
            "comgooglemaps://?saddr=\(locationManager.location.coordinate.latitude),\(locationManager.location.coordinate.longitude)&daddr=\(Lat),\(Lng)&directionsmode=driving&views=traffic")!)
        } else {
            NSLog("Can't use comgooglemaps://");
        }
    }
    
    /////////TEST BUTTONS
    
    @IBAction func POIbtn(sender: AnyObject) {
   showPOI()
    }
    
    @IBAction func routeANDpoi(sender: AnyObject) {
        
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Destination?"
        }
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if let polyline = self.routePolyline {
                // self.clearRoute()
                self.waypointsArray.removeAll(keepCapacity: false)
            }
            
            let origin: String = "\(self.locationManager.location.coordinate.latitude),\(self.locationManager.location.coordinate.longitude)"
            println("origin \(origin)")
            let destination = (addressAlert.textFields![0] as! UITextField).text as String
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
                if success {
                    self.POI(self.mapTasks.destinationCoordinate.latitude,lng: self.mapTasks.destinationCoordinate.longitude)
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    println(status)
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
        
    }
    
    
    //FUNC POI
    func POI(lat: Double ,lng: Double){

        String(format: "%.2f", 1.1999898878) // Prints "1.20"
        
        var myLat = (String(format: "%.2f", lat) as NSString).doubleValue
        var myLng = (String(format: "%.2f", lng) as NSString).doubleValue

        
        var path = GMSMutablePath()

    
        var startPathLat =  (String(format: "%.2f", self.mapTasks.originCoordinate.latitude) as NSString).doubleValue
        var startPathLng =  (String(format: "%.2f", self.mapTasks.originCoordinate.longitude) as NSString).doubleValue
        
        var endPathLat = (String(format: "%.2f", self.mapTasks.destinationCoordinate.latitude) as NSString).doubleValue
        var endPathLng = (String(format: "%.2f", self.mapTasks.destinationCoordinate.longitude) as NSString).doubleValue
        
        
        println("startPathLat: \(startPathLat)")
        println("startPathLng: \(startPathLng)")
        
        println("endPathLat: \(endPathLat)")
        println("endPathLng: \(endPathLng)")

        
        viewMap.camera = GMSCameraPosition.cameraWithTarget(self.mapTasks.originCoordinate, zoom: 10.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.viewMap
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = self.mapTasks.originAddress
        
                destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
                destinationMarker.map = self.viewMap
                destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
                destinationMarker.title = self.mapTasks.destinationAddress
        
        
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = viewMap
                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                
                markersArray.append(marker)
            }
        }
        
        
    }

    
    //.//////////TEST BUTTONS
    
    //Showing Fav
    @IBAction func favBtn(sender: AnyObject) {
    showFav()
    }
    //./Showing Fav
    
    //Button for clearing route
    @IBAction func clrRoute(sender: AnyObject) {
    self.clrAllRoute()
         clearBtn.enabled = false
    }

    //./Button for clearing route
    
    
    //button for creating from to destionation
    @IBAction func crtRoute(sender: AnyObject) {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Origin?"
        }
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Destination?"
        }
        
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if let polyline = self.routePolyline {
               // self.clearRoute()
                self.waypointsArray.removeAll(keepCapacity: false)
            }
            
            let origin = (addressAlert.textFields![0] as! UITextField).text as String
            let destination = (addressAlert.textFields![1] as! UITextField).text as String
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    println(status)
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)

    }
    //./button for creating from to destination
    
    
    //CREATE ROUTE BUTTON From my lcoation
    
    @IBAction func crtRouteFromMyLocation(sender: AnyObject) {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Destination?"
        }
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if let polyline = self.routePolyline {
               // self.clearRoute()
                self.waypointsArray.removeAll(keepCapacity: false)
            }
            
            let origin: String = "\(self.locationManager.location.coordinate.latitude),\(self.locationManager.location.coordinate.longitude)"
            println("origin \(origin)")
            let destination = (addressAlert.textFields![0] as! UITextField).text as String
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    println(status)
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
        
    }
    
    //./CREATE ROUTE FROM MY LOCAITON
    
    @IBAction func showActionSheet(sender: AnyObject) {
        
        actionSheet.show()
    }
    
    override func viewWillDisappear(animated: Bool) {
        viewMap.removeObserver(self, forKeyPath: "myLocation", context: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
 

        
    }
    
   
    
    class func hasConnectivity() -> Bool {
        let reachability: Reachability = Reachability.reachabilityForInternetConnection()
        let networkStatus: Int = reachability.currentReachabilityStatus().rawValue
        return networkStatus != 0
    }
    
    //VIEW DID LOAD()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

            
        
        self.title = "My Way";





        actionSheet.addButtonWithTitle("Find Address", type: AHKActionSheetButtonType.Default, handler:{ (AHKActionSheet) -> Void in
            
            let addressAlert = UIAlertController(title: "Address Finder", message: "Type the address you want to find:", preferredStyle: UIAlertControllerStyle.Alert)
            
            addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Address?"
            }
            
            let findAction = UIAlertAction(title: "Find Address", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                let address = (addressAlert.textFields![0] as! UITextField).text as String
                
                self.mapTasks.geocodeAddress(address, withCompletionHandler: { (status, success) -> Void in
                    if !success {
                        println(status)
                        
                        if status == "ZERO_RESULTS" {
                            self.showAlertWithMessage("The location could not be found.")
                        }
                    }
                    else {
                        let coordinate = CLLocationCoordinate2D(latitude: self.mapTasks.fetchedAddressLatitude, longitude: self.mapTasks.fetchedAddressLongitude)
                        self.viewMap.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 14.0)
                        
                        self.setupLocationMarker(coordinate)
                    }
                })
                
            }
            
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
                
            }
            
            addressAlert.addAction(findAction)
            addressAlert.addAction(closeAction)
            
            self.presentViewController(addressAlert, animated: true, completion: nil)
            
        })
        
        
        
        actionSheet.addButtonWithTitle("Get Direction from Current Location", type: AHKActionSheetButtonType.Default, handler:  { (AHKActionSheet) -> Void in
            
            let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
            
            addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Destination?"
            }
            
            let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                if let polyline = self.routePolyline {
                    // self.clearRoute()
                    self.waypointsArray.removeAll(keepCapacity: false)
                }
                
                let origin: String = "\(self.locationManager.location.coordinate.latitude),\(self.locationManager.location.coordinate.longitude)"
                println("origin \(origin)")
                let destination = (addressAlert.textFields![0] as! UITextField).text as String
                
                self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
                    if success {
                        self.configureMapAndMarkersForRoute()
                        self.drawRoute()
                        self.displayRouteInfo()
                    }
                    else {
                        println(status)
                    }
                })
            }
            
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
                
            }
            
            addressAlert.addAction(createRouteAction)
            addressAlert.addAction(closeAction)
            
            self.presentViewController(addressAlert, animated: true, completion: nil)
            
        })
        
        
        actionSheet.addButtonWithTitle("Get Direction", type: AHKActionSheetButtonType.Default, handler:  { (AHKActionSheet) -> Void in
            
            let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
            
            addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Origin?"
            }
            
            addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Destination?"
            }
            
            
            let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                if let polyline = self.routePolyline {
                    // self.clearRoute()
                    self.waypointsArray.removeAll(keepCapacity: false)
                }
                
                let origin = (addressAlert.textFields![0] as! UITextField).text as String
                let destination = (addressAlert.textFields![1] as! UITextField).text as String
                
                self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
                    if success {
                        self.configureMapAndMarkersForRoute()
                        self.drawRoute()
                        self.displayRouteInfo()
                    }
                    else {
                        println(status)
                    }
                })
            }
            
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
                
            }
            
            addressAlert.addAction(createRouteAction)
            addressAlert.addAction(closeAction)
            
            self.presentViewController(addressAlert, animated: true, completion: nil)
            
        })
        
        if favBool == true {
            
        }
        
//        actionSheet.addButtonWithTitle("On/Off Favourite", type: AHKActionSheetButtonType.Default, handler:  { (AHKActionSheet) -> Void in
//            
//
//            var myDoubLat = 29.2786584
//            var myDoubLng = 48.0681507
//            
//            
//            var myCoor:CLLocationCoordinate2D = CLLocationCoordinate2DMake(myDoubLat, myDoubLng)
//            
//            self.viewMap.camera = GMSCameraPosition.cameraWithTarget(myCoor, zoom: 12.0)
//            
//            // originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
//            self.originMarker = GMSMarker(position: myCoor)
//            self.originMarker.map = self.viewMap
//            self.originMarker.icon = GMSMarker.markerImageWithColor(UIColor.yellowColor())
//            self.originMarker.title = "My Fav"
//
//           // println("did enter showFav()")
//            
//            if self.waypointsArray.count > 0 {
//                for waypoint in self.waypointsArray {
//                    let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
//                    let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
//                    
//                    let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
//                    marker.map = self.viewMap
//                    marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
//                    
//                    self.markersArray.append(marker)
//                }
//            }
//            
//        })
                
        actionSheet.addButtonWithTitle("On/Off Traffic", type: AHKActionSheetButtonType.Default, handler:  { (AHKActionSheet) -> Void in
            
            
            if  self.viewMap.trafficEnabled == true {
                self.viewMap.trafficEnabled = false
                
            }else {
                self.viewMap.trafficEnabled = true
            }

            
            })
        
        actionSheet.addButtonWithTitle("Navigate", type: AHKActionSheetButtonType.Default, handler:  { (AHKActionSheet) -> Void in
            
            
        //
        var Lat = 29.2786584
        var Lng = 48.0681507
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            UIApplication.sharedApplication().openURL(NSURL(string:
                //  "comgooglemaps://?center=\(Lat),\(Lng)&zoom=14&views=traffic")!)
                "comgooglemaps://?saddr=\(self.locationManager.location.coordinate.latitude),\(self.locationManager.location.coordinate.longitude)&daddr=\(Lat),\(Lng)&directionsmode=driving&views=traffic")!)
        } else {
            NSLog("Can't use comgooglemaps://");
        }

        //
            })
        
        //////////// trying to add if statment for clear button 
        
        //map.getBounds().contains(marker.getPosition())
        
        
        
//        actionSheet.addButtonWithTitle("clear", type: AHKActionSheetButtonType.Destructive, handler:  { (AHKActionSheet) -> Void in
//
//            
//            self.clrAllRoute()
//            
//        })

//         self.clearBtn = UIBarButtonItem(image: UIImage(named: "icon_me"), style: UIBarButtonItemStyle.Plain, target: self, action: "clrRoute:")
        
        self.clearBtn = UIBarButtonItem(title: "clear", style: UIBarButtonItemStyle.Plain, target: self, action: "clrRoute:")
        
        
        //
       // self.navigationItem.rightBarButtonItems?.append(clearBtn)
        
       
        
        self.navigationItem.setRightBarButtonItem(self.clearBtn, animated: true)
       
        
         self.clearBtn.enabled=false
        
        ////////////./// trying to add if statment for clear button 
        
        placesClient = GMSPlacesClient()
        
       // lblLongLat.text = "long and lat havn't change"
//        
//        var camera = GMSCameraPosition.cameraWithLatitude(29.3760648,
//            longitude: 47.9818853, zoom: 18)
        
        
        var myDoubLat = 29.2786584
        var myDoubLng = 48.0681507
        

        
        var camera = GMSCameraPosition.cameraWithLatitude(29.2786584, longitude: 48.0681507, zoom: 12)
//          mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
       
        var lat = 29.363
        
        var lng = 47.984
        
        viewMap.camera = camera
        
        viewMap.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
       // mapView.myLocationEnabled = true
        viewMap.settings.compassButton = true;
        viewMap.settings.myLocationButton = true;
        
        viewMap.trafficEnabled = true;
        
      // viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    
      //  println(deviceLocation())
        
       // self.view = mapView
        
        //var theLocation: NSString = "latitude: \(locationManager.location.coordinate.latitude) longitude : \(locationManager.location.coordinate.longitude)"
        
       
      //  println(theLocation)
        
//        var circleCenter = CLLocationCoordinate2DMake(lat, lng)
//        var circ = GMSCircle(position: circleCenter, radius: 1000)
//        
//     //   println(circ.description)
//        
//        circ.fillColor = UIColor(red: 0.35, green: 0, blue: 0, alpha: 0.05)
//        circ.strokeColor = UIColor.redColor()
//        circ.strokeWidth = 5
//        circ.map = viewMap
//   
//        
//        var floor = 1
//        
//        // Implement GMSTileURLConstructor
//        // Returns a Tile based on the x,y,zoom coordinates, and the requested floor
//        var urls = { (x: UInt, y: UInt, zoom: UInt) -> NSURL in
//            var url = "http://www.example.com/floorplans/L\(floor)_\(zoom)_\(x)_\(y).png"
//            return NSURL(string: url)!
//        }
//        
//        // Create the GMSTileLayer
//        var layer = GMSURLTileLayer(URLConstructor: urls)
//        
//        // Display on the map at a specific zIndex
//        layer.zIndex = 100
//        layer.map = viewMap
        
        
      //  randomPOI()
    }
    //./VIEW DID LOAD()
    
    //Check if location is turned on
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("please turn on Location")
    }
    
    
    
    //.///Check if location is turned on
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        
        
        
        if markersArray.count > 0 || originMarker != nil {
            
//            actionSheet.addButtonWithTitle("clear", type: AHKActionSheetButtonType.Destructive, handler:  { (AHKActionSheet) -> Void in
//                
//                self.clrAllRoute()
//            
//            })
            
            clearBtn.enabled = true
            
        }
        
    }
    
    func retrieveMarkerInfo(var lat:Double, var lng:Double) {
        println("Marker lat: \(lat), Market lng: \(lng)")
        
        var coor:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
        
        self.setupLocationMarker(coor)
        
        let settings = NSUserDefaults.standardUserDefaults()
        settings.setValue(lat, forKey: "coor")

    }
    
    //testing
    
    
  //  func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        
//        var path = GMSMutablePath()
//    
//        clrAllRoute()
//        
//                path.addCoordinate(CLLocationCoordinate2DMake(position.target.latitude + 0.050 , position.target.longitude - 0.050))
//                path.addCoordinate(CLLocationCoordinate2DMake(position.target.latitude + 0.050 , position.target.longitude + 0.050))
//                path.addCoordinate(CLLocationCoordinate2DMake(position.target.latitude - 0.050 , position.target.longitude + 0.050))
//                path.addCoordinate(CLLocationCoordinate2DMake(position.target.latitude - 0.050 , position.target.longitude - 0.050))
//                path.addCoordinate(CLLocationCoordinate2DMake(position.target.latitude + 0.050 , position.target.longitude - 0.050))
//
//        var rectangle = GMSPolyline(path: path)
//        rectangle.map = viewMap
        
        
        
//        placesClient?.currentPlaceWithCallback({ (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
//            if let error = error {
//                println("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//            
//            self.nameLabel.text = "No current place"
//            self.addressLabel.text = ""
//            
//            if let placeLicklihoodList = placeLikelihoodList {
//                let place = placeLicklihoodList.likelihoods.first?.place
//                if let place = place {
//                    self.nameLabel.text = place.name
//                    self.addressLabel.text = "\n".join(place.formattedAddress.componentsSeparatedByString(", "))
//                }
//            }
//        })
//        
//println("placeClient descrip: \(placesClient?.description)")

       
//          var i = 0
//        var myCoorArray = [CLLocationCoordinate2D]()
//        
//        myCoorArray.append(CLLocationCoordinate2DMake(29.2786584, 48.0681507))
//        myCoorArray.append(CLLocationCoordinate2DMake(29.3424059, 47.7608936))
//        myCoorArray.append(CLLocationCoordinate2DMake(29.0810784, 48.1307494))
//        myCoorArray.append(CLLocationCoordinate2DMake(29.2528726, 47.9340363))
//        myCoorArray.append(CLLocationCoordinate2DMake(29.2770, 48.0690))
//        myCoorArray.append(CLLocationCoordinate2DMake(29.50, 48.50))
//        myCoorArray.append(CLLocationCoordinate2DMake(29.60, 48.60))
//        
//        
//        var Lat = 0.0
//        var Lng = 0.0
//        var cLat = 0.0
//        var cLng = 0.0
//        
//        
//        
//                for coor in myCoorArray {
//        
//                    //String(format: "%.2f", 1.1999898878)
//                    
//                    Lat = (String(format: "%.0f", coor.latitude) as NSString).doubleValue
//                    Lng = (String(format: "%.0f", coor.longitude) as NSString).doubleValue
//                    
//                    println("Lat in didChangeCamera: \(Lat) Lng in didChangeCamera: \(Lng)")
//                    
//                    cLat = (String(format: "%.0f", position.target.latitude) as NSString).doubleValue
//                    cLng = (String(format: "%.0f", position.target.longitude) as NSString).doubleValue
//                    
//                    println("cLat in didChangeCamera: \(cLat) cLng in didChangeCamera: \(cLng)")
//                    
//                    if cLat == Lat || cLng == Lng {
//        
//                            originMarker = GMSMarker(position: coor)
//                            originMarker.map = self.viewMap
//                            originMarker.icon = GMSMarker.markerImageWithColor(getRandomColor())
//                        originMarker.title = String(i)
//                            i++
//                    }
//                }

        
      //  println("Camera postion did change: \(position.description)")
 //   }
  
    
    
    
    
    
    
    
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let currentLocation = locations.last as! CLLocation
        println(currentLocation)
        println(currentLocation.coordinate.latitude)
        lblLongLat.text = String(stringInterpolationSegment: currentLocation.coordinate.latitude)
        
        var circleCenter = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude)
        var circ = GMSCircle(position: circleCenter, radius: 1000)

        circ.fillColor = UIColor(red: 0.0, green: 0.35, blue: 0, alpha: 0.05)
        circ.strokeColor = UIColor.greenColor()
        circ.strokeWidth = 5
        circ.map = viewMap
    }
    
    //./testing
    
    //Button for finding specific address
    @IBAction func findAddress(sender: AnyObject) {
        
        let addressAlert = UIAlertController(title: "Address Finder", message: "Type the address you want to find:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Address?"
        }
        
        let findAction = UIAlertAction(title: "Find Address", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let address = (addressAlert.textFields![0] as! UITextField).text as String
            
            self.mapTasks.geocodeAddress(address, withCompletionHandler: { (status, success) -> Void in
                if !success {
                    println(status)
                    
                    if status == "ZERO_RESULTS" {
                        self.showAlertWithMessage("The location could not be found.")
                    }
                }
                else {
                    let coordinate = CLLocationCoordinate2D(latitude: self.mapTasks.fetchedAddressLatitude, longitude: self.mapTasks.fetchedAddressLongitude)
                    self.viewMap.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 14.0)
                    
                    self.setupLocationMarker(coordinate)
                }
            })
            
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(findAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
        
    }
    //./Button for finding specific address
  
    
    //main for mapTask
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            viewMap.myLocationEnabled = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        
        if !didFindMyLocation {
            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as! CLLocation
            viewMap.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 12.0)
            viewMap.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    }
    
    // MARK: Custom method implementation
    
    func showAlertWithMessage(message: String) {
        let alertController = UIAlertController(title: "GMapsDemo", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        alertController.addAction(closeAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    func setupLocationMarker(coordinate: CLLocationCoordinate2D) {
        if locationMarker != nil {
            locationMarker.map = nil
        }
        
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = viewMap
        
        locationMarker.title = mapTasks.fetchedFormattedAddress
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        locationMarker.opacity = 0.75
        
        locationMarker.flat = true
        //locationMarker.snippet = ""
    }
    
    //////////
    func configureMapAndMarkersForRoute() {
        viewMap.camera = GMSCameraPosition.cameraWithTarget(mapTasks.originCoordinate, zoom: 9.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.viewMap
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = self.mapTasks.originAddress
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.viewMap
        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        destinationMarker.title = self.mapTasks.destinationAddress
        
        
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = viewMap
                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                
                markersArray.append(marker)
            }
        }
    }
    
    // SHOWING FAV
    
    func showFav() {
        
        var myDoubLat = 29.2786584
        var myDoubLng = 48.0681507
     

        var myCoor:CLLocationCoordinate2D = CLLocationCoordinate2DMake(myDoubLat, myDoubLng)
        
        viewMap.camera = GMSCameraPosition.cameraWithTarget(myCoor, zoom: 12.0)
        
       // originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker = GMSMarker(position: myCoor)
        originMarker.map = self.viewMap
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.yellowColor())
        originMarker.title = "My Fav"
        

        println("did enter showFav()")
        
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = viewMap
                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                
                markersArray.append(marker)
            }
        }
    }

    //./ SHOW FAV
    
    func getRandomColor() -> UIColor{
        
        var randomRed:CGFloat = CGFloat(drand48())
        
        var randomGreen:CGFloat = CGFloat(drand48())
        
        var randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    
    //TESTING ADD POLY ON AND NEAR MARKER
    

    
    func showPOI(){
        
        var circleCenter = CLLocationCoordinate2DMake(29.27, 48.0)
        var circ = GMSCircle(position: circleCenter, radius: 1000)
        
        circ.fillColor = UIColor(red: 0.35, green: 0, blue: 0, alpha: 0.05)
        circ.strokeColor = UIColor.redColor()
        circ.strokeWidth = 5
        circ.map = viewMap
        
        var myDoubLat = 29.2786584
        var myDoubLng = 48.0681507
        
        var myCoorArray = [CLLocationCoordinate2D]()

        myCoorArray.append(CLLocationCoordinate2DMake(29.00, 48.00))
        myCoorArray.append(CLLocationCoordinate2DMake(29.10, 48.10))
        myCoorArray.append(CLLocationCoordinate2DMake(29.27, 48.06))
        myCoorArray.append(CLLocationCoordinate2DMake(29.2751, 48.0650))
        myCoorArray.append(CLLocationCoordinate2DMake(29.2770, 48.0690))
        myCoorArray.append(CLLocationCoordinate2DMake(29.50, 48.50))
        myCoorArray.append(CLLocationCoordinate2DMake(29.60, 48.60))
        
        
        for coor in myCoorArray {
            
            //if coor.latitude >= 29.27 && coor.latitude <= 29.31 &&
            //coor.longitude >= 48.0 && coor.longitude <= 48.11 {
            
            originMarker = GMSMarker(position: coor)
            originMarker.map = self.viewMap
            originMarker.icon = GMSMarker.markerImageWithColor(getRandomColor())
            
            //}
        }
        
        var path = GMSMutablePath()
        path.addCoordinate(CLLocationCoordinate2DMake(29.27, 48.0))
        path.addCoordinate(CLLocationCoordinate2DMake(29.31, 48.0))
        path.addCoordinate(CLLocationCoordinate2DMake(29.31, 48.11))
        path.addCoordinate(CLLocationCoordinate2DMake(29.27, 48.11))
        path.addCoordinate(CLLocationCoordinate2DMake(29.27, 48.0))
        
        
        var rectangle = GMSPolyline(path: path)
        rectangle.map = viewMap
        
        var myCoor:CLLocationCoordinate2D = CLLocationCoordinate2DMake(myDoubLat, myDoubLng)
        
        viewMap.camera = GMSCameraPosition.cameraWithTarget(myCoor, zoom: 10.0)
        
        originMarker = GMSMarker(position: myCoor)
        originMarker.map = self.viewMap
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.blackColor())
        originMarker.title = "My POI"
        
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = viewMap
                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                
                markersArray.append(marker)
            }
        }

        
    }
    
    //./TESTING ADD POLY..
    
    func drawRoute() {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        
        println("path count: \(path.count())")
        
        println("\(self.mapTasks.originCoordinate.latitude) \(self.mapTasks.originCoordinate.longitude) ")
        println("\(self.mapTasks.destinationCoordinate.latitude) \(self.mapTasks.destinationCoordinate.longitude) ")
        
        var bounds:GMSCoordinateBounds = GMSCoordinateBounds()
      //  println("initial bounds: (\(bounds.southWest.latitude), \(bounds.southWest.longitude)) - (\(bounds.northEast.latitude), \(bounds.northEast.longitude)) ")
        
        for (var i:UInt = 0; i < path.count(); i++){
            bounds = bounds.includingCoordinate(path.coordinateAtIndex(i))
          //  println("updated bounds: (\(bounds.southWest.latitude), \(bounds.southWest.longitude)) - (\(bounds.northEast.latitude), \(bounds.northEast.longitude)) ")
        }
        //println("final bounds: (\(bounds.southWest.latitude), \(bounds.southWest.longitude)) - (\(bounds.northEast.latitude), \(bounds.northEast.longitude)) ")
        
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = viewMap
    }
    
    
    func displayRouteInfo() {
//        lblInfo.text = mapTasks.totalDistance + "\n" + mapTasks.totalDuration
    }
    
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepCapacity: false)
        }
    }
    
    
    //clear all route
    func clrAllRoute() {
        
//        originMarker.map = nil
//        destinationMarker.map = nil
//        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepCapacity: false)
        }
        
        viewMap.clear()
        
        
    }
    
    //./clear all route
    
    func recreateRoute() {
        if let polyline = routePolyline {
            clearRoute()
            
            mapTasks.getDirections(mapTasks.originAddress, destination: mapTasks.destinationAddress, waypoints: waypointsArray, travelMode: travelMode, completionHandler: { (status, success) -> Void in
                
                if success {
                    println("did enter recreate route sucess status")
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    println("did NOT enter recreate route sucess status")
                    println(status)
                }
            })
        }
    }
    
    
    // MARK: GMSMapViewDelegate method implementation
    //Help with recreating the route
    
 
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        //println("function mapView runs")
        
        var markerCoorLat:Double
        var markerCoorLng:Double
        
        markerCoorLat = coordinate.latitude
        markerCoorLng = coordinate.longitude
        
        retrieveMarkerInfo(markerCoorLat, lng: markerCoorLng)
        
        if let polyline = routePolyline {
            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
            waypointsArray.append(positionString)
            
            recreateRoute()
        }
    }

    

        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


} //./End of mainViewController


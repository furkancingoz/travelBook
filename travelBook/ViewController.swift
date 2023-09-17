//
//  ViewController.swift
//  travelBook
//
//  Created by Furkan Cingöz on 17.09.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData



class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    
    var selectedTitle = ""
    var selectedID : UUID?
    
    var annaotationTitle = ""
    var annaotationSubTitle = ""
    var annaotationLatitude = Double()
    var annaotationLongitude = Double()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedTitle != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for results in results as! [NSManagedObject] {
                        if let title = results.value(forKey: "title") as? String {
                            annaotationTitle = title
                            if let subtitle = results.value(forKey: "subtitle") as? String {
                                annaotationSubTitle = subtitle
                                
                                if let subtitle = results.value(forKey: "subtitle") as? String {
                                    annaotationSubTitle = subtitle
                                    
                                    
                                    if let latitude = results.value(forKey: "latitude") as? Double {
                                        annaotationLatitude = latitude
                                        
                                        if let longitutde = results.value(forKey: "longitude") as? Double {
                                            annaotationLongitude = longitutde
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annaotationTitle
                                            annotation.subtitle = annaotationSubTitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annaotationLatitude, longitude: annaotationLongitude)
                                            annotation.coordinate = coordinate
                                            mapView.addAnnotation(annotation)
                                            
                                            nameText.text = annaotationTitle
                                            commentText.text = annaotationSubTitle
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            } catch {
                print("error")
            }
        }
        
    }
    
    
    
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            chosenLatitude = touchedCoordinate.latitude
            chosenLongitude = touchedCoordinate.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let  locations = CLLocationCoordinate2D(latitude:  locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locations, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context  = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        
        do {
            try context.save()
            print("succes")
        } catch {
            print("error")
        }
        
        
        
        
    }
    
    
}


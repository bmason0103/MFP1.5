//
//  cityViewController.swift
//  MyFinal
//
//  Created by Brittany Mason on 2/29/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class CityViewController : UIViewController {
    
    //MARK: Set up Outlets
    @IBOutlet weak var cityPicture: CityViewController!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    @IBOutlet weak var getPhotoButton: UIButton!
    
    
    //MARK: Setup Variables
    var nameOfSelectedCity = ""
    var lat = 0.0
    var log = 0.0
    var pictureStruct : [PhotoParser]?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var personvar: Person?
    var cityViewPerson : [Person]?
    var name = ""
    var pics: Photos?
    //    let context: NSManagedObjectContext
    //let managedContext = appDelegate.persistentContainer.viewContext
    var pictureStructs: [NSManagedObject] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityNameLabel.text = nameOfSelectedCity
        cityNameIntoCoord()
        //        getPhotosFromFlickr ()
        //        print("This is viewDidLoad lat", lat)
        //        print("This is viewDidLoad lat", lat)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //May refactor this later
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Photos")
        
        do {
            pictureStructs = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //this is the same as in view will appear
    private func setupFetchedResultControllerWith(_ city: Photos) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Photos")
        
        // Start the fetched results controller
        //        let error: NSError?
        do {
            pictureStructs = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        //
        //        if let error = error {
        //            print("\(#function) Error performing initial fetch: \(error)")
        //        }
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:Turn City name into coordinates
    
    func cityNameIntoCoord() {
        let address = nameOfSelectedCity
        //let address = "Burlington, Vermont"
        CLGeocoder().geocodeAddressString(address, completionHandler: { placemarks, error in
            if (error != nil) {
                return
            }
            
            if let placemark = placemarks?[0]  {
                let lat = String(format: "%.04f", (placemark.location?.coordinate.longitude ?? 0.0)!)
                let lon = String(format: "%.04f", (placemark.location?.coordinate.latitude ?? 0.0)!)
                let name = placemark.name!
                let country = placemark.country!
                let region = placemark.administrativeArea!
                print("\(lat),\(lon)\n\(name),\(region) \(country)")
                
                let corlat = (lat as NSString).doubleValue
                let corlong = (lon as NSString).doubleValue
                Constants.Coordinate.latitude = corlat
                Constants.Coordinate.longitude = corlong
                print("function lat",corlat)
                print( Constants.Coordinate.longitude)
            }
        })
    }
    
    
    
    
    @IBAction func getPhotoButtonPressed(_ sender: Any) {
        getPhotosFromFlickr ()
        
    }
    
    
    
    func getPhotosFromFlickr () {
        print("'New Collection' button pressed")
        activityIndicatorStart()
        //           newCollectionButton.isEnabled = false
        
        helperTasks.downloadPhotos { (pictureInfo, error) in
            if let pictureInfo = pictureInfo {
                self.pictureStruct = pictureInfo.photos.photo
                self.storePhotos(self.pictureStruct!, cityName: self.personvar!)
                print(pictureInfo)
                
                DispatchQueue.main.async {
                    self.activityIndicatorStop()
                    
                    guard self.personvar != nil else {
                        return
                    }
                    self.setupFetchedResultControllerWith(self.pics!)
                    //                       self.collectionView.reloadData()
                    
                }
            } else {
                DispatchQueue.main.async {
                    self.displayAlert(title: "Error", message: "Unable to get city pictures.")
                }
                print(error as Any)
            }
            
        }
        //           self.CityViewController.reloadData()
    }
    
    
    //    private func setupFetchedResultControllerWith(_ city: Photos) {
    //
    //        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    //            return
    //        }
    //        let managedContext = appDelegate.persistentContainer.viewContext
    //        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Photos")
    //
    //        // Start the fetched results controller
    ////        let error: NSError?
    //        do {
    //                   pictureStructs = try managedContext.fetch(fetchRequest)
    //               } catch let error as NSError {
    //                   print("Could not fetch. \(error), \(error.userInfo)")
    //               }
    ////
    ////        if let error = error {
    ////            print("\(#function) Error performing initial fetch: \(error)")
    ////        }
    //    }
    
    private func storePhotos(_ photos: [PhotoParser], cityName: Person) {
        func showErrorMessage(msg: String) {
            showInfo(withTitle: "Error", withMessage: msg)
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        for photo in photos {
            DispatchQueue.main.async {
                
                if let url = photo.url {
                    
                    _ = Photos(title: photo.title, imageUrl: url, cityName: cityName, context: managedContext)
                }
            }
        }
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Photos", in: managedContext)!
        let picurl = NSManagedObject(entity: entity, insertInto: managedContext)
        picurl.setValue(name, forKeyPath: "urlimage")
        print (picurl)
        
        do {
            try managedContext.save()
            pictureStructs.append(pics!)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func activityIndicatorStart () {
        print("act ind working")
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func activityIndicatorStop () {
        activityIndicator.stopAnimating()
    }
    
    
}

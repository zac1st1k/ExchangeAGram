//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Zac on 7/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var error:NSError?
        //        let itemArray = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "FeedItem"), error: &error)
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDelegate.managedObjectContext
        let itemArray = context?.executeFetchRequest(request, error: &error)
        println(error)
        if itemArray!.count > 0 {
            for item in itemArray! {
                let location = CLLocationCoordinate2DMake(Double(item.latitude), Double(item.longitude))
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegionMake(location, span)
                mapView.setRegion(region, animated: true)
                let annotation = MKPointAnnotation()
                annotation.setCoordinate(location)
                annotation.title = item.caption
                mapView.addAnnotation(annotation)
            }
        }
//        let location = CLLocationCoordinate2D(latitude: 48.868639224587, longitude: 2.37119161036255)
//        let span = MKCoordinateSpanMake(0.05, 0.03)
//        let region = MKCoordinateRegionMake(location, span)
//        mapView.setRegion(region, animated: true)
//        let annotation = MKPointAnnotation()
//        annotation.setCoordinate(location)
//        annotation.title = "Canal Saint-Martin"
//        annotation.subtitle = "Paris"
//        mapView.addAnnotation(annotation)
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

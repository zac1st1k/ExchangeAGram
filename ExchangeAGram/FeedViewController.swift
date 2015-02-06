//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Zac on 4/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import ImageIO


class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    @IBOutlet weak var collectionView: UICollectionView!
    var feedArray: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        feedArray = context.executeFetchRequest(request, error: nil)!
    }
    
    override func viewWillAppear(animated: Bool) {
//        let request = NSFetchRequest(entityName: "FeedItem")
        feedArray = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "FeedItem"), error: nil)!
        collectionView.reloadData()
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
    
    @IBAction func snapBarButtonItemPressed(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
            cameraController.allowsEditing = false
            presentViewController(cameraController, animated: true, completion: nil)
        }
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            var cameraController =  UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = [kUTTypeImage]
            cameraController.allowsEditing = false
            presentViewController(cameraController, animated: true, completion: nil)
        }
        else {
            var alertController = UIAlertController(title: "Warning", message: "Your device does not support the Camera or Photo Library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //UIImagePickerController Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbNail = imageWithImage(image, scaledToSize: CGSizeMake(image.size.width/10, image.size.height/10))
        let thumbNailData = UIImageJPEGRepresentation(thumbNail, 1.0)

        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext)!
        let feedItem = FeedItem(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        
        feedItem.image = imageData
        feedItem.caption = image.description
        feedItem.thumbNail = thumbNailData
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        feedArray.append(feedItem)
        self.collectionView.reloadData()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //UICollectionView Delegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FeedCell
        let thisItem = feedArray[indexPath.row] as FeedItem
        cell.imageView.image = UIImage(data: thisItem.thumbNail)
        cell.captionLabel.text = thisItem.caption
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as FeedItem
        var filterVC = FilterViewController()
        filterVC.thisFeedItem = thisItem
        filterVC.tappedCellNumber = indexPath.row
        navigationController?.pushViewController(filterVC, animated: true)
    }
    
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        image.drawInRect(CGRect(origin: CGPointZero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    @IBAction func profileTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("profileSegue", sender: nil)
    }
}

//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Zac on 5/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var thisFeedItem: FeedItem!
    var collectionView:UICollectionView!
    var filterCell: FilterCell!
    let kIntensity = 0.7
    var context:CIContext = CIContext(options: nil)
    var filters:[CIFilter] = []
    var tappedCellNumber: Int!
    
//    var tempImageArray:[NSData] = []
    let tmp = NSTemporaryDirectory()
    let placeHolderImage = UIImage(named: "Placeholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.whiteColor()
        
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
//        tempImageArray = [NSData](count: photoFilters().count, repeatedValue: thisFeedItem.thumbNail)
        filters = photoFilters()
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
    
    // MARK: - UICollectionView Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoFilters().count

    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        cell.imageView.image = placeHolderImage
        
        //GCD
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        dispatch_async(filterQueue, { () -> Void in
//        let filteredImage = self.filteredImageFromImage(self.thisFeedItem.thumbNail, filter: self.filters[indexPath.row])
            // Caching
            let filteredImage = self.getCachedImage(indexPath.row)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filteredImage
                cell.label.text = self.filters[indexPath.row].name()
            })
        })
        
        return cell
    }
    // MARK: - UICollectionView Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        createUIAlertController(indexPath)
    }
    
    // MARK: - Helper Function
    func photoFilters () -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
        
    }
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        filter.setValue(CIImage(data: imageData), forKey: kCIInputImageKey)
        let filteredImage = filter.outputImage
        
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: filteredImage.extent())
        let finalImage = UIImage(CGImage: cgImage)!
        
        return finalImage
    }
    func saveFilerToCoreData (indexPath: NSIndexPath, caption: String) {
        let filteredImage = self.filteredImageFromImage(thisFeedItem.image, filter: filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filteredImage, 1.0)
        thisFeedItem.image = imageData
        let filteredthumbNail = self.filteredImageFromImage(thisFeedItem.image, filter: filters[indexPath.row])
        let thumbNailData = UIImageJPEGRepresentation(filteredthumbNail, 1.0)
        thisFeedItem.thumbNail = thumbNailData
        thisFeedItem.caption = caption
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        navigationController?.popViewControllerAnimated(true)
    }
    func shareToFacebook (indexPath: NSIndexPath) {
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        let photos:NSArray = [filterImage]
        var params = FBPhotoParams()
        params.photos = photos
        FBDialogs.presentShareDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            if (result? != nil) {
                println(result)
            }
            else {
                println(error)
            }
        }
        
    }
    
    // MARK: - Caching Functions
    func cacheImage (rowNumber: Int) {
        let image = UIImage(data: thisFeedItem.image)
        let fileName = "\(tappedCellNumber)\(rowNumber)"
//        println("cache \(fileName)")
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName) {
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[rowNumber]
            let image = filteredImageFromImage(data, filter: filter)
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage (rowNumber: Int) -> UIImage {
        let image = UIImage(data: thisFeedItem.image)
        let fileName = "\(tappedCellNumber)\(rowNumber)"
//        println("get \(fileName)")
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        var Cachedimage:UIImage
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            Cachedimage = UIImage(contentsOfFile: uniquePath)!
        }
        else {
            self.cacheImage(rowNumber)
            Cachedimage = UIImage(contentsOfFile: uniquePath)!
        }
        return Cachedimage
    }
    
    // MARK: - UIAlertController Helper Functions
    func createUIAlertController (indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)

        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        
        let photoAction = UIAlertAction(title: "Post Photo to Facebook with Caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            self.shareToFacebook(indexPath)
        }
        alert.addAction(photoAction)
        
        var text = (alert.textFields![0] as UITextField).text
        let saveFilterAction = UIAlertAction(title: "Save Filter without Posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.saveFilerToCoreData(indexPath, caption: text)
        }
        alert.addAction(saveFilterAction)
        alert.addAction(UIAlertAction(title: "Select Another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
        })

        presentViewController(alert, animated: true, completion: nil)
    }
}

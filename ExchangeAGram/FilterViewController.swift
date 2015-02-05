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
        println(FilterCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoFilters().count

    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
//        var image = UIImage(data: thisFeedItem.image)
        cell.imageView.image = filteredImageFromImage(thisFeedItem.image, filter: photoFilters()[indexPath.row])
        return cell
    }
    
    //Helper Function
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

}

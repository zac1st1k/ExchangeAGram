//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Zac on 7/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber

}

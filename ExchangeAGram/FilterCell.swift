//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by Zac on 5/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    var imageView: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(imageView)
        label = UILabel(frame: CGRect(x: 0, y: 50, width: frame.size.width, height: frame.size.height))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        imageView.addSubview(label)
    }
    
    required init(coder aDecoder:NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
}

//
//  PhotoCollectionViewCell.swift
//  MyAlbum
//
//  Created by 전세호 on 22/08/2019.
//  Copyright © 2019 sayho. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
//    override var isSelected: Bool {
//        didSet {
//            self.contentView.backgroundColor = isSelected ? UIColor.blue : UIColor.yellow
//            self.imageView.alpha = isSelected ? 0.75 : 1.0
//        }
//    }
    
    override var isSelected: Bool{
        didSet{
            self.contentView.backgroundColor = isSelected ? UIColor.black : UIColor.clear
            self.contentView.alpha = isSelected ? 0.5 : 1.0
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

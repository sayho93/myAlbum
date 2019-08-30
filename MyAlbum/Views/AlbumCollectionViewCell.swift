//
//  AlbumCollectionViewCell.swift
//  MyAlbum
//
//  Created by 전세호 on 09/08/2019.
//  Copyright © 2019 sayho. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet var thumbImg: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            thumbImg.image = thumbnailImage
        }
    }
}

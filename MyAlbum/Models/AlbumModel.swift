//
//  AlbumModel.swift
//  MyAlbum
//
//  Created by 전세호 on 08/08/2019.
//  Copyright © 2019 sayho. All rights reserved.
//

import Foundation
import Photos

class AlbumModel {
    private var thumb: UIImage
    private var name: String
    private var count: Int
    private var collection: PHAssetCollection
    init(name: String, count: Int, collection: PHAssetCollection, thumb: UIImage) {
        self.thumb = thumb
        self.name = name
        self.count = count
        self.collection = collection
    }
    
    func setThumb(image: UIImage){
        self.thumb = image
    }
    
    func getThumb() -> UIImage{
        return self.thumb
    }
    
    func setName(name: String){
        self.name = name
    }
    
    func getName() -> String{
        return self.name
    }
    
    func setCount(count: Int){
        self.count = count
    }
    
    func getCount() -> Int{
        return self.count
    }
    
    func setCollection(collection: PHAssetCollection){
        self.collection = collection
    }
    
    func getCollection() -> PHAssetCollection{
        return self.collection
    }
    
    func toString() -> String{
        return "img: \(thumb)\nname: \(name)\ncount: \(count)\ncollection: \(collection)\n"
    }
}

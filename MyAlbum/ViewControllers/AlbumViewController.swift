//
//  ViewController.swift
//  MyAlbum
//
//  Created by 전세호 on 08/08/2019.
//  Copyright © 2019 sayho. All rights reserved.
//

import UIKit
import Photos

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver {
    @IBOutlet weak var albumCollectionView: UICollectionView!
    var fetchResult: [AlbumModel]!
    fileprivate var imageManager: PHCachingImageManager = PHCachingImageManager()
    let cellIdentifier: String = "albumCell"
    
    private var flowLayout: UICollectionViewFlowLayout!
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? AlbumCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        cell.thumbImg.layer.cornerRadius = 8.0
        
        let albumItem: AlbumModel = fetchResult[indexPath.item]
        
        let options = PHFetchOptions()
        let assets = PHAsset.fetchKeyAssets(in: albumItem.getCollection(), options: options)
        if let keyAsset = assets?.firstObject{
            let options = PHImageRequestOptions()
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            options.isNetworkAccessAllowed = true
            options.resizeMode = PHImageRequestOptionsResizeMode.exact
            
            cell.representedAssetIdentifier = keyAsset.localIdentifier
            self.imageManager.requestImage(
                for: keyAsset,
                targetSize: self.thumbnailSize!,
                contentMode: .aspectFill,
                options: options,
                resultHandler: {image, _ in
                    if cell.representedAssetIdentifier == keyAsset.localIdentifier{
                        cell.thumbImg?.image = image
                    }
                    
                    albumItem.setThumb(image: image!
                )}
            )
        }
        cell.thumbnailImage = albumItem.getThumb()
        cell.thumbImg.backgroundColor = .gray
        cell.nameLabel.text = albumItem.getName()
        cell.countLabel.text = String(albumItem.getCount())
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "photoListSegue", sender: albumCollectionView.cellForItem(at: indexPath))
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        listAlbums()
        OperationQueue.main.addOperation {
            self.albumCollectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        let scale = UIScreen.main.scale
        let cellSize = flowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.height * scale, height: cellSize.height * scale)

        listAlbums()
        self.albumCollectionView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "앨범"
        self.navigationController?.navigationBar.tintColor = .white
        let barColor = UIColor(red: 107.0/255.0, green: 170.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = barColor
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
//        self.navigationController?.toolbar.barTintColor = barColor
//        self.navigationController?.setToolbarHidden(true, animated: false)
//        self.navigationController?.toolbar.isHidden = true
        
        PHPhotoLibrary.shared().register(self)
        let halfWidth: CGFloat = UIScreen.main.bounds.width / 2.0
        
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: halfWidth - 5, height: halfWidth + 50)
        self.albumCollectionView.collectionViewLayout = flowLayout
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func listAlbums(){
        var album:[AlbumModel] = [AlbumModel]()
        let options = PHFetchOptions()
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: options)
        let favorite = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: options)
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        let allAlbums = [cameraRoll, favorite, userAlbums]
        
        for item in allAlbums{
            item.enumerateObjects{ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
                if object is PHAssetCollection {
                    let obj:PHAssetCollection = object as! PHAssetCollection
                    var assetCount: Int = obj.estimatedAssetCount
                    if assetCount == NSNotFound{
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
                        assetCount = PHAsset.fetchAssets(in: obj , options: fetchOptions).count
                    }
                    let newAlbum = AlbumModel(name: obj.localizedTitle!, count: assetCount, collection: obj, thumb: UIImage())
            
                    album.append(newAlbum)
                }
            }
        }
        self.fetchResult = album
//        for item in album {
//            print(item.toString())
//        }
    }
    
    func getCollection(indexPath: Int) -> PHAssetCollection{
        let obj =  fetchResult[indexPath]
        return obj.getCollection()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoListSegue"{
            let destination = segue.destination as! PhotoCollectionViewController
            
            guard let cell = sender as? AlbumCollectionViewCell else { fatalError("Unexpected sender for segue") }
            let indexPath = albumCollectionView.indexPath(for: cell)!
            destination.collection = getCollection(indexPath: indexPath.row)
        }
    }
}


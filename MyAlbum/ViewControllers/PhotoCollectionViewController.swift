//
//  PhotoCollectionViewController.swift
//  MyAlbum
//
//  Created by 전세호 on 21/08/2019.
//  Copyright © 2019 sayho. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver {
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var actionBarBtn: UIBarButtonItem!
    @IBOutlet var trashBarBtn: UIBarButtonItem!
    @IBOutlet var centerBarBtn: UIBarButtonItem!
    
    var collection: PHAssetCollection!
    private var fetchResult: PHFetchResult<PHAsset>!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate let options = PHFetchOptions()
    private var flowLayout: UICollectionViewFlowLayout!
    fileprivate var thumbnailSize: CGSize!
    
    private var descFlag: Bool!
    private var editingModeFlag: Bool!
    
    let cellIdentifier: String = "photoCell"

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? PhotoCollectionViewCell else{
            return UICollectionViewCell()
        }
        let asset = fetchResult.object(at: indexPath.row)
        cell.representedAssetIdentifier = asset.localIdentifier
        
        let option = PHImageRequestOptions()
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        option.isNetworkAccessAllowed = true
        option.resizeMode = PHImageRequestOptionsResizeMode.exact
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: option, resultHandler: {image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier{
                cell.imageView?.image = image
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editingModeFlag == false{
            performSegue(withIdentifier: "photoViewSegue", sender: photoCollectionView.cellForItem(at: indexPath))
        }else{
            bindSelectedCnt()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        bindSelectedCnt()
    }
    
    func bindSelectedCnt(){
        guard let cnt = photoCollectionView.indexPathsForSelectedItems?.count else{return}
        self.navigationItem.title = "\(cnt)장 선택"
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if fetchResult != nil{
            guard let changes = changeInstance.changeDetails(for: fetchResult) else{
                return
            }
            fetchResult = changes.fetchResultAfterChanges
            OperationQueue.main.addOperation {
                self.photoCollectionView.performBatchUpdates({
                    self.photoCollectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
                }, completion: {(finished: Bool) -> Void in})
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scale = UIScreen.main.scale
        let cellSize = flowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)

        getPhotoList()
        emptySelection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "사진"
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        self.actionBarBtn.isEnabled = false
        self.trashBarBtn.isEnabled = false
        
        PHPhotoLibrary.shared().register(self)
        let halfWidth: CGFloat = (UIScreen.main.bounds.width / 2.0) - 2
        
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.itemSize = CGSize(width: halfWidth / 2, height: halfWidth / 2)
    
        self.photoCollectionView.collectionViewLayout = flowLayout
        self.descFlag = true
        self.editingModeFlag = false
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func getPhotoList(){
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !self.descFlag)]
        fetchResult = PHAsset.fetchAssets(in: self.collection, options: options)
    }
    
    @IBAction func toggleSort(){
        self.descFlag = !self.descFlag
        if self.descFlag == true{
            centerBarBtn.title = "최신순"
        } else{
            centerBarBtn.title = "과거순"
        }
        
        getPhotoList()
        
        self.photoCollectionView.performBatchUpdates({
            self.photoCollectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
        }, completion: {(finished: Bool) -> Void in})
    }
    
    @IBAction func toggleEditingMode(){
        guard let currentState = self.editingModeFlag else{
            fatalError()
        }
        
        if currentState == false{
            self.editBtn.title = "취소"
            self.navigationItem.title = "항목 선택"
        }else{
            self.editBtn.title = "선택"
            emptySelection()
            self.navigationItem.title = "사진"
        }
        
        self.navigationItem.setHidesBackButton(!currentState, animated: true)
        self.editingModeFlag = !currentState
        photoCollectionView.allowsMultipleSelection = !photoCollectionView.allowsMultipleSelection
        self.actionBarBtn.isEnabled = !self.actionBarBtn.isEnabled
        self.centerBarBtn.isEnabled = !self.centerBarBtn.isEnabled
        self.trashBarBtn.isEnabled = !self.trashBarBtn.isEnabled
    }
    
    @IBAction func showActivity(){
        guard let selectedItems = photoCollectionView.indexPathsForSelectedItems else{
            fatalError()
        }
        
         var sharingItems = [Any]()
        let option = PHImageRequestOptions()
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        
        for indexPath in selectedItems{
            let asset: PHAsset = self.fetchResult[indexPath.row]
            
            OperationQueue.main.addOperation {
                self.imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option, resultHandler: {image, _ in
                    sharingItems.append(image!)
                })
            }
        }
        
        OperationQueue.main.addOperation {
            print(sharingItems)
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            
            // 2. 기본으로 제공되는 서비스 중 사용하지 않을 UIActivityType 제거(선택 사항)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact]
            
            // 3. 컨트롤러를 닫은 후 실행할 완료 핸들러 지정
            activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
                if success {
                    // 성공했을 때 작업
                }  else  {
                    // 실패했을 때 작업
                }
            }
            // 4. 컨트롤러 나타내기(iPad에서는 팝 오버로, iPhone과 iPod에서는 모달로 나타냅니다.)
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func deletePhotos(){
        guard let selectedItems = photoCollectionView.indexPathsForSelectedItems else{
            fatalError()
        }
        
        if selectedItems.count > 0{
            var itemArr: [PHAsset] = []
            var indexArr: [IndexPath] = []
            for indexPath in selectedItems{
                let asset: PHAsset = self.fetchResult[indexPath.row]
                itemArr.append(asset)
                indexArr.append(indexPath)
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(itemArr as NSArray)
            }, completionHandler: {(succeeded, error) -> Void in
                if succeeded{
                    for indexPath in indexArr{
                        OperationQueue.main.addOperation{
                            guard let cell = self.photoCollectionView.cellForItem(at: indexPath) else{return}
                            cell.contentView.backgroundColor = UIColor.clear
                            cell.contentView.alpha = 1
                        }
                    }
                    OperationQueue.main.addOperation{
                        self.toggleEditingMode()
                    }
                }else{
                    fatalError("dsf")
                }
            })
        }else{
            let alert = UIAlertController(title: "알림", message: "사진을 한장 이상 선택해 주시기 바랍니다.", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler : nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func emptySelection(){
        guard let selectedItems = photoCollectionView.indexPathsForSelectedItems else{return}
        for indexPath in selectedItems {
            guard let cell = photoCollectionView.cellForItem(at: indexPath) else{
                return
            }
            cell.contentView.backgroundColor = UIColor.clear
            cell.contentView.alpha = 1
            photoCollectionView.deselectItem(at: indexPath, animated:true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController: PhotoViewController = segue.destination as? PhotoViewController else{
            return
        }
        
        guard let cell: PhotoCollectionViewCell = sender as? PhotoCollectionViewCell else{
            return
        }
        
        guard let index: IndexPath = self.photoCollectionView.indexPath(for: cell) else{
            return
        }
        
        nextViewController.asset = fetchResult.object(at: index.row)
    }
}

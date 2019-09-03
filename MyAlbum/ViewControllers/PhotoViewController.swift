//
//  PhotoViewController.swift
//  MyAlbum
//
//  Created by 전세호 on 26/08/2019.
//  Copyright © 2019 sayho. All rights reserved.
//

import UIKit
import Photos

class PhotoViewController: UIViewController, UIScrollViewDelegate, PHPhotoLibraryChangeObserver {
    var asset: PHAsset!
    private let imageManager =  PHCachingImageManager()
    var gesture = UITapGestureRecognizer()
    private var tapFlag = false
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var centerBtn: UIBarButtonItem!
    
    var isStatusBarHidden: Bool = false
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return self.imageView
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let photoAsset = self.asset, let changeDetails = changeInstance.changeDetails(for: photoAsset)else { return }
        self.asset = changeDetails.objectAfterChanges
        OperationQueue.main.addOperation {
            self.initToolbar()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
        fetchPhoto()
        initToolbar()
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(gestureActivated))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gesture)
    }
    
    func initToolbar(){
        if asset.isFavorite == true{
            self.centerBtn.image = UIImage(named: "heartFilled")
        }else{
            self.centerBtn.image = UIImage(named: "heartEmpty")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    @objc func gestureActivated() {
        let tap = gesture.location(in: imageView)
        let frame = imageView.accessibilityFrame
        let currentStatus = self.tapFlag
        
        if !frame.contains(tap){
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.isStatusBarHidden = !self.isStatusBarHidden
                self.setNeedsStatusBarAppearanceUpdate()
                self.navigationController?.setToolbarHidden(!currentStatus, animated: false)
                self.navigationController?.setNavigationBarHidden(!currentStatus, animated: false)
                
                self.view.backgroundColor = currentStatus == false ? .black : .white
            }, completion: nil)
            self.tapFlag = !self.tapFlag
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if self.isMovingFromParent{
//            self.navigationController?.hidesBarsOnTap = false
//            self.navigationController?.navigationBar.isTranslucent = false
//        }
    }
    
    func fetchPhoto(){
        let option = PHImageRequestOptions()
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        option.isNetworkAccessAllowed = true
        
        imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFill,
            options: nil,
            resultHandler: {
                image, _ in
                self.imageView.image = image
            }
        )
    }
    
    @IBAction func showActivity(){
        let sharingImage = self.imageView.image
        let activityViewController = UIActivityViewController(activityItems: [sharingImage!], applicationActivities: nil)
        
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
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func toggleFavor(){
        let status = self.asset.isFavorite

        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest(for: self.asset)
            request.isFavorite = !status
        }, completionHandler: { succeeded, error in
            if succeeded{
                OperationQueue.main.addOperation {
                    self.view.reloadInputViews()
                }
            }
        })
    }
    
    @IBAction func deletePhoto(){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([self.asset as Any] as NSArray)
        }, completionHandler: {(succeeded, error) -> Void in
            if succeeded{
                //TODO go backwards
                OperationQueue.main.addOperation {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                return
            }
        })
    }
}

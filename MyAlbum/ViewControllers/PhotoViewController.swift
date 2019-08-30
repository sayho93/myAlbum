//
//  PhotoViewController.swift
//  MyAlbum
//
//  Created by 전세호 on 26/08/2019.
//  Copyright © 2019 sayho. All rights reserved.
//

import UIKit
import Photos

class PhotoViewController: UIViewController, UIScrollViewDelegate {
    var asset: PHAsset!
    let imageManager =  PHCachingImageManager()
    var gesture = UITapGestureRecognizer()
    
    @IBOutlet var imageView: UIImageView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return self.imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchPhoto()
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.navigationBar.isTranslucent = false
        
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
        
        gesture = UITapGestureRecognizer(target: imageView, action: #selector(PhotoViewController.gestureActivated))
//        gesture.numberOfTapsRequired = 1
//        gesture.numberOfTouchesRequired = 1
    }
    
    @objc func gestureActivated() {
        let tap = gesture.location(in: imageView)
        print("::::::tapped")
        imageView.backgroundColor = .black
        
        if let image = imageView.image?.accessibilityFrame {
            if !image.contains(tap) {
                imageView.backgroundColor = .black
            }
            else{
             imageView.backgroundColor = .black
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent{
            self.navigationController?.hidesBarsOnTap = false
            self.navigationController?.navigationBar.isTranslucent = false
        }
    }
    
    func fetchPhoto(){
        let option = PHImageRequestOptions()
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        option.isNetworkAccessAllowed = true
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
}

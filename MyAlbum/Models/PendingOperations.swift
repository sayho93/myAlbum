//
//  PendingOperations.swift
//  MyAlbum
//
//  Created by 전세호 on 30/08/2019.
//  Copyright © 2019 sayho. All rights reserved.
//

import Foundation
class PendingOperations{
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var filtrationsInProgress: [IndexPath: Operation] = [:]
    lazy var filtrationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var processInProgress: [IndexPath: Operation] = [:]
    lazy var processQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Process Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

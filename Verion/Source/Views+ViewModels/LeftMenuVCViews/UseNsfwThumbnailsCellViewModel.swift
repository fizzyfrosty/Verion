//
//  UseNsfwThumbnailsCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 1/10/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

class UseNsfwThumbnailsCellViewModel {

    var shouldUseNsfwThumbnails = Observable<Bool>(false)
    var isSwitchEnabled = Observable<Bool>(true)
}

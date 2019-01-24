//
//  SlidePickerFlowLayout.swift
//  Dmitry Klimkin
//
//  Created by Dmitry Klimkin on 15/3/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import Foundation
import UIKit

open class SlidePickerFlowLayout: UICollectionViewFlowLayout {
        
    func update(withDirection scrollDirection: UICollectionView.ScrollDirection) {
        self.scrollDirection = scrollDirection
        self.minimumInteritemSpacing = 0.0
        self.minimumLineSpacing = 0.0
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}

//
//  GridViewController.swift
//  Catalog
//
//  Created by Nhat Tran on 10/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

class GridViewController : UICollectionViewFlowLayout {
    
    
//    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        if let cv = self.collectionView {
//            
//            let cvBounds = cv.bounds
//            let halfWidth = cvBounds.size.width * 0.5
//            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth
//            
//            
//            let attributesForVisibleCells = self.layoutAttributesForElementsInRect(cvBounds)! as [UICollectionViewLayoutAttributes]
//            var candidateAttributes : UICollectionViewLayoutAttributes?
//            for attributes in attributesForVisibleCells {
//                
//                // == Skip comparison with non-cell items (headers and footers) == //
//                if attributes.representedElementCategory != UICollectionElementCategory.Cell {
//                    continue
//                }
//                
//                if let candAttrs = candidateAttributes {
//                    
//                    let a = attributes.center.x - proposedContentOffsetCenterX
//                    let b = candAttrs.center.x - proposedContentOffsetCenterX
//                    
//                    if fabsf(Float(a)) < fabsf(Float(b)) {
//                        candidateAttributes = attributes;
//                    }
//                    
//                }
//                else {
//                    
//                    candidateAttributes = attributes;
//                    continue;
//                }
//                
//                
//            }
//            
//            return CGPoint(x: round(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
//        }
//        
//        return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
//    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesToReturn:[UICollectionViewLayoutAttributes] = super.layoutAttributesForElementsInRect(rect)! as [UICollectionViewLayoutAttributes]
        
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        
        if (attributesToReturn.count > 0) {
            
            attributesCopy = copyAttributesArray(attributesToReturn)
            
            for i in 1..<attributesCopy.count {
                
                let currentLayoutAttributes = attributesCopy[i]
                let prevLayoutAttributes = attributesCopy[i - 1]
                let maximumSpacing = CGFloat(0)
                let origin = CGRectGetMaxY(prevLayoutAttributes.frame)
//                print("\(origin) + \(maximumSpacing) + \(currentLayoutAttributes.frame.size.width)")
//                print(self.collectionViewContentSize())
                if (origin + maximumSpacing + currentLayoutAttributes.frame.size.height < self.collectionViewContentSize().height) {
                    var frame = currentLayoutAttributes.frame
                    frame.origin.y = origin + maximumSpacing
                    currentLayoutAttributes.frame = frame
                }
            }
        }
        
        return attributesCopy
    }
    
    /// Copy() function to prevent warning - try to copy as in Objective-C, Swift are value types so don't have copy() in Array
    
    func copyAttributesArray(attributesToReturn:[UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]{
        
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        // Copy item attributes
        for itemAttributes in attributesToReturn {
            let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            // add the changes to the itemAttributesCopy
            attributesCopy.append(itemAttributesCopy)
        }
        
        return attributesCopy
    }
}
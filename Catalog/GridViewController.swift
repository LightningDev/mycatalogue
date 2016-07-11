//
//  GridViewController.swift
//  Catalog
//
//  Created by Nhat Tran on 10/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

class GridViewController : UICollectionViewFlowLayout {
    
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if let cv = self.collectionView {
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth
            
            
            let attributesForVisibleCells = self.layoutAttributesForElementsInRect(cvBounds)! as [UICollectionViewLayoutAttributes]
            var candidateAttributes : UICollectionViewLayoutAttributes?
            for attributes in attributesForVisibleCells {
                
                // == Skip comparison with non-cell items (headers and footers) == //
                if attributes.representedElementCategory != UICollectionElementCategory.Cell {
                    continue
                }
                
                if let candAttrs = candidateAttributes {
                    
                    let a = attributes.center.x - proposedContentOffsetCenterX
                    let b = candAttrs.center.x - proposedContentOffsetCenterX
                    
                    if fabsf(Float(a)) < fabsf(Float(b)) {
                        candidateAttributes = attributes;
                    }
                    
                }
                else {
                    
                    candidateAttributes = attributes;
                    continue;
                }
                
                
            }
            
            return CGPoint(x: round(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
        }
        
        return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
    }
}
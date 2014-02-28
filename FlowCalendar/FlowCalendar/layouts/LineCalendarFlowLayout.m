//
//  LineCalendarFlowLayout.m
//  MoveOnLayout
//
//  Created by bhliu on 14-2-18.
//  Copyright (c) 2014年 bhliu. All rights reserved.
//

#import "LineCalendarFlowLayout.h"

const CGFloat PDTSimpleCalendarFlowLayoutMinInterItemSpacing = 0.0f;
const CGFloat PDTSimpleCalendarFlowLayoutMinLineSpacing = 0.0f;
const CGFloat PDTSimpleCalendarFlowLayoutInsetTop = 5.0f;
const CGFloat PDTSimpleCalendarFlowLayoutInsetLeft = 5.0f;
const CGFloat PDTSimpleCalendarFlowLayoutInsetBottom = 5.0f;
const CGFloat PDTSimpleCalendarFlowLayoutInsetRight = 5.0f;
const CGFloat PDTSimpleCalendarFlowLayoutHeaderHeight = 30.0f;

@implementation LineCalendarFlowLayout

-(id)init
{
    self = [super init];
    if (self) {
        self.minimumInteritemSpacing = PDTSimpleCalendarFlowLayoutMinInterItemSpacing;
        self.minimumLineSpacing = PDTSimpleCalendarFlowLayoutMinLineSpacing;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsZero;
        //self.sectionInset = UIEdgeInsetsMake(PDTSimpleCalendarFlowLayoutInsetTop, PDTSimpleCalendarFlowLayoutInsetLeft, PDTSimpleCalendarFlowLayoutInsetBottom, PDTSimpleCalendarFlowLayoutInsetRight);
        self.headerReferenceSize = CGSizeMake(0, PDTSimpleCalendarFlowLayoutHeaderHeight);
        
        //Note: Item Size is defined using the delegate to take into account the width of the view and calculate size dynamically
    }
    
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        if (layoutAttributes.representedElementCategory != UICollectionElementCategoryCell)
            continue; // skip headers
        
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end

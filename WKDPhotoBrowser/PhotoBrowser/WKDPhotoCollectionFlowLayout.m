//
//  WKDPhotoCollectionHeaderFlowLayout.m
//  WKDPhotoBrowser
//
//  Created by zm on 2017/11/9.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "WKDPhotoCollectionFlowLayout.h"

@implementation WKDPhotoCollectionFlowLayout

- (instancetype)init{
    self = [super init];
    if(self){
        _navHeight = 64.f;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
     NSMutableArray <UICollectionViewLayoutAttributes *>*superArray = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    NSMutableIndexSet *sectionIndexSet = [NSMutableIndexSet indexSet];
    
    [superArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.representedElementCategory == UICollectionElementCategoryCell)
        {
            [sectionIndexSet addIndex:obj.indexPath.section];
        }
    }];
    
    [superArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
        {
            [sectionIndexSet removeIndex:obj.indexPath.section];
        }
    }];
    
    [sectionIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        if(attributes){
            [superArray addObject:attributes];
        }
    }];
    
    [superArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
        {
             NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:obj.indexPath.section];
             NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:obj.indexPath.section];
             NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:MAX(0, numberOfItemsInSection-1) inSection:obj.indexPath.section];
            
            UICollectionViewLayoutAttributes *firstItemAttributes, *lastItemAttributes;
            if(numberOfItemsInSection >0){
                firstItemAttributes = [self layoutAttributesForItemAtIndexPath:firstItemIndexPath];
                lastItemAttributes = [self layoutAttributesForItemAtIndexPath:lastItemIndexPath];
            }else{
                firstItemAttributes = [UICollectionViewLayoutAttributes new];
                CGFloat y = CGRectGetMaxY(obj.frame)+self.sectionInset.top;
                firstItemAttributes.frame = CGRectMake(0, y, 0, 0);
                lastItemAttributes = firstItemAttributes;
            }
            
            CGRect rect = obj.frame;
            CGFloat offset = self.collectionView.contentOffset.y + _navHeight;
            CGFloat headerShow_Y = firstItemAttributes.frame.origin.y - rect.size.height - self.sectionInset.top;
            
            CGFloat maxY = MAX(offset,headerShow_Y);
            
            CGFloat headerDisappear_Y = CGRectGetMaxY(lastItemAttributes.frame) + self.sectionInset.bottom - rect.size.height;
            
            rect.origin.y = MIN(maxY, headerDisappear_Y);
            
            obj.frame = rect;
            
            obj.zIndex = 10;
            
        }
    }];
    
    return [superArray copy];
}

@end

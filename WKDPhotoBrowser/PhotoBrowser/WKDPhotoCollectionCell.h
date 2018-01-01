//
//  WKDPhotoCollectionCell.h
//  WKDPhotoBrowser
//
//  Created by zm on 2017/11/5.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKDPhoto.h"

typedef void(^WKDCellSelectedPhotoBlock)(BOOL isSelected, WKDPhoto *photo);

typedef NS_ENUM(NSUInteger, WKDPhotoOptionalStatus) {
    WKDPhotoOptionalStatusNomal = 0,
    WKDPhotoOptionalStatusSelect,
};

@interface WKDPhotoCollectionCell : UICollectionViewCell
@property (nonatomic, strong) WKDPhoto *photo;
@property (nonatomic) WKDPhotoOptionalStatus cellOptionalStatus;
@property (nonatomic, copy) WKDCellSelectedPhotoBlock selectedPhotoBlock;
@property (nonatomic) BOOL isSelected;

@end

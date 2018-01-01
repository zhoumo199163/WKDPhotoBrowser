//
//  WKDPhotoPickerViewController.h
//  WKDPhotoBrowser
//
//  Created by zm on 2017/11/5.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WKDPhoto;
@interface WKDPhotoPickerViewController : UIViewController

- (instancetype) initWithPhotos:(NSArray<WKDPhoto *> *)photos;


@end

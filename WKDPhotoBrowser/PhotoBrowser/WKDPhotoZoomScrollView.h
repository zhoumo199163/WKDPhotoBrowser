//
//  WKDPhotoZoomScrollView.h
//  WKDPhotoBrowser
//  
//  Created by zm on 2017/10/11.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKDPhoto.h"

@interface WKDPhotoZoomScrollView : UIView
@property (nonatomic,strong) WKDPhoto *photo;
- (instancetype)initWithPhoto:(WKDPhoto *)photo;
@end

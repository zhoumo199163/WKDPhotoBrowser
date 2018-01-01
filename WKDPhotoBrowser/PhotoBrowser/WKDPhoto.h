//
//  WKDPhoto.h
//  WKDPhotoBrowser
//
//  Created by zm on 2017/10/11.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WKDPhotoType) {
    WKDPhotoTypeImage = 0,
    WKDPhotoTypeVideo,
};

typedef NS_ENUM(NSUInteger, WKDPhotoImageType) {
    WKDPhotoImageTypeUnknown = 0,
    WKDPhotoImageTypeThumb,
    WKDPhotoImageTypeOrigin,
};

@interface WKDPhoto : NSObject
@property (nonatomic) WKDPhotoType photoType;
@property (nonatomic) WKDPhotoImageType photoImageType;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSURL *url;
// 预计下载大小 kb
@property (nonatomic) CGFloat preBytes;
// 视频时长
@property (nonatomic, copy) NSString *videoDuration;
// 附加属性
@property (nonatomic, copy) NSDate *photoDate;

- (instancetype)initWithImageUrl:(NSURL *)imageUrl thumbImage:(UIImage *)image;
- (instancetype)initWithVideoUrl:(NSURL *)videoUrl thumbImage:(UIImage *)image;

@end

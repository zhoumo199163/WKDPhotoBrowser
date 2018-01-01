//
//  WKDPhoto.m
//  WKDPhotoBrowser
//
//  Created by zm on 2017/10/11.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "WKDPhoto.h"
@interface WKDPhoto()
@end;
@implementation WKDPhoto

- (instancetype)initWithImageUrl:(NSURL *)imageUrl thumbImage:(UIImage *)image{
    return [self initWithVideoUrl:nil imageUrl:imageUrl thumbImage:image];
}
- (instancetype)initWithVideoUrl:(NSURL *)videoUrl thumbImage:(UIImage *)image{
    return [self initWithVideoUrl:videoUrl imageUrl:nil thumbImage:image];
}

- (instancetype)initWithVideoUrl:(NSURL *)videoUrl
                        imageUrl:(NSURL *)imageUrl
                      thumbImage:(UIImage *)thumbImage{
    self = [super init];
    if(self){
        if(videoUrl){
            _photoType = WKDPhotoTypeVideo;
            _url = videoUrl;
            _image = thumbImage;
        }else if(imageUrl){
            _photoType = WKDPhotoTypeImage;
            _image = thumbImage;
            _photoImageType = WKDPhotoImageTypeThumb;
            
            UIImage *image = [UIImage imageWithContentsOfFile:imageUrl.absoluteString];
            if(image){
                _image = image;
                _photoImageType = WKDPhotoImageTypeOrigin;
            }
        }
       
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@---dealloc",self);
}


@end

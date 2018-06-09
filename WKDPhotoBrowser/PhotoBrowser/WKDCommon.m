//
//  WKDCommon.m
//  WKDPhotoBrowser
//
//  Created by 周末 on 2018/6/4.
//  Copyright © 2018年 zm. All rights reserved.
//

#import "WKDCommon.h"

@implementation WKDCommon
+ (CGSize)sizeAspectFillForView:(UIView *)view image:(UIImage *)image{
    CGSize imageSize = image.size;
    CGSize screenSize = view.bounds.size;
    CGFloat widthRatio= screenSize.width/imageSize.width;
    CGFloat heightRatio = screenSize.height/imageSize.height;
    if(widthRatio <= heightRatio){
        return CGSizeMake(imageSize.width *widthRatio, imageSize.height * widthRatio);
    }
    if(heightRatio < widthRatio){
        return CGSizeMake(imageSize.width*heightRatio, imageSize.height*heightRatio);
    }
    
    return screenSize;
}


+ (CGSize)sizeAspectFitForView:(UIView *)view image:(UIImage *)image{
    CGSize imageSize = image.size;
    CGSize screenSize = view.bounds.size;
    CGFloat widthRatio= screenSize.width/imageSize.width;
    CGFloat heightRatio = screenSize.height/imageSize.height;
    if(widthRatio >= 1.0 && heightRatio >= 1.0){
        return screenSize;
    }
    if(widthRatio <= heightRatio){
        return CGSizeMake(imageSize.width*heightRatio, imageSize.height * heightRatio);
    }
    if(heightRatio < widthRatio){
        return CGSizeMake(imageSize.width*widthRatio, imageSize.height*widthRatio);
    }
    
    return screenSize;
}

@end

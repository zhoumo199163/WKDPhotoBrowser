//
//  WKDCommon.h
//  WKDPhotoBrowser
//
//  Created by 周末 on 2018/6/4.
//  Copyright © 2018年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WKDCommon : NSObject
/**
 按照比例充满view

 @param view 需要充满的view
 @param image 图片
 @return size
 */
+ (CGSize)sizeAspectFillForView:(UIView *)view image:(UIImage *)image;
/**
 充满view，多余裁剪

 @param view 需要充满的view
 @param image 图片
 @return size
 */
+ (CGSize)sizeAspectFitForView:(UIView *)view image:(UIImage *)image;
@end

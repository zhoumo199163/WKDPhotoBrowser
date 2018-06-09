//
//  WKDPhotoHandler.h
//  WKDPhotoBrowser
//
//  Created by 周末 on 2018/5/30.
//  Copyright © 2018年 周末. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WKDPhoto;
/**
 数据操作
 */
@interface WKDPhotoHandler : NSObject
+ (instancetype) sharedInstance;
- (NSArray <WKDPhoto *> *)getAllPhotos;
- (NSUInteger)count;
- (void)updatePhoto:(WKDPhoto *)photo atIndex:(NSInteger)index;

/**
 下载完成
 */
- (void)downloadCompleteUpdatePhotoLocalPath:(NSURL *)localPath atIndex:(NSInteger)index;
@end

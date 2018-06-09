//
//  WKDRequestHandler.h
//  WKDPhotoBrowser
//
//  Created by 周末 on 2018/6/4.
//  Copyright © 2018年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^requestCompleteBlock)(BOOL isComplete,float progress,NSURL *downloadFilePath,NSError *error);
/**
 下载操作
 */
@interface WKDRequestHandler : NSObject<NSURLSessionDelegate>
+ (instancetype)sharedInstance;
- (void)downloadTaskWithURL:(NSURL *)url completeBlock:(requestCompleteBlock)block;
@end

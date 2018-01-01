//
//  WKDPhotoBrowserViewController.h
//  WKDPhotoBrowser
//
//  Created by zm on 2017/10/11.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKDPhoto.h"

@class WKDPhotoBrowserViewController,WKDPhotoPickerViewController;
@protocol WKDPhotoBrowserDelegate <NSObject>
@required
- (NSUInteger)numberOfPhotosInPhotoBrowser:(WKDPhotoBrowserViewController *)photoBrowser;
- (WKDPhoto *)photoBrowser:(WKDPhotoBrowserViewController *)photoBrowser photoAtIndex:(NSUInteger)index;
@optional
- (void)downloadOriginPhotoInPhotoBrowser:(WKDPhotoBrowserViewController *)photoBrowser originPhotoAtIndex:(NSUInteger)index;
- (void)dismissPhotoBrowser:(WKDPhotoBrowserViewController *)photoBrowser;
// 转发
- (void)transmitPhotoInPhotoPicker:(WKDPhotoPickerViewController *)photoPicker transmitPhotoAtIndex:(NSUInteger)index;
// 长按
- (void)longGestureInPhotoBrowser:(WKDPhotoBrowserViewController *)photoBroser gestureAtIndex:(NSUInteger)index;
@end

@interface WKDPhotoBrowserViewController : UIViewController
@property (nonatomic, weak) id<WKDPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL isShowPhotoPicker;
@property (nonatomic) BOOL playAfterDownload;

- (instancetype)initWithDelegate:(id<WKDPhotoBrowserDelegate>)delegate;

- (void)reloadData;
- (void)reloadDataAtIndex:(NSUInteger)index;

- (void)setCurrentPhotoIndex:(NSUInteger)index;

- (void)updateLoadingView:(NSUInteger)index progress:(CGFloat)progress;
- (void)removeLoadingView:(NSUInteger)index;
@end

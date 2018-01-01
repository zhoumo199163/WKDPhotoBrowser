//
//  WKDVideoPlayView.h
//  WKDPhotoBrowser
//
//  Created by zm on 2017/10/29.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const WKDClosePlayingVideoNotification;  // 关闭正在播放的视频通知

@interface WKDVideoPlayView : UIView
- (instancetype)init;
- (void)setPlayItemWithUrl:(NSURL *)url;
@end

//
//  WKDVideoPlayView.m
//  WKDPhotoBrowser
//
//  Created by zm on 2017/10/29.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "WKDVideoPlayView.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, WKDVideoPlayState) {
    WKDVideoPlayStatePause = 0,
    WKDVideoPlayStatePlaying,
};

static NSInteger PauseButton_Width = 30;
static NSInteger ProgressSlider_Padding = 20;

NSString *const WKDClosePlayingVideoNotification = @"WKDClosePlayingVideoNotification";

@interface WKDVideoPlayView (){
    BOOL _isDraggingSlider;
    id _playingProgressObserve;
    WKDVideoPlayState _playState;
}
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerItem *avPlayItem;
@property (nonatomic, strong) AVPlayerLayer *avPlayLayer;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UISlider *playProgressSlider;
@property (nonatomic, strong) UIProgressView *bufferProgressView;
@property (nonatomic, strong) UILabel *playingTimeLabel; // 进度时间
@property (nonatomic, strong) UILabel *videoTotalTimeLabel; // 总时间
@end

@implementation WKDVideoPlayView
- (instancetype)init{
    self = [super init];
    if(self){
        
        _avPlayer = [[AVPlayer alloc] init];
        _avPlayLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
        [self.layer addSublayer:self.avPlayLayer];
        [self addSubview:self.pauseButton];
        [self addSubview:self.videoTotalTimeLabel];
        [self addSubview:self.playingTimeLabel];
        [self addSubview:self.bufferProgressView];
        [self addSubview:self.playProgressSlider];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:WKDClosePlayingVideoNotification object:nil];
        
    }
    return self;
}

- (void)setPlayItemWithUrl:(NSURL *)url{
    _videoUrl = url;
    self.avPlayItem = [AVPlayerItem playerItemWithURL:url];
    [self.avPlayer replaceCurrentItemWithPlayerItem:self.avPlayItem];
    
    [self addObserver];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.avPlayLayer.frame = self.bounds;
    
    
    self.pauseButton.frame = ({
        CGRect rect =CGRectMake(PauseButton_Width, self.bounds.size.height - 10 - PauseButton_Width, PauseButton_Width, PauseButton_Width);
        rect;
    });
    
    self.playingTimeLabel.frame = ({
        CGRect pauseFrame = self.pauseButton.frame;
        CGRect rect =CGRectMake(PauseButton_Width*3, pauseFrame.origin.y, PauseButton_Width, PauseButton_Width);
        rect;
    });
    
    self.videoTotalTimeLabel.frame = ({
        CGRect bound = self.bounds;
        CGRect rect = CGRectMake(bound.size.width - PauseButton_Width -ProgressSlider_Padding, self.pauseButton.frame.origin.y, PauseButton_Width, PauseButton_Width);
        rect;
    });
    
    self.playProgressSlider.frame = ({
        CGRect totalLabelFrame = self.videoTotalTimeLabel.frame;
        CGRect playingLabelFrame = self.playingTimeLabel.frame;
        CGFloat x = playingLabelFrame.origin.x + PauseButton_Width + ProgressSlider_Padding;
        CGRect rect = CGRectMake(x , totalLabelFrame.origin.y, self.bounds.size.width - x - ProgressSlider_Padding*2 - PauseButton_Width, PauseButton_Width);
        rect;
    });
    
    self.bufferProgressView.frame = ({
        CGRect rect = self.playProgressSlider.frame;
        rect;
    });
    
    self.bufferProgressView.center = self.playProgressSlider.center;
    
}


- (void)addObserver{
    [self.avPlayItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil]; // 观察status属性
    [self.avPlayItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil]; // 观察缓冲进度
    [self observePlayingProgress]; // 观察播放进度
    
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}

- (void)removeObserver{
    [self.avPlayItem removeObserver:self forKeyPath:@"status"];
    [self.avPlayItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.avPlayer removeTimeObserver:_playingProgressObserve];
    _playingProgressObserve = nil;
   
}

- (void)clear{
    [self removeObserver];
    _avPlayer = nil;
    _avPlayItem = nil;
    _avPlayLayer = nil;
}

#pragma mark - Get

- (UIButton *)pauseButton{
    if(!_pauseButton){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(pauseAction) forControlEvents:UIControlEventTouchUpInside];
        
        _pauseButton = button;
    }
    return _pauseButton;
}

- (UILabel *)playingTimeLabel{
    if(!_playingTimeLabel){
        _playingTimeLabel = [UILabel new];
        [_playingTimeLabel setTextColor:[UIColor whiteColor]];
        [_playingTimeLabel setText:@"00:00"];
        [_playingTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
    }
    return _playingTimeLabel;
}

- (UILabel *)videoTotalTimeLabel{
    if(!_videoTotalTimeLabel){
        _videoTotalTimeLabel = [UILabel new];
        [_videoTotalTimeLabel setTextColor:[UIColor whiteColor]];
        [_videoTotalTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
    }
    return _videoTotalTimeLabel;
}

- (UISlider *)playProgressSlider{
    if(!_playProgressSlider){
        _playProgressSlider = [UISlider new];
        [_playProgressSlider setTintColor:[UIColor whiteColor]];
        [_playProgressSlider setThumbImage:[UIImage imageNamed:@"progressSlider.png"] forState:UIControlStateNormal];
        [_playProgressSlider setValue:0.0];
        [_playProgressSlider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        [_playProgressSlider addTarget:self action:@selector(sliderTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        [_playProgressSlider addTarget:self action:@selector(sliderTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_playProgressSlider setBackgroundColor:[UIColor clearColor]];
        [_playProgressSlider setMaximumTrackTintColor:[UIColor clearColor]];
        [_playProgressSlider setMinimumTrackTintColor:[UIColor clearColor]];
    }
    return _playProgressSlider;
}

- (UIProgressView *)bufferProgressView{
    if(!_bufferProgressView){
        _bufferProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _bufferProgressView.progress = 0.0;
        [_bufferProgressView setTrackTintColor:[UIColor lightGrayColor]];
        [_bufferProgressView setTintColor:[UIColor whiteColor]];
    }
    return _bufferProgressView;
}

#pragma mark - Action
- (void)pauseAction{
    BOOL isPlay = self.pauseButton.selected;
    if(isPlay){
        [self play];
    }else{
        [self pause];
    }
    self.pauseButton.selected = !isPlay;
}

- (void)sliderValueChangedAction:(UISlider *)sender{
    UISlider *slider = sender;
    _isDraggingSlider = YES;
    [self updatePauseButtonForSliderChangeValue];
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1.0);
    [self.avPlayItem seekToTime:changedTime completionHandler:^(BOOL finished) {
        
    }];
}

- (void)sliderTouchUpInsideAction:(UISlider *)sender{
    _isDraggingSlider = NO;
    [self updatePauseButtonForSliderChangeValue];

}

- (void)updatePauseButtonForSliderChangeValue{
    self.pauseButton.selected = !_isDraggingSlider;
    [self pauseAction];
}

- (void)sliderTouchDownAction:(UISlider *)sender{
    [self pause];
}

- (void)closeButtonAction{
    [self pause];
    [self removeObserver];
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:WKDClosePlayingVideoNotification object:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
        if (status == AVPlayerStatusReadyToPlay) {
            CMTime duration = item.duration; // 获取视频长度
            // 设置视频时间
            [self setTotalTime:CMTimeGetSeconds(duration)];
            // 播放
            [self play];
        } else if (status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        } else {
            NSLog(@"AVPlayerStatusUnknown");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSTimeInterval timeInterval = [self videoBufferedProgress]; // 缓冲时间
            CGFloat totalDuration = CMTimeGetSeconds(self.avPlayItem.duration); // 总时间
            [self.bufferProgressView setProgress:timeInterval / totalDuration animated:YES]; // 更新缓冲条
    }
}

- (void)observePlayingProgress{
    __weak __typeof(self) weakSelf = self;
    _playingProgressObserve = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float currentPlayTime = (double)weakSelf.avPlayItem.currentTime.value/ weakSelf.avPlayItem.currentTime.timescale;
        [weakSelf updateProgressTime:currentPlayTime];
    }];
}

#pragma mark - Play

- (void)play{
    [self.avPlayer play];
    _playState = WKDVideoPlayStatePlaying;
}

- (void)pause{
    [self.avPlayer pause];
    _playState = WKDVideoPlayStatePause;
}

- (void)playVideoFinished:(NSNotification *)notif{
    [self removeObserver];
    [self removeFromSuperview];
}

// 视频已缓冲时间
- (NSTimeInterval)videoBufferedProgress{
    NSArray *loadedTimeRanges = [self.avPlayItem loadedTimeRanges]; // 获取item的缓冲数组
    // discussion Returns an NSArray of NSValues containing CMTimeRanges
    
    // CMTimeRange 结构体 start duration 表示起始位置 和 持续时间
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; // 计算总缓冲时间 = start + duration
    return result;
}


#pragma mark - setting
- (void)setTotalTime:(float)totalTime{
    [self.videoTotalTimeLabel setText:[self transformTime:totalTime]];
    [self.playProgressSlider setMaximumValue:totalTime];
}

- (void)updateProgressTime:(float)currentProgress{
    [self.playingTimeLabel setText:[self transformTime:currentProgress]];
    [self.playProgressSlider setValue:currentProgress];
}

- (NSString *)transformTime:(float)second{
    // 相对格林时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    
    NSString *showTimeNew = [formatter stringFromDate:date];
    return showTimeNew;
}

- (void)dealloc{
    NSLog(@"%@---dealloc",self);
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


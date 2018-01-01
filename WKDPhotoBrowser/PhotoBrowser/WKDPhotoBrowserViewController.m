//
//  WKDPhotoBrowserViewController.m
//  WKDPhotoBrowser
//
//  Created by zm on 2017/10/11.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "WKDPhotoBrowserViewController.h"
#import "WKDPhotoZoomScrollView.h"
#import "WKDVideoPlayView.h"
#import "WKDPhotoPickerViewController.h"
#import "WKDPhotoCircleLoadingView.h"
#import "WKDProgressButton.h"

static NSInteger ScrollView_Padding = 10;
static NSInteger DownloadOriginButton_height = 25;
static NSInteger DownloadOriginButton_width = 80;
static NSInteger CheckAllImages_width = 40;
static NSInteger CloseButton_Width = 30;

static NSInteger DownloadProgressButtonTag = 1000;
static NSInteger CloseButtonTag = 2000;
static NSInteger VideoPlayButtonTag = 4000;

struct  {
    unsigned  int numberOfPhotosInPhotoBrowser : 1;
    unsigned  int photoAtIndex  : 1;
    unsigned  int downloadOriginPhotoInPhotoBrowser :1;
    unsigned  int dismissPhotoBrowser :1;
    unsigned  int transmitPhotoInPhotoPicker :1;
    unsigned  int longGestureInPhotoBrowser :1;
} _WKDPhotoBrowserDelegateFlag;

@interface WKDPhotoBrowserViewController ()<UIScrollViewDelegate>{
    NSUInteger _currentPageIndex;
}

@property (nonatomic, strong) UIScrollView *pageScrollView;

@property (nonatomic, strong) NSMutableArray<WKDPhoto *> *photos;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *,UIView *>*loadingViewCache;
@property (nonatomic, strong) NSCache <NSNumber *,WKDPhotoZoomScrollView *> * preLoadPageViews;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *,WKDPhotoZoomScrollView *> *showedPageViews;

@property (nonatomic) NSUInteger photosCount;

@end

@implementation WKDPhotoBrowserViewController
- (instancetype)init{
    self = [super init];
    if(self){
        [self initialization];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<WKDPhotoBrowserDelegate>)delegate{
    self = [self init];
    if(self){
        self.delegate = delegate;
    }
    return self;
}

- (void)initialization{
    _currentPageIndex = 0;
    _photosCount = NSNotFound;
    _loadingViewCache = [NSMutableDictionary new];
    _preLoadPageViews = [NSCache new];
    _preLoadPageViews.countLimit = 30;
    _preLoadPageViews.totalCostLimit = 10;
    _showedPageViews = [NSMutableDictionary new];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.view.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleToDismiss:)];
    [self.view addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureAction:)];
    [self.view addGestureRecognizer:longGesture];
    
    [self.view addSubview:self.pageScrollView];
    
   
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    if(_isShowPhotoPicker){
        [self.view addSubview:[self createPhotoPickerButton]];
    }
    
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@---dealloc",self);
}

- (void)clearData{
    [_photos removeAllObjects];
    _photosCount = NSNotFound;
    _photos = nil;
    [_loadingViewCache removeAllObjects];
    [_showedPageViews removeAllObjects];
}

- (void)reloadData{
    [self clearData];
    
    NSUInteger numberOfPhotos = [self photosCount];
    if (numberOfPhotos > 0) {
        _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    } else {
        _currentPageIndex = 0;
    }
    [self photos];
    [self updateLayout:_currentPageIndex];
}

- (void)reloadDataAtIndex:(NSUInteger)index{
    WKDPhoto *photo = [_delegate photoBrowser:self photoAtIndex:index];
    [self.photos replaceObjectAtIndex:index withObject:photo];
    
    [self.preLoadPageViews removeObjectForKey:@(index)];
    [self.showedPageViews removeObjectForKey:@(index)];
    
    if(index == _currentPageIndex){
        [self updateLayout:_currentPageIndex];
    }
    
    if(photo.photoType == WKDPhotoTypeVideo && _playAfterDownload){
        [self playVideoAction];
    }
}

- (void)preLoadWillShowPageViews:(NSInteger)index{
    if(index >= [self photosCount]) index = [self photosCount]-1;
    if(index <= 0) index = 0;
    WKDPhotoZoomScrollView *pageView = [self.preLoadPageViews objectForKey:@(index)];
    
    if(!pageView){
        WKDPhoto *photo = self.photos[index];
        
        pageView = [[WKDPhotoZoomScrollView alloc] initWithPhoto:photo];
        [pageView setFrame:[self frameForPageViewAtIndex:index]];
        
        UIView *loadingView = self.loadingViewCache[@(index)];
        if(loadingView){
            [pageView addSubview:loadingView];
        }
        [self.preLoadPageViews setObject:pageView forKey:@(index)];
        
        [self resetButtons:index];
    }
}

- (void)updateLayout:(NSUInteger)page{
    WKDPhotoZoomScrollView *currentPageView = [self.preLoadPageViews objectForKey:@(page)];
    WKDPhotoZoomScrollView *showedPageView = [self.showedPageViews objectForKey:@(page)];
    if(currentPageView && !showedPageView) {
        self.showedPageViews[@(page)] = currentPageView;
        [self.pageScrollView addSubview:currentPageView];
        return;
    }
    if(!currentPageView && !showedPageView){
        
        WKDPhoto *photo = self.photos[page];
        
        WKDPhotoZoomScrollView *pageView = [[WKDPhotoZoomScrollView alloc] initWithPhoto:photo];
        [pageView setFrame:[self frameForPageViewAtIndex:page]];
        [self.pageScrollView addSubview:pageView];
        
        UIView *loadingView = self.loadingViewCache[@(page)];
        if(loadingView){
            [pageView addSubview:loadingView];
        }
        [self.showedPageViews setObject:pageView forKey:@(page)];
        [self.preLoadPageViews setObject:pageView forKey:@(page)];
        
        [self resetButtons:page];
        [self.pageScrollView setContentOffset:[self contentOffSetForPageScrollView:_currentPageIndex] animated:NO];
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)index{
    _currentPageIndex = index;
}

#pragma mark - Set
- (void)setDelegate:(id<WKDPhotoBrowserDelegate>)delegate{
    if(delegate){
        _delegate = delegate;
        if([delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]){
            _WKDPhotoBrowserDelegateFlag.numberOfPhotosInPhotoBrowser = 1;
        }
        if([delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]){
            _WKDPhotoBrowserDelegateFlag.photoAtIndex = 1;
        }
        if([delegate respondsToSelector:@selector(downloadOriginPhotoInPhotoBrowser:originPhotoAtIndex:)]){
            _WKDPhotoBrowserDelegateFlag.downloadOriginPhotoInPhotoBrowser = 1;
        }
        if([delegate respondsToSelector:@selector(dismissPhotoBrowser:)]){
            _WKDPhotoBrowserDelegateFlag.dismissPhotoBrowser = 1;
        }
        if([delegate respondsToSelector:@selector(transmitPhotoInPhotoPicker:transmitPhotoAtIndex:)]){
            _WKDPhotoBrowserDelegateFlag.transmitPhotoInPhotoPicker = 1;
        }
        if([delegate respondsToSelector:@selector(longGestureInPhotoBrowser:gestureAtIndex:)]){
            _WKDPhotoBrowserDelegateFlag.longGestureInPhotoBrowser = 1;
        }
    }
}

#pragma mark - Get
- (WKDProgressButton *)createProgressButton:(WKDPhoto *)photo{
    WKDProgressButton *button = [WKDProgressButton buttonWithType:UIButtonTypeCustom];
    [button setTag:DownloadProgressButtonTag];
    [button setTitle:@"查看原图" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    CGRect bounds = self.view.bounds;
    [button setFrame:CGRectMake(bounds.size.width/2 - DownloadOriginButton_width/2, bounds.size.height - DownloadOriginButton_height*2, DownloadOriginButton_width, DownloadOriginButton_height)];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:3];
    [button.layer setBorderWidth:0.5];
    [button.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    return button;
}


- (UIButton *)createPhotoPickerButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"checkAllImages"] forState:UIControlStateNormal];
    CGRect bounds = self.view.bounds;
    [button setFrame:CGRectMake(bounds.size.width - CheckAllImages_width*1.5, CheckAllImages_width*3/4, CheckAllImages_width, CheckAllImages_width)];
    [button addTarget:self action:@selector(checkAllImagesAction) forControlEvents:UIControlEventTouchUpInside];
    [button setHidden:!_isShowPhotoPicker];
    return button;
}

- (UIButton *)createPlayVideoButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTag:VideoPlayButtonTag];
    [button setImage:[UIImage imageNamed:@"playVideo.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    button.center = self.view.center;
    [button addTarget:self action:@selector(playVideoAction) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIButton *)createCloseButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTag:CloseButtonTag];
    [button setImage:[UIImage imageNamed:@"closeThisView.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(CloseButton_Width, CloseButton_Width, CloseButton_Width, CloseButton_Width)];
    [button addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIScrollView *)pageScrollView{
    if(!_pageScrollView){
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[self frameForPageScrollView]];
        scrollView.contentSize = [self contentSizeForPageScrollView];
        scrollView.pagingEnabled = YES;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.delegate = self;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _pageScrollView = scrollView;
    }
    return _pageScrollView;
}

- (NSUInteger)photosCount{
    if(_photosCount == NSNotFound){
        if(_delegate && [_delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]){
            _photosCount = [_delegate numberOfPhotosInPhotoBrowser:self];
        }
    }
    return _photosCount == NSNotFound?0:_photosCount;
}

- (NSMutableArray <WKDPhoto *>*)photos{
    if(!_photos){
        _photos = [NSMutableArray new];
        for (NSUInteger index = 0; index < [self photosCount]; index ++) {
            if(_delegate && [_delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]){
                @autoreleasepool{
                    WKDPhoto *photo = [_delegate photoBrowser:self photoAtIndex:index];
                    [_photos addObject:photo];
                }
            }
        }
    }
    return _photos;
}

#pragma mark - FrameFor...
- (CGRect)frameForPageScrollView{
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= ScrollView_Padding;
    frame.size.width += (2 * ScrollView_Padding);
    return CGRectIntegral(frame);
}

- (CGSize)contentSizeForPageScrollView{
    CGRect bound = [self frameForPageScrollView];
    return CGSizeMake(bound.size.width * [self photosCount], 0);
}

- (CGPoint)contentOffSetForPageScrollView:(NSUInteger)index{
    CGFloat width = self.pageScrollView.bounds.size.width;
    CGFloat offsetX = width*index;
    return CGPointMake(offsetX, self.pageScrollView.contentOffset.y);
}

- (CGRect)frameForPageViewAtIndex:(NSUInteger)index{
    CGRect bounds = _pageScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width = bounds.size.width - 2*ScrollView_Padding;
    pageFrame.origin.x = bounds.size.width *index + ScrollView_Padding;
    return pageFrame;
}

#pragma mark - Action
- (void)longGestureAction:(UILongPressGestureRecognizer *)longGesture{
    if(_WKDPhotoBrowserDelegateFlag.longGestureInPhotoBrowser){
        [_delegate longGestureInPhotoBrowser:self gestureAtIndex:_currentPageIndex];
    }
}

- (void)tapHandleToDismiss:(UITapGestureRecognizer *)tap{
    WKDPhoto *photo = self.photos[_currentPageIndex];
    if(photo.photoType == WKDPhotoTypeImage){
        [self clearData];
        if(_WKDPhotoBrowserDelegateFlag.dismissPhotoBrowser){
            [_delegate dismissPhotoBrowser:self];
        }
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)downloadAction{
    if(_WKDPhotoBrowserDelegateFlag.downloadOriginPhotoInPhotoBrowser){
        [_delegate downloadOriginPhotoInPhotoBrowser:self originPhotoAtIndex:_currentPageIndex];
        [self updateLoadingView:_currentPageIndex progress:0.0];
    }
}

- (void)checkAllImagesAction{
    [_preLoadPageViews removeAllObjects];
    [_showedPageViews removeAllObjects];
    WKDPhotoPickerViewController *photoPicker = [[WKDPhotoPickerViewController alloc] initWithPhotos:self.photos];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backButtonItem;
    [self.navigationController pushViewController:photoPicker animated:YES];
}

- (void)playVideoAction{
    WKDPhoto *photo = self.photos[_currentPageIndex];
    if(photo.url){
        WKDVideoPlayView *videoPlayView = [[WKDVideoPlayView alloc] init];
        [videoPlayView setPlayItemWithUrl:photo.url];
        videoPlayView.frame = self.view.bounds;
        [self.view addSubview:videoPlayView];
        UIButton *closeButton = [self createCloseButton];
        [videoPlayView addSubview:closeButton];
        return;
    }
    [self downloadAction];
}

- (void)closeButtonAction{
    [self clearData];
    if(_delegate && [_delegate respondsToSelector:@selector(dismissPhotoBrowser:)]){
        [_delegate dismissPhotoBrowser:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:WKDClosePlayingVideoNotification object:nil];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    NSUInteger page = contentOffsetX/CGRectGetWidth(scrollView.bounds);
    CGFloat currentPageOffsetX = [self contentOffSetForPageScrollView:_currentPageIndex].x;
    
    if(contentOffsetX < currentPageOffsetX && _currentPageIndex >0){
        [self updateLayout:_currentPageIndex -1];
        [self setCurrentPhotoIndex:page];
        [self preLoadWillShowPageViews:page -1];
    }
    else if(contentOffsetX > currentPageOffsetX && _currentPageIndex <[self photosCount]-1){
        [self updateLayout:_currentPageIndex +1];
        [self setCurrentPhotoIndex:page];
        [self preLoadWillShowPageViews:page+ 1];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self removePageFromSuperview];
    
}

#pragma mark - Other
- (void)resetButtons:(NSUInteger)index{
    BOOL isShoudDownloadButton = NO;
    BOOL isShoudPlayVideoButton = NO;
    WKDPhoto *photo = self.photos[index];
    UIView *loadingView = self.loadingViewCache[@(index)];
    if(photo.photoType == WKDPhotoTypeImage && photo.photoImageType == WKDPhotoImageTypeThumb){
        isShoudDownloadButton = YES;
    }
    
    if(photo.photoType == WKDPhotoTypeVideo && !loadingView){
        isShoudPlayVideoButton = YES;
    }
    
    WKDPhotoZoomScrollView *currentPageView = [self.preLoadPageViews objectForKey:@(index)];
    UIButton *downloadBtn;
    
    if(isShoudDownloadButton) {
        downloadBtn = [self createProgressButton:photo];
        [currentPageView addSubview:downloadBtn];
    }
    
    if(isShoudPlayVideoButton){
        [currentPageView addSubview:[self createPlayVideoButton]];
        [currentPageView addSubview:[self createCloseButton]];
    }
    
    if(downloadBtn){
        if(photo.preBytes){
            NSString *text = [NSString stringWithFormat:@" 查看原图 (%.fKB)",photo.preBytes];
            CGFloat textWidth = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(downloadBtn.frame)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSAttachmentAttributeName:downloadBtn.titleLabel.font} context:nil].size.width;
            CGRect bounds = self.view.bounds;
            textWidth += 30;
            [downloadBtn setFrame:CGRectMake(bounds.size.width/2 - textWidth/2, bounds.size.height - DownloadOriginButton_height*2, textWidth, DownloadOriginButton_height)];
            [downloadBtn setTitle:text forState:UIControlStateNormal];
        }
    }
    [self.preLoadPageViews setObject:currentPageView forKey:@(index)];
}

- (void)removePageFromSuperview{
    NSMutableDictionary *pageViews = self.showedPageViews;
    [pageViews enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, WKDPhotoZoomScrollView * _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger index = [key integerValue];
        if(index != _currentPageIndex){
            [obj removeFromSuperview];
            [pageViews removeObjectForKey:@(index)];
        }
    }];
}

- (UIView *)subviewAtPageView:(UIView *)pageView withTag:(NSInteger)tag{
    __block UIView *view;
    NSArray<UIView *> *subviews = pageView.subviews;
    [subviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.tag == tag){
            view = obj;
            *stop = YES;
        }
    }];
    return view;
}


#pragma mark - LoadingView
- (void)removeLoadingView:(NSUInteger)index{
    UIView *loadingView = self.loadingViewCache[@(index)];
    [self.loadingViewCache removeObjectForKey:@(index)];
    [loadingView setUserInteractionEnabled:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingView removeFromSuperview];
    });
}

- (void)updateLoadingView:(NSUInteger)index progress:(CGFloat)progress{
    WKDPhoto *phote = self.photos[index];
    UIView *loadingView = self.loadingViewCache[@(index)];
    UIView *pageView = [self.preLoadPageViews objectForKey:@(index)];
    UIButton *playButton = (UIButton *)[self subviewAtPageView:pageView withTag:VideoPlayButtonTag];
    if(loadingView){
        if(progress >= 1){
            [self removeLoadingView:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                [playButton setHidden:NO];
            });
        }else{
            if(phote.photoType == WKDPhotoTypeVideo){
                WKDPhotoCircleLoadingView *view = (WKDPhotoCircleLoadingView *)loadingView;
                [view setProgress:progress];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view setNeedsDisplay];
                });
            }else{
                WKDProgressButton *progressButton = (WKDProgressButton *)loadingView;
                [progressButton setProgress:progress];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressButton setNeedsDisplay];
                });
            }
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [playButton setHidden:YES];
        });
        [self addLoadingView:index photoType:phote.photoType];
    }
}

- (void)addLoadingView:(NSUInteger)index photoType:(WKDPhotoType)type{
    __block UIView *loadingView;
    WKDPhotoZoomScrollView *currentPageView =[self.preLoadPageViews objectForKey:@(index)];
    switch (type) {
        case WKDPhotoTypeVideo:{
            WKDPhotoCircleLoadingView *view = [[WKDPhotoCircleLoadingView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            view.center = self.view.center;
            view.progress = 0;
            loadingView = view;
             [currentPageView addSubview:loadingView];
        }
            break;
        case WKDPhotoTypeImage:{
            [currentPageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(obj.tag == DownloadProgressButtonTag){
                    [obj setUserInteractionEnabled:NO];
                    loadingView = obj;
                    *stop = YES;
                }
            }];
            
        }
            break;
        default:
            break;
    }
    [self.preLoadPageViews setObject:currentPageView forKey:@(index)];
    self.loadingViewCache[@(index)] = loadingView;
}

@end

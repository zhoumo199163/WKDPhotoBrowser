//
//  WKDPhotoZoomScrollView.m
//  WKDPhotoBrowser
//
//  Created by zm on 2017/10/11.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "WKDPhotoZoomScrollView.h"

@interface WKDPhotoZoomScrollView ()<UIScrollViewDelegate>
@property (nonatomic , strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITapGestureRecognizer *superSingleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@end
@implementation WKDPhotoZoomScrollView

- (instancetype)initWithPhoto:(WKDPhoto *)photo{
    self = [super init];
    if(self){
         _photo = photo;
        
        self.backgroundColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 5.0;
        _scrollView.delegate = self;
        _scrollView.contentInset = UIEdgeInsetsZero;
        _scrollView.contentSize = CGSizeZero;
        _scrollView.contentOffset = CGPointZero;
        _scrollView.scrollEnabled = NO;
        [self addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.image = _photo.image;
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setUserInteractionEnabled:YES];
        [self.scrollView addSubview:_imageView];
        
        if(_photo.photoType == WKDPhotoTypeImage){
            _scrollView.scrollEnabled = YES;
            _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
            _doubleTapGesture.numberOfTapsRequired = 2;
            [self addGestureRecognizer:_doubleTapGesture];
            
        }
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeZero;
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.zoomScale = 1.0;
    
    self.imageView.image = _photo.image;
    CGSize imageViewSize = [self imageViewSizeForImage:_photo.image];
    self.imageView.frame = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
    self.imageView.center = _scrollView.center;
    
    if(_doubleTapGesture){
        [self.superSingleTapGesture requireGestureRecognizerToFail:_doubleTapGesture];
    }
}

- (UITapGestureRecognizer *)superSingleTapGesture{
    if(!_superSingleTapGesture){
        NSArray <UIGestureRecognizer *>* gestures = self.superview.superview.gestureRecognizers;
        [gestures enumerateObjectsUsingBlock:^(UIGestureRecognizer * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[UITapGestureRecognizer class]]){
                _superSingleTapGesture = (UITapGestureRecognizer *)obj;
                *stop = YES;
            }
        }];
    }
    return _superSingleTapGesture;
}

- (CGSize)imageViewSizeForImage:(UIImage *)image{
    CGSize imageSize = image.size;
    CGSize screenSize = self.bounds.size;
    CGFloat widthRatio= screenSize.width/imageSize.width;
    CGFloat heightRatio = screenSize.height/imageSize.height;
    if(widthRatio >= 1.0 && heightRatio >= 1.0){
        return imageSize;
    }
    if(widthRatio <= heightRatio){
        return CGSizeMake(screenSize.width, imageSize.height * widthRatio);
    }
    if(heightRatio < widthRatio){
        return CGSizeMake(imageSize.width*heightRatio, screenSize.height);
    }
    
    return imageSize;
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap{
   
    if(_scrollView.zoomScale == 1){
         CGPoint tapPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = ((self.scrollView.maximumZoomScale + self.scrollView.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(tapPoint.x - xsize/2, tapPoint.y - ysize/2, xsize, ysize) animated:YES];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            _scrollView.zoomScale = 1;
        }];
    }
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;

    CGFloat offsetX = (width > scrollView.contentSize.width) ? ((width - scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (height > scrollView.contentSize.height) ? ((height - scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)dealloc{
    NSLog(@"%@---dealloc",self);
}


@end

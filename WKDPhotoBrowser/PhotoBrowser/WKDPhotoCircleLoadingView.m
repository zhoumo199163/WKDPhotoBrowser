//
//  WKDPhotoCircleLoadingView.m
//  WKDPhotoBrowser
//
//  Created by zm on 2017/11/9.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "WKDPhotoCircleLoadingView.h"

@interface WKDPhotoCircleLoadingView()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation WKDPhotoCircleLoadingView
- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:frame.size.width/2];
        
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (UIActivityIndicatorView *)indicatorView{
    if(!_indicatorView){
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.color = [UIColor lightGrayColor];
        indicatorView.hidesWhenStopped = YES;
        
        _indicatorView = indicatorView;
    }
    return _indicatorView;
}

- (void)drawRect:(CGRect)rect {
    if(self.progress == 0){
        [self.indicatorView startAnimating];
        return;
    }else{
        [self.indicatorView stopAnimating];
    }
    
    // 进度圆
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    
    CGFloat minCenter = MIN(xCenter, yCenter);
    CGFloat circleRadius = minCenter -2;
    
    // 进程圆半径
    CGFloat progressRadius = circleRadius - 4;
    
     [[UIColor lightGrayColor] setStroke];

    CGContextSetLineWidth(ctx, 1);
    CGContextAddArc(ctx, xCenter, yCenter, circleRadius, 0, M_PI * 2, 1);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, progressRadius);
    CGContextMoveToPoint(ctx, xCenter, yCenter);
    CGContextAddLineToPoint(ctx, xCenter, 0);
    CGFloat to = - M_PI_2 + self.progress* M_PI * 2 + 0.001; // 初始值
    CGContextAddArc(ctx, xCenter, yCenter, progressRadius, - M_PI_2, to, 0);
    [[UIColor lightGrayColor] setFill];
    CGContextClosePath(ctx);
   
    CGContextFillPath(ctx);
}



@end

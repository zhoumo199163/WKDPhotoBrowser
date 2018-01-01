//
//  WKDProgressButton.m
//  WKDPhotoBrowser
//
//  Created by zm on 2017/11/11.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "WKDProgressButton.h"

@implementation WKDProgressButton

- (void)drawRect:(CGRect)rect {
     CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect frame = CGRectMake(0, 0, self.progress*CGRectGetWidth(rect), CGRectGetHeight(rect));
    [[UIColor greenColor] setFill];
    CGContextFillRect(ctx, frame);
}

@end

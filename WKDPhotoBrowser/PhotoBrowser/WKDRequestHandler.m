//
//  WKDRequestHandler.m
//  WKDPhotoBrowser
//
//  Created by 周末 on 2018/6/4.
//  Copyright © 2018年 zm. All rights reserved.
//

#import "WKDRequestHandler.h"

@interface WKDRequestHandler ()
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMutableDictionary *downloadTaskCaches;
@end

@implementation WKDRequestHandler

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static WKDRequestHandler *request;
    dispatch_once(&onceToken, ^{
        request = [[WKDRequestHandler alloc] init];
    });
    return request;
}

- (instancetype)init{
    self = [super init];
    if(self){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _downloadTaskCaches = [NSMutableDictionary new];
    }
    return self;
}


- (void)downloadTaskWithURL:(NSURL *)url completeBlock:(requestCompleteBlock)block{
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithURL:url];
    [task resume];
    if(block){
         self.downloadTaskCaches[@(task.taskIdentifier)] = block;
    }
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *locationString = location.absoluteString;
    NSArray *components = [locationString componentsSeparatedByString:@"/"];
    locationString = [components lastObject];
    components = [locationString componentsSeparatedByString:@"."];
    locationString = [components firstObject];
    
    
    NSData *imageData = [NSData dataWithContentsOfURL:location];
    NSArray* pathes = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) ;
    NSString *filePath = [pathes[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",locationString]];
    BOOL isWrite =  [imageData writeToFile:filePath atomically:YES];
    requestCompleteBlock block = self.downloadTaskCaches[@(downloadTask.taskIdentifier)];
    if(isWrite && block){
        block(YES, 1.0, [NSURL URLWithString:filePath],nil);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
     requestCompleteBlock block = self.downloadTaskCaches[@(downloadTask.taskIdentifier)];
    if(block){
        block(NO, progress, nil, nil);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    if(error){
        requestCompleteBlock block = self.downloadTaskCaches[@(task.taskIdentifier)];
        if(block){
            block(YES, 0, nil, error);
        }
    }
}
@end

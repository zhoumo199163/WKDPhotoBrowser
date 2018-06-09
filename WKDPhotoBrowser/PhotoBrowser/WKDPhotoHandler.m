//
//  WKDPhotoHandler.m
//  WKDPhotoBrowser
//
//  Created by 周末 on 2018/5/30.
//  Copyright © 2018年 周末. All rights reserved.
//

#import "WKDPhotoHandler.h"
#import <UIKit/UIKit.h>
#import "WKDPhoto.h"

@interface WKDPhotoHandler ()
@property (nonatomic, strong) NSMutableArray <WKDPhoto *>*photos;
@end

@implementation WKDPhotoHandler
+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    static WKDPhotoHandler *photoHandler;
    dispatch_once(&onceToken, ^{
        photoHandler = [[WKDPhotoHandler alloc] init];
    });
    return photoHandler;
}

- (NSArray <WKDPhoto *> *)getAllPhotos{
    return [self.photos copy];
}

- (NSUInteger)count{
    return [self.photos count];
}

- (void)updatePhoto:(WKDPhoto *)photo atIndex:(NSInteger)index{
    [self.photos replaceObjectAtIndex:index withObject:photo];
}

- (void)downloadCompleteUpdatePhotoLocalPath:(NSURL *)localPath atIndex:(NSInteger)index{
    WKDPhoto *oldPhoto = [self.photos objectAtIndex:index];
    WKDPhoto *newPhoto = [[WKDPhoto alloc] initWithUrl:localPath thumbImage:oldPhoto.image type:oldPhoto.photoType additionalInfo:oldPhoto.additionalInfo];
    newPhoto.photoDownloadType = WKDPhotoDownloadedState;
    [self updatePhoto:newPhoto atIndex:index];
}

- (NSMutableArray <WKDPhoto *>*)photos{
    if(!_photos){
        _photos = [NSMutableArray arrayWithArray:[self p_parseJsonHandler]];
    }
    return _photos;
}

#pragma mark - private
- (NSArray *)p_parseJsonHandler{
    NSMutableArray <WKDPhoto *> *photos = [NSMutableArray new];
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"]];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    NSArray *jsonPhotos = jsonDic[@"photos"];
    for(NSDictionary *obj in jsonPhotos){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:obj];
        NSString *thumbImagePath = dic[@"thumbImage"];
        thumbImagePath =  [self p_localPathWithFileName:thumbImagePath];
        UIImage *thumbImage = [UIImage imageNamed:thumbImagePath];
        NSString *filePath = dic[@"filePath"];
        if(![filePath hasPrefix:@"https://"] && ![filePath hasPrefix:@"http://"]){
            filePath = [self p_localPathWithFileName:filePath];
        }
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *byte = dic[@"byte"];
        float byteFloat = [byte floatValue];
        NSString *date = dic[@"date"];
        
        NSString *type = dic[@"type"];
        WKDPhotoType photoType = WKDPhotoTypeImage;
        NSDictionary *info = @{@"date":date,@"preSize":@(byteFloat)};
        if([type isEqualToString:@"video"]){
            photoType = WKDPhotoTypeVideo;
            fileUrl = [NSURL fileURLWithPath:filePath];
        }
        WKDPhoto *photo = [[WKDPhoto alloc] initWithUrl:fileUrl thumbImage:thumbImage type:photoType additionalInfo:info];
        [photos addObject:photo];
    }
    return photos;
}

- (NSString *)p_localPathWithFileName:(NSString *)fileName{
    if([fileName isAbsolutePath]){
        return fileName;
    }
    NSArray *separated = [fileName componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[separated firstObject] ofType:[separated lastObject]];
    return filePath;
}



@end

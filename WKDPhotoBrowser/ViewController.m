//
//  ViewController.m
//  WKDPhotoBrowser
//
//  Created by zm on 2018/1/1.
//  Copyright © 2018年 zm. All rights reserved.
//

#import "ViewController.h"
#import "WKDPhotoBrowserViewController.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,WKDPhotoBrowserDelegate,NSURLSessionDelegate>{
    NSURLSession *_session;
    NSMutableDictionary *_downloadCache;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *thumbImages;
@property (nonatomic, strong) WKDPhotoBrowserViewController *wkdPhotoBrowser;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    _downloadCache = [NSMutableDictionary new];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionView *)collectionView{
    if(!_collectionView){
        CGFloat width = CGRectGetWidth(self.view.frame);
        CGFloat height = CGRectGetHeight(self.view.frame);
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake((width-10)/2, 200);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, height) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
    }
    return _collectionView;
}

- (NSMutableArray *)images{
    if(!_images){
        _images = @[@"http://image15-c.poco.cn/mypoco/myphoto/20131110/20/5242736920131110201542020_640.jpg",
                    @"http://d.hiphotos.baidu.com/image/pic/item/8ad4b31c8701a18b5c6410fa9c2f07082938fefc.jpg",
                    @"http://b.hiphotos.baidu.com/image/pic/item/4bed2e738bd4b31c5e7f960e85d6277f9f2ff8c0.jpg",
                    @"http://g.hiphotos.baidu.com/image/pic/item/d50735fae6cd7b8928e0235c0d2442a7d8330e64.jpg",
                    @"http://f.hiphotos.baidu.com/image/pic/item/c75c10385343fbf2978bafe1b27eca8064388f48.jpg",
                    @"http://g.hiphotos.baidu.com/image/pic/item/8601a18b87d6277f103081ff2a381f30e824fcd3.jpg",
                    @"http://e.hiphotos.baidu.com/image/pic/item/b7003af33a87e95039ab96ad12385343faf2b4b6.jpg",
                    @"http://a.hiphotos.baidu.com/image/pic/item/d0c8a786c9177f3ebf1d2bfc72cf3bc79f3d5612.jpg",
                    @"http://a.hiphotos.baidu.com/image/pic/item/9e3df8dcd100baa12d04904a4510b912c8fc2e13.jpg",
                    @"http://b.hiphotos.baidu.com/image/pic/item/7c1ed21b0ef41bd55c7a3f0553da81cb39db3d12.jpg"].mutableCopy;
        [_images addObject:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"]];
    }
    return _images;
}

- (NSMutableArray *)thumbImages{
    if(!_thumbImages){
        _thumbImages = [NSMutableArray new];
        for(int i = 0;i<10;i++){
            NSString *imageName = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%ld",(long)i] ofType:@"jpg"];
            UIImage *image = [UIImage imageWithContentsOfFile:imageName];
            [_thumbImages addObject:image];
        }
        [_thumbImages addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video_thumb" ofType:@"png"]]];
    }
    return _thumbImages;
}

- (WKDPhotoBrowserViewController *)wkdPhotoBrowser{
    if(!_wkdPhotoBrowser){
        _wkdPhotoBrowser = [[WKDPhotoBrowserViewController alloc] initWithDelegate:self];
        _wkdPhotoBrowser.isShowPhotoPicker = YES;
    }
    return _wkdPhotoBrowser;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectior{
    return [self.thumbImages count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
  
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.thumbImages[indexPath.row]];
    imageView.frame = CGRectMake(0, 0, CGRectGetWidth(cell.frame), CGRectGetHeight(cell.frame));
    [cell.contentView addSubview:imageView];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.wkdPhotoBrowser setCurrentPhotoIndex:indexPath.row];
    [self.navigationController pushViewController:self.wkdPhotoBrowser animated:YES];
}

#pragma mark - WKDPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(WKDPhotoBrowserViewController *)photoBrowser{
    return self.thumbImages.count;
}
- (WKDPhoto *)photoBrowser:(WKDPhotoBrowserViewController *)photoBrowser photoAtIndex:(NSUInteger)index{
    if(index == 10){
        WKDPhoto *photo = [[WKDPhoto alloc] initWithVideoUrl:[NSURL fileURLWithPath:self.images[index]] thumbImage:self.thumbImages[index]];
        return photo;
    }
    
    WKDPhoto *photo = [[WKDPhoto alloc] initWithImageUrl:[NSURL URLWithString:self.images[index]] thumbImage:self.thumbImages[index]];
    return photo;
}

- (void)downloadOriginPhotoInPhotoBrowser:(WKDPhotoBrowserViewController *)photoBrowser originPhotoAtIndex:(NSUInteger)index{
    NSURLSessionDownloadTask *task = [_session downloadTaskWithURL:[NSURL URLWithString:self.images[index]]];
    [task resume];
    _downloadCache[@(task.taskIdentifier)] = @(index);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSUInteger index = [_downloadCache[@(downloadTask.taskIdentifier)] integerValue];
    NSLog(@"下载完成:%lu",(unsigned long)index);
    NSData *imageData = [NSData dataWithContentsOfURL:location];
    NSArray* pathes = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) ;
    NSString *filePath = [pathes[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.jpg",(unsigned long)index]];
   BOOL isWrite =  [imageData writeToFile:filePath atomically:YES];
    if(isWrite){
        [self.images replaceObjectAtIndex:index withObject:filePath];
        [self.wkdPhotoBrowser reloadDataAtIndex:index];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    NSUInteger index = [_downloadCache[@(downloadTask.taskIdentifier)] integerValue];
    [self.wkdPhotoBrowser updateLoadingView:index progress:progress];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    if(error){
        NSUInteger index = [_downloadCache[@(task.taskIdentifier)] integerValue];
        [self.wkdPhotoBrowser removeLoadingView:index];
    }
}


@end

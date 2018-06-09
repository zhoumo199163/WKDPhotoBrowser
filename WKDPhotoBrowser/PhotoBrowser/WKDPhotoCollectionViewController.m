//
//  WKDPhotoCollectionViewController.m
//  WKDPhotoBrowser
//
//  Created by 周末 on 2018/5/29.
//  Copyright © 2018年 zm. All rights reserved.
//

#import "WKDPhotoCollectionViewController.h"
#import "WKDPhotoBrowserViewController.h"
#import "WKDPhotoHandler.h"
#import "WKDRequestHandler.h"

@interface WKDPhotoCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,WKDPhotoBrowserDelegate,WKDPhotoBrowserDataSource>{
    NSIndexPath *_currentSelectedIndexPath;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation WKDPhotoCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get
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


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectior{
    return [[WKDPhotoHandler sharedInstance] count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSArray <WKDPhoto *> *photos = [WKDPhotoHandler sharedInstance].getAllPhotos;
    WKDPhoto *photo = photos[indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:photo.image];
    imageView.frame = CGRectMake(0, 0, CGRectGetWidth(cell.frame), CGRectGetHeight(cell.frame));
    [cell.contentView addSubview:imageView];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _currentSelectedIndexPath = indexPath;
    WKDPhotoBrowserViewController *wkdPhotoBrowser = [[WKDPhotoBrowserViewController alloc]  init];
    wkdPhotoBrowser.isShowPhotoPicker = YES;
    wkdPhotoBrowser.dataSource = self;
    wkdPhotoBrowser.delegate = self;
    [wkdPhotoBrowser setCurrentPhotoIndex:indexPath.row];
    self.navigationController.delegate = wkdPhotoBrowser;
    [self.navigationController pushViewController:wkdPhotoBrowser animated:YES];
}

#pragma mark - WKDPhotoBrowserDataSource
- (UIView *)didSelectedViewFromSuperClassToPhotoBrowser:(WKDPhotoBrowserViewController *)photoBrowser atIndex:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.contentView;
}

- (NSInteger)numberOfPhotoBrowser:(WKDPhotoBrowserViewController *)photoBrowser{
    return [[WKDPhotoHandler sharedInstance] count];
}

- (WKDPhoto *)photoBrowser:(WKDPhotoBrowserViewController *)photoBrowser photoAtIndex:(NSInteger)index{
    NSArray <WKDPhoto *> *photos = [WKDPhotoHandler sharedInstance].getAllPhotos;
    WKDPhoto *photo = photos[index];
    return photo;
}

#pragma mark - WKDPhotoBrowserDelegate
- (void)downloadOriginPhotoInPhotoBrowser:(WKDPhotoBrowserViewController *)photoBrowser originPhotoAtIndex:(NSUInteger)index{
    NSArray <WKDPhoto *> *photos = photoBrowser.photos;
    WKDPhoto *photo = photos[index];
    
    WKDRequestHandler *requestHandler = [WKDRequestHandler  sharedInstance];
    [requestHandler downloadTaskWithURL:photo.downloadUrl completeBlock:^(BOOL isComplete, float progress, NSURL *downloadFilePath, NSError *error) {
        if(isComplete && downloadFilePath){
            // 下载完成
            [[WKDPhotoHandler sharedInstance] downloadCompleteUpdatePhotoLocalPath:downloadFilePath atIndex:index];
             [[NSNotificationCenter defaultCenter] postNotificationName:kWKDPhotoBrowserReloadNotification object:nil userInfo:@{@"index":@(index)}];
        }
        if(error && isComplete){
            // 下载错误
             [[NSNotificationCenter defaultCenter] postNotificationName:kWKDPhotoBrowsweDownloadErrorNotification object:nil userInfo:@{@"index":@(index)}];
        }
        
        if(!isComplete && progress){
            // 下载进度
            [[NSNotificationCenter defaultCenter] postNotificationName:kWKDPhotoBrowserUpdateDownloadProgressNotification object:nil userInfo:@{@"index":@(index),@"progress":@(progress)}];
        }
    }];
}


@end

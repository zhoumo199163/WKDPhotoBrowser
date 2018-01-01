//
//  WKDPhotoPickerViewController.m
//  WKDPhotoBrowser
//
//  Created by zm on 2017/11/5.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "WKDPhotoPickerViewController.h"
#import "WKDPhotoCollectionCell.h"
#import "WKDPhotoBrowserViewController.h"
#import "WKDPhotoCollectionFlowLayout.h"

static NSString * WKDPhotoCell = @"WKDPhotoCollectionCell";
static NSString * WKDPhotoCollectionHeader = @"WKDPhotoCollectionHeader";
static CGFloat itemMargin = 3;
static NSInteger columnNumber = 4;

@interface WKDPhotoPickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *toolView;

@property (nonatomic, strong) NSArray <WKDPhoto *>*photos;
@property (nonatomic) WKDPhotoOptionalStatus photoOptionalStatus;
@property (nonatomic, strong) NSMutableArray <WKDPhoto *> *selectedPhotos;

@property (nonatomic, strong) NSArray <NSString *> *sectionTitles;
@property (nonatomic, strong) NSDictionary <NSString *,NSArray *> *sectionPhotos;

@property (nonatomic, strong) WKDPhotoBrowserViewController *photoBrowser;
@end

@implementation WKDPhotoPickerViewController

- (instancetype) initWithPhotos:(NSArray<WKDPhoto *> *)photos{
    self = [super init];
    if(self){
        _photos = [photos copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:44/255.0 green:50/255.0 blue:50/255.0 alpha:1.0]];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.toolView];
    self.selectedPhotos = [NSMutableArray new];
    
    [self.navigationController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[WKDPhotoBrowserViewController class]]){
            WKDPhotoBrowserViewController * controller = (WKDPhotoBrowserViewController *)obj;
            _photoBrowser = controller;
            *stop = YES;
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"图片及视频";
    [self updateNavigation];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.toolView.frame));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"%@---dealloc",self);
}

- (void)updateNavigation{
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:@"选择" forState:UIControlStateNormal];
    [rightButton setTitle:@"取消" forState:UIControlStateSelected];
    [rightButton addTarget:self action:@selector(choosePhotos:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    rightButton.selected = _photoOptionalStatus;
}

#pragma mark - Actions
- (void)choosePhotos:(UIButton *)sender{
    BOOL isSelect = sender.selected;
    _photoOptionalStatus = !isSelect;
    sender.selected = !isSelect;
    [self.collectionView reloadData];
    
    if(_photoOptionalStatus){
        [UIView animateWithDuration:0.2 animations:^{
            CGRect toolFrame = self.toolView.frame;
            CGFloat y= CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.toolView.frame);
            [self.toolView setFrame:CGRectMake(0, y, CGRectGetWidth(toolFrame), CGRectGetHeight(toolFrame))];
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            CGRect toolFrame = self.toolView.frame;
            [self.toolView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(toolFrame), CGRectGetHeight(toolFrame))];
        }];
    }
    self.collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.toolView.frame));
}

- (void)transmitPhotoAction:(UIButton *)sender{
    if(_photoBrowser.delegate && [_photoBrowser.delegate respondsToSelector:@selector(transmitPhotoInPhotoPicker:transmitPhotoAtIndex:)]){
        [self.selectedPhotos enumerateObjectsUsingBlock:^(WKDPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger index = [self.photos indexOfObject:obj];
            [_photoBrowser.delegate transmitPhotoInPhotoPicker:self transmitPhotoAtIndex:index];
        }];
    }
}

- (void)downloadPhotoAction:(UIButton *)sender{
    if(_photoBrowser.delegate && [_photoBrowser.delegate respondsToSelector:@selector(downloadOriginPhotoInPhotoBrowser:originPhotoAtIndex:)]){
        [self.selectedPhotos enumerateObjectsUsingBlock:^(WKDPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj.photoImageType == WKDPhotoImageTypeThumb){
                NSInteger index = [self.photos indexOfObject:obj];
                [_photoBrowser.delegate downloadOriginPhotoInPhotoBrowser:_photoBrowser originPhotoAtIndex:index];
            }
        }];
    }
}

- (void)backAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - lazy
- (UICollectionView *)collectionView{
    if(!_collectionView){
        WKDPhotoCollectionFlowLayout *layout = [[WKDPhotoCollectionFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor colorWithRed:44/255.0 green:50/255.0 blue:50/255.0 alpha:1.0]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceHorizontal = NO;
        [_collectionView registerClass:[WKDPhotoCollectionCell class] forCellWithReuseIdentifier:WKDPhotoCell];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:WKDPhotoCollectionHeader];
    }
    return _collectionView;
}

- (NSArray <NSString *> *)sectionTitles{
    if(!_sectionTitles){
        NSMutableArray *sections = [NSMutableArray new];
        NSMutableDictionary *sectionDic = [NSMutableDictionary new];
        __block NSString *dateString;
        [self.photos enumerateObjectsUsingBlock:^(WKDPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDate *date = obj.photoDate;
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents  *components  =  [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:[NSDate date]];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"WDKWKD"];
            NSInteger year=[[formatter stringFromDate:date] integerValue];
            [formatter setDateFormat:@"MM"];
            NSInteger month=[[formatter stringFromDate:date]integerValue];
            
            if(year == components.year && month == components.month){
                dateString = @"这个月";
            }else if(year== 0 && month == 0){
                dateString = @"其他";
            }else{
                 dateString = [NSString stringWithFormat:@"%ld年%ld月",(long)year,(long)month];
            }
            if(dateString){
            NSMutableArray *photos =sectionDic[dateString];
            if(!photos){
                photos = [NSMutableArray new];
                [sections addObject:dateString];
            }
            [photos addObject:obj];
            sectionDic[dateString] = photos;
            }
        }];
        
        self.sectionPhotos = [sectionDic copy];
        _sectionTitles = [sections copy];
    }
    return _sectionTitles;
}

- (UIView *)toolView{
    if(!_toolView){
        CGRect bounds = self.view.bounds;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), 50)];
        [view setBackgroundColor:[UIColor colorWithRed:28/255.0 green:29/255.0 blue:30/255.0 alpha:0.8]];
        UIButton *transmit = [UIButton buttonWithType:UIButtonTypeCustom];
        [transmit setImage:[UIImage imageNamed:@"transmit.png"] forState:UIControlStateNormal];
        [transmit addTarget:self action:@selector(transmitPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        [transmit setFrame:CGRectMake(CGRectGetWidth(bounds)/4, 10, 25, 25)];
        [view addSubview:transmit];
        
        UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
        [download setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
        [download addTarget:self action:@selector(downloadPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        [download setFrame:CGRectMake(CGRectGetWidth(bounds)/4*3, 10, 25, 25)];
        [view addSubview:download];
        _toolView = view;
    }
    return _toolView;
}

#pragma mark - UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WKDPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WKDPhotoCell forIndexPath:indexPath];
    NSString *title = self.sectionTitles[indexPath.section];
    NSArray *photos = self.sectionPhotos[title];
    
    WKDPhoto *photo = photos[indexPath.row];
    cell.cellOptionalStatus = _photoOptionalStatus;
    __weak __typeof(self) weakSelf = self;
    cell.selectedPhotoBlock = ^(BOOL isSelected, WKDPhoto *photo) {
        __strong __typeof(weakSelf) self = weakSelf;
        if(isSelected){
            [self.selectedPhotos addObject:photo];
        }else{
            [self.selectedPhotos removeObject:photo];
        }
    };
    cell.isSelected = NO;
    [self.selectedPhotos enumerateObjectsUsingBlock:^(WKDPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj == photo){
            cell.isSelected = YES;
            *stop = YES;
        }
    }];
    cell.photo = photo;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *key = self.sectionTitles[section];
    NSArray *values = self.sectionPhotos[key];
    return values.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.sectionTitles.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if(kind == UICollectionElementKindSectionHeader && self.sectionTitles.count){
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:WKDPhotoCollectionHeader forIndexPath:indexPath];
        if(headerView.subviews.count == 0){
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, CGRectGetWidth(collectionView.frame), 20)];
            [label setTextColor:[UIColor whiteColor]];
            [headerView setBackgroundColor:[UIColor colorWithRed:28/255.0 green:29/255.0 blue:30/255.0 alpha:0.8]];
            [headerView addSubview:label];
        }
        UILabel *label = headerView.subviews[0];
        label.text = self.sectionTitles[indexPath.section];
        return headerView;
    }
    return nil;
}


#pragma mark - UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat itemWith =(collectionView.frame.size.width- itemMargin*(columnNumber+1))/columnNumber;
    CGSize size = CGSizeMake(floorf(itemWith),floorf(itemWith));
    return size;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return  UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);//分别为上、左、下、右
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return itemMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return itemMargin;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(collectionView.frame.size.width, 30);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [_photoBrowser removeFromParentViewController];
    _photoBrowser.isShowPhotoPicker = NO;
    NSString *key = self.sectionTitles[indexPath.section];
    NSArray *values = self.sectionPhotos[key];
    WKDPhoto *photo = values[indexPath.row];
    NSInteger index = [self.photos indexOfObject:photo];
    [_photoBrowser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:_photoBrowser animated:YES];

}

@end

//
//  WKDPhotoCollectionCell.m
//  WKDPhotoBrowser
//
//  Created by zm on 2017/11/5.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "WKDPhotoCollectionCell.h"

static CGFloat VideoMarkView_LeftMargin = 8;
static CGFloat VideoMarkView_Width = 20;
static CGFloat VideoMarkView_height = 15;
static CGFloat SelectButton_Width = 35;

@interface WKDPhotoCollectionCell ()
@property (nonatomic, strong) UIImageView *photoView;
// Only Video
@property (nonatomic, strong) UIImageView *videoMarkView;
@property (nonatomic, strong) UILabel *videoDurationLabel;

@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation WKDPhotoCollectionCell
- (void)setPhoto:(WKDPhoto *)photo{
    _photo = photo;
    self.photoView.image = photo.image;
    self.videoDurationLabel.text = photo.videoDuration;
    
    if(_photo.photoType == WKDPhotoTypeVideo){
        [self.videoMarkView setHidden:NO];
        [self.videoDurationLabel setHidden:NO];
    }else{
         [self.videoMarkView setHidden:YES];
         [self.videoDurationLabel setHidden:YES];
    }
    if(_cellOptionalStatus == WKDPhotoOptionalStatusSelect){
        [self.selectButton setHidden:NO];
    }else if(_cellOptionalStatus == WKDPhotoOptionalStatusNomal){
        [self.selectButton setHidden:YES];
    }
    
    [self.selectButton setSelected:_isSelected];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.contentView addSubview:self.photoView];
    [self.contentView addSubview:self.videoMarkView];
    [self.contentView addSubview:self.videoDurationLabel];
    [self.contentView addSubview:self.selectButton];
    
    self.photoView.frame = self.bounds;
    self.videoMarkView.frame = CGRectMake(VideoMarkView_LeftMargin, self.bounds.size.height - VideoMarkView_LeftMargin-VideoMarkView_height, VideoMarkView_Width, VideoMarkView_height);
    self.videoDurationLabel.frame = CGRectMake(CGRectGetMaxX(self.videoMarkView.frame) + VideoMarkView_LeftMargin, CGRectGetMinY(self.videoMarkView.frame), self.bounds.size.width - CGRectGetMaxX(self.videoMarkView.frame) - VideoMarkView_LeftMargin, VideoMarkView_height);
    self.selectButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - SelectButton_Width, 0, SelectButton_Width, SelectButton_Width);
   
}

- (UIImageView *)photoView{
    if(!_photoView){
        _photoView = [[UIImageView alloc] initWithImage:_photo.image];
         _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
    }
    return _photoView;
}

- (UIImageView *)videoMarkView{
    if(!_videoMarkView){
        _videoMarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoMark.png"]];
    }
    return _videoMarkView;
}

- (UILabel *)videoDurationLabel{
    if(!_videoDurationLabel){
        _videoDurationLabel = [[UILabel alloc] init];
        _videoDurationLabel.text = _photo.videoDuration;
        [_videoDurationLabel setTextColor:[UIColor whiteColor]];
        [_videoDurationLabel setFont:[UIFont systemFontOfSize:12]];
    }
    return _videoDurationLabel;
}

- (UIButton *)selectButton{
    if(!_selectButton){
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"selectPhoto_nomal.png"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"selectPhoto_select.png"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectSomePhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (void)selectSomePhoto:(UIButton *)sender{
    sender.selected = !sender.selected;
    if(self.selectedPhotoBlock){
        self.selectedPhotoBlock(sender.selected, self.photo);
    }
}

- (void)dealloc{
    NSLog(@"%@---dealloc",self);
}
@end

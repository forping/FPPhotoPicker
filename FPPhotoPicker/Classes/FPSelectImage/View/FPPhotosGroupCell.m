//
//  FPPhotosGroupCell.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/7.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosGroupCell.h"
#import "NSBundle+FPPhotos.h"
#import <Masonry/Masonry.h>


@implementation FPPhotosGroupCell


@synthesize imageView = _imageView,titleLabel = _titleLabel;


-(void)dealloc
{
#ifdef RITLDebug
    //    NSLog(@"YPPhotoGroupCell Dealloc");
#endif
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    _imageView.image = nil;
    _titleLabel.text = @"";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self photoGroupCellWillLoad];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    [self photoGroupCellWillLoad];
}

- (void)photoGroupCellWillLoad
{
    [self addSubImageView];
    [self addSubTitleLabel];
    [self addSubArrowImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark - AddSubviews

- (void)addSubImageView
{
    _imageView = [[UIImageView alloc]init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = true;
    
    [self.contentView addSubview:_imageView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.leading.mas_equalTo(10);
        make.width.equalTo(self.imageView.mas_height);
        
    }];
}


- (void)addSubTitleLabel
{
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.imageView.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        
    }];
    
}

- (void)addSubArrowImageView
{
    _arrowImageView = [[UIImageView alloc]init];
    _arrowImageView.image = /*RITLGroupTableViewControllerRightArrowImageName.ritl_image*/NSBundle.fp_arrow_right;
    
    [self.contentView addSubview:_arrowImageView];
    
    [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.inset(15);
        make.centerY.offset(0);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
}
@end

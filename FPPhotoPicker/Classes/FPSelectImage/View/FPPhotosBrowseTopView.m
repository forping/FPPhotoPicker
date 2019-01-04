//
//  FPPhotosBrowseTopView.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/12.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosBrowseTopView.h"
#import "FPUnility.h"
#import "NSBundle+FPPhotos.h"
#import <Masonry/Masonry.h>

@implementation FPPhotosBrowseTopView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        self.backButton = ({
            
            UIButton *view = [UIButton new];
            view.adjustsImageWhenHighlighted = false;
            view.backgroundColor = [UIColor clearColor];
            view.imageEdgeInsets = UIEdgeInsetsMake(13, 5, 5, 23);
            [view setImage:NSBundle.fp_browse_back/*@"FPPhotos.bundle/FP_browse_back".FP_image*/ forState:UIControlStateNormal];
            view;
        });
        
        self.statusButton = ({
            
            UIButton *view = [UIButton new];
            view.adjustsImageWhenHighlighted = false;
            view.backgroundColor = [UIColor clearColor];
            view.imageEdgeInsets = UIEdgeInsetsMake(10, 11, 0, 0);
            [view setImage:NSBundle.fp_brower_selected/*@"FPPhotos.bundle/FP_brower_selected".FP_image*/ forState:UIControlStateNormal];
            view;
        });
        
        self.indexLabel = ({
            
            UILabel *label = [UILabel new];
            label.backgroundColor = FPColorFromIntRBG(9, 187, 7);
            label.text = @"0";
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = UIColor.whiteColor;
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.cornerRadius = 30 / 2.0;
            label.layer.masksToBounds = true;
            label.hidden = true;
            label;
        });
        
        [self addSubview:self.backButton];
        [self addSubview:self.statusButton];
        [self addSubview:self.indexLabel];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.offset(15);
            make.width.height.mas_equalTo(40);
            make.bottom.inset(10);
        }];
        
        [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.inset(15);
            make.width.height.mas_equalTo(40);
            make.bottom.inset(10);
        }];
        
        [self.indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.height.mas_equalTo(30);
            make.bottom.inset(10);
            make.right.inset(15);
        }];
        
        
    }
    return self;
}

@end

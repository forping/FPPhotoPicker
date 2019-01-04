//
//  FPPhotosBottomView.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosBottomView.h"

#import <Masonry/Masonry.h>
#import "NSBundle+FPPhotos.h"
#import "UIImage+AIRendleModel.h"
#import "FPUnility.h"

@implementation FPPhotosBottomView


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self buildViews];
    }
    return self;
}


- (void)buildViews
{
    self.contentView = ({
        
        UIView *view = [UIView new];
        view.backgroundColor = UIColor.clearColor;
        
        view;
    });
    
    self.previewButton = ({
        
        UIButton *view = [UIButton new];
        view.adjustsImageWhenHighlighted = false;
        view.backgroundColor = [UIColor clearColor];
        view.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [view setTitle:NSLocalizedString(@"预览", @"") forState:UIControlStateNormal];
        [view setTitle:NSLocalizedString(@"预览", @"") forState:UIControlStateDisabled];
        
        [view setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [view setTitleColor:FPColorFromIntRBG(105, 109, 113) forState:UIControlStateDisabled];
        
        view;
    });
    
    self.fullImageButton = ({
        
        UIButton *view = [UIButton new];
        
        view.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 40);
        view.titleEdgeInsets = UIEdgeInsetsMake(0, -60, 0, 0);
        
        [view setImage:NSBundle.fp_bottomUnselected forState:UIControlStateNormal];
        [view setImage:NSBundle.fp_bottomSelected forState:UIControlStateSelected];
        
        view.titleLabel.font = [UIFont systemFontOfSize:14];
        [view setTitle:NSLocalizedString(@"原图", @"") forState:UIControlStateNormal];
        [view setTitle:NSLocalizedString(@"原图", @"") forState:UIControlStateSelected];
        
        [view setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        
        view;
    });
    
    self.sendButton = ({
        
        UIButton *view = [UIButton new];
        view.adjustsImageWhenHighlighted = false;
        
        view.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        
        [view setTitle:NSLocalizedString(@"发送", @"") forState:UIControlStateNormal];
        [view setTitle:NSLocalizedString(@"发送", @"") forState:UIControlStateDisabled];
        
        [view setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [view setTitleColor:FPColorFromIntRBG(92, 134, 90) forState:UIControlStateDisabled];
        
        [view setBackgroundImage:[UIImage colorImage:FPColorFromIntRBG(9, 187, 7)] forState:UIControlStateNormal];
        [view setBackgroundImage:[UIImage colorImage:FPColorFromIntRBG(23, 83, 23)] forState:UIControlStateDisabled];
        
        view.layer.cornerRadius = 5;
        view.clipsToBounds = true;
        
        view;
    });
    
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.previewButton];
    [self.contentView addSubview:self.fullImageButton];
    [self.contentView addSubview:self.sendButton];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.offset(0);
        make.height.mas_equalTo(FP_NormalTabBarHeight - 5);
        
    }];
    
    [self.previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.offset(0);
        make.left.offset(10);
        make.width.mas_equalTo(40);
    }];
    
    [self.fullImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.offset(0);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(60);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.offset(0);
        make.right.inset(10);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(30);
    }];
}

@end

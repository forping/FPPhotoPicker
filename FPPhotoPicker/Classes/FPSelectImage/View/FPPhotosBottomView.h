//
//  FPPhotosBottomView.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotosBottomView : UIView

///
@property (nonatomic, strong) UIView *contentView;
/// 预览按钮
@property (nonatomic, strong) UIButton *previewButton;
/// 原图按钮
@property (nonatomic, strong) UIButton *fullImageButton;
/// 发送按钮
@property (nonatomic, strong) UIButton *sendButton;


@end

NS_ASSUME_NONNULL_END

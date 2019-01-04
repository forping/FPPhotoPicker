//
//  FPPhotosBrowseTopView.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/12.
//  Copyright © 2018 forping. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotosBrowseTopView : UIView
/// 返回的按钮
@property (nonatomic, strong) UIButton *backButton;
/// 状态按钮
@property (nonatomic, strong) UIButton *statusButton;
/// 显示索引的标签
@property (strong, nonatomic) UILabel *indexLabel;
@end

NS_ASSUME_NONNULL_END

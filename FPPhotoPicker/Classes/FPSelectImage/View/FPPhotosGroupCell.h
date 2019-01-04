//
//  FPPhotosGroupCell.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/7.
//  Copyright © 2018 forping. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotosGroupCell : UITableViewCell


/// 显示图片的imageView
@property (strong, nonatomic) UIImageView * imageView;

/// 分组的名称
@property (strong, nonatomic) UILabel * titleLabel;

///
@property (strong, nonatomic) UIImageView * arrowImageView;



@end

NS_ASSUME_NONNULL_END

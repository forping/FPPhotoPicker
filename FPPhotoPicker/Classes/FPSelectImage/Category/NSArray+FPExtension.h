//
//  NSArray+FPExtension.h
//  EattaClient
//
//  Created by forping on 2017/6/22.
//  Copyright © 2017年 forping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN


/// 泛型数组使用
@interface NSArray<__covariant ObjectType> (FPExtension)

/// 数组转换的map函数
- (NSArray *)fp_detailMap:(id(^)(ObjectType obj,NSInteger index))mapHandler;
- (NSArray *)fp_map:(id(^)(ObjectType obj))mapHander;


/// 数组过滤器的filter函数
- (NSArray *)fp_detailFilter:(BOOL(^)(ObjectType obj,NSInteger index))filterHandler;
- (NSArray *)fp_filter:(BOOL(^)(ObjectType obj))filterHandler;


/// 数组变换的reduce函数
- (NSArray *)fp_detailReduce:(NSArray *)initial
                reduceHandler:(NSArray *(^)(NSArray *result,id obj,NSInteger index))reduceHandler;
- (NSArray *)fp_reduce:(NSArray *)initial
          reduceHandler:(NSArray *(^)(NSArray *result,id obj))reduceHandler;


/// 逆序数组
- (NSArray <ObjectType> *)fp_revert;


@property (nonatomic, strong, nullable, readonly)ObjectType fp_safeFirstObject;

/// 获得object的方法
- (nullable ObjectType)fp_safeObjectAtIndex:(NSInteger)index;
/// 获得逆序的方法
- (nullable ObjectType)fp_revertObjectAtIndex:(NSInteger)index;

@end




NS_ASSUME_NONNULL_END

//
//  FPUnility.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/6.
//  Copyright © 2018 forping. All rights reserved.
//
// 存放所有的宏

#ifndef FPUnility_h
#define FPUnility_h


#define fp_singleH(name) +(instancetype)share##name;

#define fp_singleM(name) static id _instance;\
+(instancetype)allocWithZone:(struct _NSZone *)zone\
{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [super allocWithZone:zone];\
});\
return _instance;\
}\
\
+(instancetype)share##name\
{\
return [[self alloc]init];\
}\
-(id)copyWithZone:(NSZone *)zone\
{\
return _instance;\
}\
\
-(id)mutableCopyWithZone:(NSZone *)zone\
{\
return _instance;\
}







#define FP_iOS_Version_GreaterThan(x) (UIDevice.currentDevice.systemVersion.floatValue > x)

#define FP_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define FP_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// XSMAX  414*896  XS  375*812  XR 414*896 X:375*812
#define FP_IS_IPHONEX ((FP_SCREEN_WIDTH == 375) && (FP_SCREEN_HEIGHT == 812))
#define FP_IS_IPHONEXR ((FP_SCREEN_WIDTH == 414) && (FP_SCREEN_HEIGHT == 896))
#define FP_IS_IPHONEXS FP_IS_IPHONEX
#define FP_IS_IPHONEXS_MAX FP_IS_IPHONEXR
#define FP_HAVE_PHONE_HEADER (FP_IS_IPHONEX || FP_IS_IPHONEXR || FP_IS_IPHONEXS || FP_IS_IPHONEXS_MAX)
#define FP_iPhoneX FP_HAVE_PHONE_HEADER //为了适配之前的，建议进行判定使用上面方法

#define FP_NormalNavigationBarHeight (64)
#define FP_iPhoneXNavigationBarHeight (88)
#define FP_NormalTabBarHeight (49)
#define FP_iPhoneXTabBarHeight (83)
#define FP_DefaultTabBarHeight (FP_iPhoneX ? FP_iPhoneXTabBarHeight : FP_NormalTabBarHeight)
#define FP_DefaultNaviBarHeight (FP_iPhoneX ? FP_iPhoneXNavigationBarHeight : FP_NormalNavigationBarHeight)

#define FPRGBACOLOR(r,g,b,a)\
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define FPColorFromIntRBG(RED, GREEN, BLUE) FPRGBACOLOR(RED,GREEN,BLUE,1.0)

// RGB颜色转换
#define FPColorSimpleFromIntRBG(x) (FPColorFromIntRBG((x),(x),(x)))



#endif /* FPUnility_h */

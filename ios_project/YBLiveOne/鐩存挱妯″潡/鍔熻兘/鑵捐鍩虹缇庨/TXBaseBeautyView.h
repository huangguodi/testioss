//
//  TXBaseBeautyView.h
//  YBVideo
//
//  Created by YB007 on 2019/12/13.
//  Copyright © 2019 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TXBeautyBlock)(NSString *eventStr,float value,NSString *filterName);


typedef NS_ENUM(NSInteger,TCLVFilterType) {
    FilterType_None         = 0,
    FilterType_white        ,   //美白滤镜
    FilterType_langman         ,   //浪漫滤镜
    FilterType_qingxin         ,   //清新滤镜
    FilterType_weimei         ,   //唯美滤镜
    FilterType_fennen         ,   //粉嫩滤镜
    FilterType_huaijiu         ,   //怀旧滤镜
    FilterType_landiao         ,   //蓝调滤镜
    FilterType_qingliang     ,   //清凉滤镜
    FilterType_rixi         ,   //日系滤镜
};

@interface TXBaseBeautyView : UIView

+(void)saveBaseBeautyValue:(CGFloat)value;
+(CGFloat)getBaseBeautyValue;

+(void)saveBaseWhiteValue:(CGFloat)value;
+(CGFloat)getBaseWhiteValue;

+(void)saveFilterIndex:(NSInteger)value;
+(NSInteger)getFilterIndex;

+(instancetype)showBaseBeauty:(TXBeautyBlock)complete;



@end



//
//  UIImage+RKCircleImg.h
//  YBVideo
//
//  Created by YB007 on 2019/12/1.
//  Copyright © 2019 cat. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIImage (RKCircleImg)

/**
 * 返回圆形图片
 */
- (instancetype)rk_circleImage;
 
/**
 * 通过图片名，返回圆形图片
 */
+ (instancetype)rk_circleImageWith:(NSString *)name;

@end



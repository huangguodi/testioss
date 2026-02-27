//
//  UIImage+RKCircleImg.m
//  YBVideo
//
//  Created by YB007 on 2019/12/1.
//  Copyright © 2019 cat. All rights reserved.
//

#import "UIImage+RKCircleImg.h"


@implementation UIImage (RKCircleImg)


- (instancetype)rk_circleImage {
    //开启图形上下文
    UIGraphicsBeginImageContext(self.size);
    //上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //添加一个圆
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextAddEllipseInRect(ctx, rect);
    //裁剪
    CGContextClip(ctx);
    //绘制图片
    [self drawInRect:rect];
    //获得图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}
 
+ (instancetype)rk_circleImageWith:(NSString *)name {
    return [[self imageNamed:name] rk_circleImage];
}


@end

//
//  YBLookPicVView.h
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/4.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^YBLookPicVViewBlock)(int code);
@interface YBLookPicVView : UIView
@property(nonatomic,copy)YBLookPicVViewBlock block;
- (instancetype)init:(NSArray *)toparray andindex:(NSInteger)currentindex;
@end

NS_ASSUME_NONNULL_END

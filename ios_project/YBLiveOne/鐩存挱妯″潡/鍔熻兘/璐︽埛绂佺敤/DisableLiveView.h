//
//  DisableLiveView.h
//  YBLive
//
//  Created by ybRRR on 2022/3/7.
//  Copyright © 2022 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^disableBtnEvent)(NSString *btntitle,NSString *banruleidStr);
@interface DisableLiveView : UIView

@property (nonatomic, copy)disableBtnEvent btnEvent;
@end


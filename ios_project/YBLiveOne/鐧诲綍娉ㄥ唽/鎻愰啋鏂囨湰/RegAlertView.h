//
//  RegAlertView.h
//  yunbaolive
//
//  Created by YB007 on 2020/4/29.
//  Copyright © 2020 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <YYText/YYLabel.h>
#import <YYText/NSAttributedString+YYText.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RegAlertBlock)(int code);

@interface RegAlertView : UIView


@property(nonatomic,copy)RegAlertBlock regAlertEvent;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *titleL;

@property (weak, nonatomic) IBOutlet YYLabel *contentL;

+(instancetype)showRegAler:(NSDictionary *)dataDic complete:(RegAlertBlock)complete;

@end

NS_ASSUME_NONNULL_END

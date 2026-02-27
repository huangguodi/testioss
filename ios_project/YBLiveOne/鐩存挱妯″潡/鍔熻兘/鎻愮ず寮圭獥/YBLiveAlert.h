//
//  YBLiveAlert.h
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/6.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <YYText/YYLabel.h>
#import <YYText/NSAttributedString+YYText.h>
#import "UIView+LBExtension.h"

typedef NS_ENUM(NSInteger,AlertFrom) {
    AlertFrom_Default,
    AlertFrom_AppUpdate,        // App更新提示
    AlertFrom_Maintain,         // App维护提示
    AlertFrom_YoungModel,       // 青少年
    
};

typedef void (^YBAlertBlock)(int eventType);//eventType: 0 取消    1 确认

@interface YBLiveAlert : UIView



/// 确认按钮点击禁止销毁弹窗:默认-NO
@property(nonatomic,assign)BOOL forbidSureDismiss;
@property(nonatomic,assign)AlertFrom alertFrom;

@property(nonatomic,copy)YBAlertBlock ybAlertEvent;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeight;

@property (weak, nonatomic) IBOutlet YYLabel *contentL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTop;

@property (weak, nonatomic) IBOutlet UILabel *vLineL;   //竖线

@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;

@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

/**
 *  NSDictionary *contentDic = @{@"title":@"",@"msg":@"",@"left":@"",@"right":@"",@"richImg":@""};
 *  其中 title 为空代表没有标题，left 为空代表只有一个按钮(右边确认按钮),
 *  如果msg中包含 [rich] 字段代表msg是富文本,对应 richImg 就是富文本的图片，获取 [rich] location插入图片(richImg)-->可参考'上热门'支付提示
 */
+(instancetype)showAlertView:(NSDictionary *)contentDic complete:(YBAlertBlock)complete;



@end



//
//  YBAlertView.h
//  yunbaolive
//
//  Created by ybRRR on 2019/12/9.
//  Copyright © 2019 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum _YBAlertStyle{
    
    YBAlertNormal= 0,
    YBAlertPassWord
    
} YBAlertStyle;

typedef void(^YBAlertEvent)(NSString *type,NSString* tipstr);
@interface YBRAlertView : UIView

@property(nonatomic,strong) UIView *bgView;

@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *contentLabel;
@property(nonatomic,strong) UIButton *cancleButton;
@property(nonatomic,strong) UIButton *sureButton;

@property (nonatomic, copy)YBAlertEvent actionEvent;
-(instancetype)initWithTitle:(NSString *)title Msg:(NSString *)msg LeftMsg:(NSString *)leftMsg RightMsg:(NSString *)rightMsg PlaceHodler:(NSString *)text Style:(YBAlertStyle)Style;
@end

NS_ASSUME_NONNULL_END

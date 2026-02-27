//
//  UserForbiddenView.h
//  YBLive
//
//  Created by ybRRR on 2019/11/8.
//  Copyright © 2019 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^forbiddeHideEvent)();

NS_ASSUME_NONNULL_BEGIN

@interface UserForbiddenView : UIView
@property (weak, nonatomic) IBOutlet UILabel *forbiddenInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *forbiddenTimeLb;
@property (weak, nonatomic) IBOutlet UILabel *titlelb;
@property (weak, nonatomic) IBOutlet UILabel *fjLb;
@property (weak, nonatomic) IBOutlet UILabel *fjscLb;
@property (weak, nonatomic) IBOutlet UIButton *zhidaoLb;

@property (nonatomic,copy)forbiddeHideEvent hideSelf;

-(void)setInfoData:(NSDictionary *)infos;
@end

NS_ASSUME_NONNULL_END

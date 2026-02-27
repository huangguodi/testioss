//
//  FullScreenPlayView.h
//  YBLive
//
//  Created by ybRRR on 2021/11/24.
//  Copyright © 2021 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
/***********************  腾讯SDK start ********************/
//腾讯
#import <TXLiteAVSDK_Professional/TXLivePlayListener.h>
#import <TXLiteAVSDK_Professional/TXLivePlayConfig.h>
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>
#import <mach/mach.h>

typedef void(^fullScreenEvent)(NSString *str);
@interface FullScreenPlayView : UIView<TXLivePlayListener>

@property (nonatomic, copy)fullScreenEvent btnEvent;
@property (nonatomic, strong)UIButton *focusBtn;
@property (nonatomic, strong)NSDictionary *playDoc;
-(instancetype)initWithFrame:(CGRect)frame withType:(NSString *)sdkType andPlayDic:(NSDictionary *)playDic;
-(void)setFousBtnHide:(BOOL)ishide;
- (void)onStopVideo;
@end


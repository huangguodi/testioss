//
//  YBLookVideoCell.h
//  YBLiveOne
//
//  Created by ybRRR on 2021/5/6.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>
#import "fenXiangView.h"
#import "videoModel.h"

@protocol lookVideoCallDelegate <NSObject>
-(void)callBtnWithType:(int)callType andModel:(videoModel *)model andUserDic:(NSDictionary *)userDic;
@end

typedef void(^LookVideoEvent)(NSString *titleStr, videoModel *videoModel, NSDictionary *userDic);

@interface YBLookVideoCell : UICollectionViewCell<shareDelegate>
{
    UILabel *titleL;
    UIImageView *iconV;
    UILabel *nameL;
    UIButton *followBtn;
    UIImageView *stateImgV;
    NSArray *onlineArr;
    
    UIButton *callBtn;
    UIButton *giftBtn;
    UIButton *likeBtn;
    UILabel *likesL;
    UILabel *sharesL;
    
    NSDictionary *_userDic;
    fenXiangView *shareView;
    int callType;

}
@property (nonatomic,strong) videoModel *model;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) UIImageView *backImgV;
@property (nonatomic, strong)NSDictionary *modelDic;
@property (nonatomic, strong)UILabel *viewsL;

@property (nonatomic, copy)LookVideoEvent cellBtnEvent;
@property (nonatomic, assign)id<lookVideoCallDelegate>delegate;
@end

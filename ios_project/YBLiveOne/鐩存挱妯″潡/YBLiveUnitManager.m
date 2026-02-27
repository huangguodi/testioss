//
//  YBLiveUnitManager.m
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/11.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "YBLiveUnitManager.h"
#import "YBPlayVC.h"

@interface YBLiveUnitManager()
{
    YBRoomAlertView *_roomAlert;
}
@property(nonatomic,assign)int roomType;
@property(nonatomic,strong)NSString *typeVal;
@property(nonatomic,strong)NSString *typeMsg;

@end

@implementation YBLiveUnitManager

static YBLiveUnitManager *_singleton = nil;

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[super allocWithZone:NULL] init];
    });
    return _singleton;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}


-(void)checkLiving {
    if ([[Config getOwnID] intValue]<=0) {
        [MBProgressHUD showError:YZMsg(@"请重新登录")];
        return;
    }
    if ([YBToolClass checkNull:_liveUid] || [YBToolClass checkNull:_liveStream]) {
        [MBProgressHUD showError:YZMsg(@"缺少信息")];
        return;
    }
    
    WeakSelf;
    NSDictionary *postDic = @{
        @"liveuid":_liveUid,
        @"stream":_liveStream
    };
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"Zlive.checkLive" andParameter:postDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            [weakSelf judgeRoomType:infoDic];
        }else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}

-(void)judgeRoomType:(NSDictionary *)infoDic {
    /**
     type （直播房间类型，0是普通房间，1密码,2是收费房间，3是计时房间）
     type_val（直播房间类型值）
     type_msg（提示话术）
     ispwd（是否为密码房间 0否 1是）
     pwd_val（密码值）
     */
    _roomType = [minstr([infoDic valueForKey:@"type"]) intValue];
    _typeVal = minstr([infoDic valueForKey:@"type_val"]);
    _typeMsg = minstr([infoDic valueForKey:@"type_msg"]);
    
    [self destroyAlertView];
    WeakSelf;
    if(_roomType == 1){
        /// 密码
        _roomAlert = [YBRoomAlertView alertInstanceWithType:Live_User_Room_Pwd];
        [_roomAlert showAlert:NO];
        _roomAlert.alertEvent = ^(LiveEnum event, NSDictionary *eventDic) {
            if(event == Live_Alert_Room_Sure){
                NSLog(@"rk====>密码：%@",eventDic);
                NSString *inputV = minstr([eventDic valueForKey:@"typeVal"]);
                inputV = [[YBToolClass sharedInstance]stringToMD5:inputV];
                // 注意密码是 type_msg
                if(![inputV isEqual:weakSelf.typeMsg]){
                    [MBProgressHUD showError:YZMsg(@"密码错误")];
                }else {
                    [weakSelf canEnterRoom:infoDic];
                }
            }
        };
    }else if (_roomType == 2 || _roomType == 3){
        /// 门票、计时
        _roomAlert = [YBRoomAlertView alertInstanceWithType:Live_User_Room_TxtAlert];
        _roomAlert.extraDic = @{@"tips":_typeMsg};
        [_roomAlert showAlert:NO];
        _roomAlert.alertEvent = ^(LiveEnum event, NSDictionary *eventDic) {
            if(event == Live_Alert_Room_Sure){
                // 确认事件
                [weakSelf payforRoomType:infoDic];
            }
        };
    }else{
        /// 普通
        [self canEnterRoom:infoDic];
    }
}

/// 门票、计时扣费
-(void)payforRoomType:(NSDictionary *)infoDic{
    [self destroyAlertView];
    NSLog(@"rk====>门票、计时扣费");
    NSDictionary *postDic = @{
        @"liveuid":_liveUid,
        @"stream":_liveStream,
    };
    [MBProgressHUD showMessage:@""];
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Zlive.roomCharge" andParameter:postDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if(code == 0){
            NSDictionary *resDic = [info firstObject];
            LiveUser *userObj = [Config myProfile];
            userObj.coin = minstr([resDic valueForKey:@"coin"]);
            [Config saveProfile:userObj];
            NSLog(@"rk====>扣费成功====>%@",[resDic valueForKey:@"coin"]);
            [weakSelf canEnterRoom:infoDic];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
   
}

-(void)destroyAlertView {
    if(_roomAlert){
        [_roomAlert removeFromSuperview];
        _roomAlert = nil;
    }
}

#pragma mark - 进房间
-(void)canEnterRoom:(NSDictionary *)playDic {
    [self destroyAlertView];
    YBPlayVC *pVC = [[YBPlayVC alloc]init];
    pVC.playDic = playDic;
    pVC.currentIndex = _currentIndex?_currentIndex:0;
    pVC.listArray = _listArray?_listArray:@[playDic];
    [[YBAppDelegate sharedAppDelegate]pushViewController:pVC animated:YES];
    
}





@end

//
//  YBLiveSocket.m
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/15.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "YBLiveSocket.h"

#import <SocketIO/SocketIO-Swift.h>
#import "YBSocketName.h"
#import "BanLiveView.h"
#import "YBLiveRTCManager.h"
#import "YBLinkAlertView.h"
#import "YBAnchorPKAlert.h"

@interface YBLiveSocket(){
    NSDictionary *_roomDic;
    NSString *_roomNum;
    NSString *_anchorName;
    BOOL _isBusy;
    BanLiveView *_banView;
    
    int _linkMicAskLast;
    NSTimer *_linkMicAskTimer;                  //连麦请求中倒计时
    NSString *_linkRequestUid;
    
    BOOL _isSend;
}

@property(nonatomic,assign)LiveEnum socketRole;

@property(nonatomic,strong)SocketManager *socketManager;
@property(nonatomic,strong)SocketIOClient *socketClient;
@property(nonatomic,strong)YBLinkAlertView *linkAlertView;
@property(nonatomic,strong)YBAnchorPKAlert *pkAlertView;
@property(nonatomic,assign)BOOL hostLinking;                //主播连麦中【包含用户-主播、主播-主播连麦】

@end

@implementation YBLiveSocket

static YBLiveSocket *_singleton = nil;

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

/** 链接 */
-(void)socketConnectInfo:(NSDictionary *)roomInfo role:(LiveEnum)role; {
    _socketRole = role;
    _roomDic = roomInfo;
    if(role == Live_Socket_Anchor){
        _roomNum = [Config getOwnID];
        _anchorName = [Config getOwnNicename];
        _userType = @"50";
    }else{
        _roomNum = minstr([roomInfo valueForKey:@"uid"]);
        _anchorName = minstr([roomInfo valueForKey:@"user_nickname"]);
    }
    _linkMicAskLast = 10;
    _roomDic = roomInfo;
    _isBusy = NO;
    _isSend = NO;
    NSString *socketUrl = minstr([_roomDic valueForKey:@"chatserver"]);
    NSString *liveStream = minstr([_roomDic valueForKey:@"stream"]);
    _socketManager = [[SocketManager alloc]initWithSocketURL:[NSURL URLWithString:socketUrl] config:@{@"log": @NO, @"compress": @YES}];
    _socketClient = _socketManager.defaultSocket;
    NSArray *cur = @[@{@"username":[Config getOwnNicename],
                       @"uid":[Config getOwnID],
                       @"token":[Config getOwnToken],
                       @"roomnum":_roomNum,
                       @"stream":liveStream,
                       @"lang":[RookieTools serviceLang],
    }];
    [_socketClient connect];
    [_socketClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        [_socketClient emit:@"conn" with:cur];
        NSLog(@"socket链接");
    }];
    
    WeakSelf;
    [_socketClient on:@"conn" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"进入房间");
        if (_isBusy && weakSelf.socketEvent && _socketRole == Live_Socket_Anchor) {
            weakSelf.socketEvent(Live_Socket_CheckLive, @{});
        }
        if(_isBusy == NO){
            [weakSelf socketSendRequestFans];
        }
        _isBusy = YES;
        
        //
        if(_socketRole == Live_Socket_User && !_isSend){
            _isSend = YES;
            weakSelf.socketEvent(Live_Socket_Conn, @{});
        }
    }];
    
    [_socketClient on:@"broadcastingListen" callback:^(NSArray* data, SocketAckEmitter* ack) {
        if([[data[0] firstObject] isEqual:@"stopplay"]) {
            if(weakSelf.socketEvent){
                weakSelf.socketEvent(Live_Socket_SuperClose, @{});
            }
            if(_socketRole == Live_Socket_Anchor){
                //主播端提示被关播原因
                [weakSelf getLiveBanInfo];
            }
            return ;
        }
        
        for (NSString *path in data[0]) {
            NSDictionary *jsonArray = [path JSONValue];
            NSDictionary *msg = [[jsonArray valueForKey:@"msg"] firstObject];
            NSString *retcode = [NSString stringWithFormat:@"%@",[jsonArray valueForKey:@"retcode"]];
            if ([retcode isEqual:@"409002"]) {
                [MBProgressHUD showError:YZMsg(@"你已被禁言")];
                return;
            }
            NSString *method = [msg valueForKey:@"_method_"];
            [weakSelf getmessage:msg andMethod:method];
        }
    }];
    
}
-(void)getLiveBanInfo {
    // 未添加
    /*
    NSDictionary *postDic = @{
        @"uid":[Config getOwnID],
        @"token":[Config getOwnToken],
    };
    [YBToolClass postNetworkWithUrl:@"Zlive.getLiveBanInfo" andParameter:postDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if(code == 0){
            NSDictionary *infoDic = [info firstObject];
            if (_banView) {
                [_banView removeFromSuperview];
                _banView = nil;
            }
            _banView = [[BanLiveView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andInfo:infoDic isWarning:NO];
            [_banView showWindow];
        }else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    */
}

/** 断开 */
-(void)socketDisconnect; {
    [_socketClient disconnect];
    [_socketClient off:@""];
    [_socketClient leaveNamespace];
    _socketClient = nil;
    _socketManager = nil;
    _hostLinking = NO;
    
    [self cancelLinkAlertShow];
    [self cancelPKAlert];
    [self destroyLinkMicAskTimer];
}


#pragma mark - socket
-(void)getmessage:(NSDictionary *)msg andMethod:(NSString *)method{
    NSLog(@"socket收到消息=======>:%@",msg);
    
    if([method isEqual:Soc_SystemNot]){
        // 系统消息
        NSString *showCt = minstr([msg valueForKey:@"ct"]);
        if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([msg valueForKey:@"ct_en"])]) {
            showCt = minstr([msg valueForKey:@"ct_en"]);
        }
        NSDictionary *chatDic = @{
            @"userName":YZMsg(@"直播间消息"),
            @"contentChat":showCt,
            @"id":@"",
            @"titleColor":@"firstlogin",
            @"usertype":@"",
            @"isAnchor":@"",
            @"guard_type":@"",// 保留字段
            @"level":@"",
        };
        // 通知
        [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RoomMsg object:nil userInfo:chatDic];
        
        // 用户端特别处理
        if(_socketRole == Live_Socket_User){
            NSString *msgtype = [NSString stringWithFormat:@"%@",[msg valueForKey:@"msgtype"]];
            NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
            NSString *touid = [NSString stringWithFormat:@"%@",[msg valueForKey:@"touid"]];
            NSString *showCt = minstr([msg valueForKey:@"ct"]);
            if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([msg valueForKey:@"ct_en"])]) {
                showCt = minstr([msg valueForKey:@"ct_en"]);
            }
            if([msgtype isEqual:@"4"] && [action isEqual:@"13"]) {
                //设置取消管理员
                if ([touid isEqual:[Config getOwnID]]) {
                    [self showUserAlertMsg:showCt];
                }
            }else if ([msgtype isEqual:@"4"] && [action isEqual:@"1"]) {
                //禁言
                if ([touid isEqual:[Config getOwnID]]) {
                    [self showUserAlertMsg:showCt];
                }
            }
        }
        
    }else if ([method isEqual:@"warning"]){
        // 直播警告
        if(_socketRole == Live_Socket_User){
            return;
        }
        if (_banView) {
            [_banView removeFromSuperview];
            _banView = nil;
        }
        
        NSDictionary *infoDic = @{@"msg":minstr([msg valueForKey:@"ct"])};
        _banView = [[BanLiveView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andInfo:infoDic isWarning:YES];
        [_banView showWindow];
    }else if ([method isEqual:Soc_KickUser]){
        //踢人
        NSString *showCt = minstr([msg valueForKey:@"ct"]);
        if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([msg valueForKey:@"ct_en"])]) {
            showCt = minstr([msg valueForKey:@"ct_en"]);
        }
        NSDictionary *chatDic = @{
            @"userName":YZMsg(@"直播间消息"),
            @"contentChat":showCt,
            @"id":@"",
            @"titleColor":@"firstlogin",
            @"usertype":@"",
            @"isAnchor":@"",
            @"guard_type":@"",// 保留字段
            @"level":@"",
        };
        // 通知
        [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RoomMsg object:nil userInfo:chatDic];
        
        // 主播-用户端特别处理
        NSString *touid = minstr([msg valueForKey:@"touid"]);
        if(_socketRole == Live_Socket_Anchor){
            // im踢人
            [[YBLiveRTCManager shareInstance]kickUser:touid];
        }else {
            // 用户端
            if([touid isEqual:[Config getOwnID]]){
                [MBProgressHUD showError:YZMsg(@"你已被踢出房间")];
                self.socketEvent(Live_Socket_Kick, @{});
            }
        }
        
    }else if ([method isEqual:Soc_ShutUpUser]){
        //禁言
        NSString *showCt = minstr([msg valueForKey:@"ct"]);
        if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([msg valueForKey:@"ct_en"])]) {
            showCt = minstr([msg valueForKey:@"ct_en"]);
        }
        NSDictionary *chatDic = @{
            @"userName":YZMsg(@"直播间消息"),
            @"contentChat":showCt,
            @"id":@"",
            @"titleColor":@"firstlogin",
            @"usertype":@"",
            @"isAnchor":@"",
            @"guard_type":@"",// 保留字段
            @"level":@"",
        };
        // 通知
        [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RoomMsg object:nil userInfo:chatDic];
        
        // 用户端特别处理
        NSString *touid = minstr([msg valueForKey:@"touid"]);
        if(_socketRole == Live_Socket_User && [touid isEqual:[Config getOwnID]]){
            [self showUserAlertMsg:showCt];
        }
        
    }else if ([method isEqual:Soc_setAdmin]){
        //设置/取消管理
        NSString *userType = minstr([msg valueForKey:@"usertype"]);
        NSString *guardType = minstr([msg valueForKey:@"guard_type"]);
        NSString *level = minstr([msg valueForKey:@"level"]);
        NSString *isAnchor = @"0";
        if(![YBToolClass checkNull:minstr([msg valueForKey:@"isAnchor"])]){
            isAnchor = minstr([msg valueForKey:@"isAnchor"]);
        }
        NSString *showCt = minstr([msg valueForKey:@"ct"]);
        if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([msg valueForKey:@"ct_en"])]) {
            showCt = minstr([msg valueForKey:@"ct_en"]);
        }
        NSDictionary *chatDic = @{
            @"userName":YZMsg(@"直播间消息"),
            @"contentChat":showCt,
            @"id":@"",
            @"titleColor":@"firstlogin",
            @"usertype":userType,
            @"isAnchor":isAnchor,
            @"guard_type":guardType,// 保留字段
            @"level":level,
        };
        // 通知
        [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RoomMsg object:nil userInfo:chatDic];
        
        // 用户端特别处理
        if(_socketRole == Live_Socket_User){
            NSString *action = minstr([msg valueForKey:@"action"]);
            NSString *touid = minstr([msg valueForKey:@"touid"]);
            if(self.socketEvent && [touid isEqual:[Config getOwnID]]){
                self.socketEvent(Live_Socket_SetAdmin, @{@"action":action});
            }
        }
        
    }else if ([method isEqual:Soc_updateVotes]){
        //更新映票
        NSString *is_first = minstr([msg valueForKey:@"isfirst"]);
        NSString *votes = minstr([msg valueForKey:@"votes"]);
        NSString *soc_uid = minstr([msg valueForKey:@"uid"]);
        NSDictionary *votesDic = @{
            @"votes":votes,
            @"is_totlal":@"0",
        };
        if((![soc_uid isEqual:[Config getOwnID]] || [is_first isEqual:@"0"]) && _socketRole == Live_Socket_User){
            [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Votes object:nil userInfo:votesDic];
        }else if(_socketRole == Live_Socket_Anchor){
            [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Votes object:nil userInfo:votesDic];
        }
        
    }else if ([method isEqual:Soc_requestFans]){
        //僵尸粉
        NSArray *ct = [msg valueForKey:@"ct"];
        NSDictionary *data = [ct valueForKey:@"data"];
        int code = [minstr([data valueForKey:@"code"]) intValue];
        if (code == 0) {
            NSArray *info = [data valueForKey:@"info"];
            NSArray *list = [info valueForKey:@"list"];
            NSDictionary *notiDic = @{
                @"list":list,
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:Live_Notice_RoomFans object:nil userInfo:notiDic];
        }
        
    }else if ([method isEqual:Soc_ConnectVideo]){
        //用户连麦
        // 1 有人发送连麦请求  2 主播接受连麦 3 主播拒绝连麦 4 用户推流，发送自己的播流地址 5 用户断开连麦 6 主播断开连麦 7 主播正忙碌 8 主播无响应
        int action = [minstr([msg valueForKey:@"action"]) intValue];
        NSString *touid = minstr([msg valueForKey:@"touid"]);
        switch (action) {
            case 1:{
                // 主播端响应
                if(_socketRole == Live_Socket_Anchor){
                    if (_linkMicAskLast != 10 || _hostLinking) {
                        
                        NSDictionary *socDic = @{
                            @"action":@"7",
                            @"touid":minstr([msg valueForKey:@"uid"]),
                        };
                        [self socketSendUserLink:socDic];
                        
                        return;
                    }
                    [self destroyLinkMicAskTimer];
                    _linkMicAskLast = 10;
                    _linkMicAskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(linkMicAskEvent) userInfo:nil repeats:YES];
                    _linkRequestUid = minstr([msg valueForKey:@"uid"]);
                    [self showLinkAlert:msg];
                }
            }break;
            case 4:{
                if (_socketRole == Live_Socket_Anchor && [_linkRequestUid isEqual:minstr([msg valueForKey:@"uid"])]) {
                    // 主播端显示用户小窗
                    [[NSNotificationCenter defaultCenter] postNotificationName:Live_Notice_UserLinkPop object:nil userInfo:msg];
                }
                if(_socketRole == Live_Socket_User){
                    // 用户端不做处理
                }
            }break;
            case 5:{ // 用户端挂断
                if(_socketRole == Live_Socket_Anchor){
                    // 主播端的处理
                    _hostLinking = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:Live_Notice_UserHung object:nil userInfo:msg];
                }
                if(_socketRole == Live_Socket_User){
                    // 用户端的处理
                    if (![minstr([msg valueForKey:@"uid"]) isEqual:[Config getOwnID]]) {
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@%@",[msg valueForKey:@"uid"],YZMsg(@"已下麦")]];
                    }
                }
            }break;
                
            case 2:{
                if (_socketRole == Live_Socket_User && [touid isEqual:[Config getOwnID]]) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_AnchorAgree object:nil userInfo:msg];
                }
            }break;
            case 3:{
                if (_socketRole == Live_Socket_User && [touid isEqual:[Config getOwnID]]) {
                    [MBProgressHUD showError:YZMsg(@"主播拒绝了您的连麦请求")];
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_AnchorRefuse object:nil userInfo:msg];
                }
            }break;
            case 6:{
                if(_socketRole == Live_Socket_User){
                    if ([touid isEqual:[Config getOwnID]]) {
                        [MBProgressHUD showError:YZMsg(@"主播已把您下麦")];
                        [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RemoveLinkPop object:nil userInfo:msg];
                    }else {
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@%@",touid,YZMsg(@"已下麦")]];
                    }
                }
            }break;
            case 7:{
                if (_socketRole == Live_Socket_User && [touid isEqual:[Config getOwnID]]) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RemoveLinkPop object:nil userInfo:msg];
                    [MBProgressHUD showError:YZMsg(@"主播正忙碌")];
                }
            }break;
            case 8:{
                if (_socketRole == Live_Socket_User && [touid isEqual:[Config getOwnID]]) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RemoveLinkPop object:nil userInfo:msg];
                    [MBProgressHUD showError:YZMsg(@"当前主播暂时无法接通")];
                }
            }break;
                
            default:
                break;
        }
        
    }else if ([method isEqual:Soc_LiveConnect]){
        //主播连麦
        //1：发起连麦；2；接受连麦；3:拒绝连麦；4：连麦成功通知；5.手动断开连麦;7:对方正忙碌 8:对方无响应
        int action = [minstr([msg valueForKey:@"action"]) intValue];
        switch (action) {
            case 1:{
                if(_socketRole == Live_Socket_Anchor){
                    if (_linkMicAskLast != 10 || _hostLinking) {
                        NSDictionary *socDic = @{
                            @"action":@"7",
                            @"pkuid":minstr([msg valueForKey:@"uid"]),
                        };
                        [[YBLiveSocket shareInstance]socketSendAnchorLink:socDic];
                        return;
                    }
                    // 通知
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RemoveOnline object:nil userInfo:msg];
                    [self destroyLinkMicAskTimer];
                    _linkMicAskLast = 10;
                    _linkMicAskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(linkMicAskEvent) userInfo:nil repeats:YES];
                    _linkRequestUid = minstr([msg valueForKey:@"uid"]);
                    [self showLinkAlert:msg];
                }
            }break;
            case 3:{
                if(_socketRole == Live_Socket_Anchor){
                    [MBProgressHUD showError:YZMsg(@"对方主播拒绝了你的连麦申请")];
                    _hostLinking = NO;
                }
            }break;
            case 4:{
                
                // 通知主播、用户端
                [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_AnchorLinkChange object:nil userInfo:msg];
                // 主播端特别处理
                if(_socketRole == Live_Socket_Anchor) {
                    if([minstr([msg valueForKey:@"uid"]) isEqual:[Config getOwnID]]){
                        [MBProgressHUD showError:YZMsg(@"对方主播接受了您的连麦请求，开始连麦")];
                    }
                    _hostLinking = YES;
                }
                
            }break;
            case 5:{
                // 通知主播、用户端
                [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_AnchorLinkChange object:nil userInfo:msg];
                
                // 主播端特别处理
                if(_socketRole == Live_Socket_Anchor){
                    [MBProgressHUD showError:YZMsg(@"连麦已断开")];
                    _hostLinking = NO;
                }
            }break;
            case 7:{
                if(_socketRole == Live_Socket_Anchor){
                    [MBProgressHUD showError:YZMsg(@"对方正忙碌")];
                    _hostLinking = NO;
                }
            }break;
            case 8:{
                if(_socketRole == Live_Socket_Anchor){
                    [MBProgressHUD showError:YZMsg(@"对方无响应")];
                    _hostLinking = NO;
                }
            }break;
                
            default:
                break;
        }
    }else if ([method isEqual:Soc_LivePK]){
        //PK
        //1：发起PK；2；接受PK；3:拒绝PK；4：PK成功通知；5.;7:对方正忙碌 8:对方无响应 9:PK结果
        int action = [minstr([msg valueForKey:@"action"]) intValue];
        switch (action) {
            case 1:{
                if(_socketRole == Live_Socket_Anchor){
                    if (_pkAlertView) {//理论不会出现这种情况
                        [self socketSendLivePKAction:@"7"];
                        return;
                    }
                    NSDictionary *notDic = @{
                        @"btn_show":@"0",
                    };
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_PKBtn object:nil userInfo:notDic];
                    
                    [self showPKAlert:msg];
                }
            }break;
            case 3:{
                if(_socketRole == Live_Socket_Anchor){
                    [self cancelPKAlert];
                    NSDictionary *notDic = @{
                        @"btn_show":@"1",
                    };
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_PKBtn object:nil userInfo:notDic];
                    [MBProgressHUD showError:YZMsg(@"对方主播拒绝了您的PK请求")];
                }
                
            }break;
            case 4:{
                // pk开始
                [[NSNotificationCenter defaultCenter] postNotificationName:Live_Notice_PKStart object:nil userInfo:msg];
                
                // 主播端特别处理
                if(_socketRole == Live_Socket_Anchor){
                    [self cancelPKAlert];
                }
            }break;
            case 7:{
                if(_socketRole == Live_Socket_Anchor){
                    [self cancelPKAlert];
                    NSDictionary *notDic = @{
                        @"btn_show":@"1",
                    };
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_PKBtn object:nil userInfo:notDic];
                    [MBProgressHUD showError:YZMsg(@"对方正忙碌")];
                }
                
            }break;
            case 8:{
                if(_socketRole == Live_Socket_Anchor){
                    [self cancelPKAlert];
                    NSDictionary *notDic = @{
                        @"btn_show":@"1",
                    };
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_PKBtn object:nil userInfo:notDic];
                    [MBProgressHUD showError:YZMsg(@"对方无响应")];
                }
               
            }break;
            case 9:{
                // pk结果
                [[NSNotificationCenter defaultCenter] postNotificationName:Live_Notice_PKRes object:nil userInfo:msg];
            }break;

            default:
                break;
        }
        
    }else if ([method isEqual:Soc_LiveUdataSwitch]){
        //个人资料开关【iOS只负责发送，不用处理收，用户点击资料卡片getpop接口会提示】
    }else if ([method isEqual:Soc_SendBarrage]){
        //弹幕
        NSDictionary *ctDic = [msg valueForKey:@"ct"];
        NSDictionary *danDic = @{
            @"title":minstr([ctDic valueForKey:@"content"]),
            @"name":minstr([msg valueForKey:@"uname"]),
            @"icon":minstr([msg valueForKey:@"uhead"]),
            @"nameColor":@"#ffffff",
        };
        [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Barrage object:nil userInfo:danDic];
        
        // 映票
        NSDictionary *votesDic = @{
            @"votes":minstr([ctDic valueForKey:@"votestotal"]),
            @"is_totlal":@"1",
        };
        [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Votes object:nil userInfo:votesDic];
        
    }else if ([method isEqual:Soc_SendGift]){
        //礼物
        int ifpk = [minstr([msg valueForKey:@"ifpk"]) intValue];
        NSString *roomNum = minstr([msg valueForKey:@"roomnum"]);
        if(ifpk == 1){
            // 更新 pk 进度条
            [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_PKProgress object:nil userInfo:msg];
        }
        if([roomNum isEqual:_roomNum]){
            NSDictionary *ctDic = [msg valueForKey:@"ct"];
            NSDictionary *uDic = @{
                @"avatar":minstr([msg valueForKey:@"uhead"]),
                @"user_nickname":minstr([msg valueForKey:@"uname"]),
            };
            NSMutableDictionary *m_gift = [NSMutableDictionary dictionaryWithDictionary:ctDic];
            [m_gift addEntriesFromDictionary:uDic];
            NSDictionary *giftDic = [NSDictionary dictionaryWithDictionary:m_gift];
            // 展示礼物效果
            [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_GiftSoc object:nil userInfo:giftDic];
            
            //公屏显示
            NSString *locGNstr = minstr([ctDic valueForKey:@"giftname"]);
            if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([ctDic valueForKey:@"giftname_en"])]) {
                locGNstr = minstr([ctDic valueForKey:@"giftname_en"]);
            }
            NSString *showCt = [NSString stringWithFormat:YZMsg(@"送%@个%@"),[ctDic valueForKey:@"giftcount"],locGNstr];
            NSDictionary *chatDic = @{
                @"userName":minstr([msg valueForKey:@"uname"]),
                @"contentChat":showCt,
                @"id":minstr([msg valueForKey:@"uid"]),
                @"titleColor":@"giftText",
                @"usertype":@"30",
                @"isAnchor":@"0",
                @"guard_type":@"0",// 保留字段
                @"level":minstr([msg valueForKey:@"level"]),
                @"vip_type":minstr([msg valueForKey:@"vip_type"]),
            };
            [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RoomMsg object:nil userInfo:chatDic];
            
            // 更新映票
            NSDictionary *votesDic = @{
                @"votes":minstr([ctDic valueForKey:@"votestotal"]),
                @"is_totlal":@"1",
            };
            [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Votes object:nil userInfo:votesDic];
        }
        
    }else if ([method isEqual:Soc_stopLive]){
        //超管关播
        if(_socketRole == Live_Socket_Anchor && self.socketEvent){
            self.socketEvent(Live_Socket_SuperClose, @{});
        }
    }else if ([method isEqual:Soc_StartEndLive]){
        //主播关播
        if(_socketRole == Live_Socket_User && self.socketEvent){
            self.socketEvent(Live_Socket_LiveOver, @{});
        }
    }else if ([method isEqual:Soc_SendMsg]){
        //公屏消息
        NSString *msgtype = minstr([msg valueForKey:@"msgtype"]);
        NSString *action = minstr([msg valueForKey:@"action"]);
        if([msgtype isEqual:@"2"]) {
            //默认-聊天消息
            NSString *titleColor = @"0";
            NSString *ct = minstr([msg valueForKey:@"ct"]);
            if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([msg valueForKey:@"ct_en"])]) {
                ct = minstr([msg valueForKey:@"ct_en"]);
            }
            NSString *uname = minstr([msg valueForKey:@"uname"]);
            NSString *uid = minstr([msg valueForKey:@"uid"]);
            NSString *userType = minstr([msg valueForKey:@"usertype"]);
            NSString *guardType = minstr([msg valueForKey:@"guard_type"]);
            NSString *level = minstr([msg valueForKey:@"level"]);
            NSString *vip_type = minstr([msg valueForKey:@"vip_type"]);
            NSString *isAnchor = @"0";
            if(![YBToolClass checkNull:minstr([msg valueForKey:@"isAnchor"])]){
                isAnchor = minstr([msg valueForKey:@"isAnchor"]);
            }
            if (![YBToolClass checkNull:minstr([msg valueForKey:@"heart"])]) {
                //说明是点亮消息
                titleColor = [@"light" stringByAppendingFormat:@"%@",[msg valueForKey:@"heart"]];
                [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Light object:nil userInfo:nil];
            }
            NSDictionary *chatDic = @{
                @"userName":uname,
                @"contentChat":ct,
                @"id":uid,
                @"titleColor":titleColor,
                @"usertype":userType,
                @"isAnchor":isAnchor,
                @"guard_type":guardType,// 保留字段
                @"level":level,
                @"vip_type":vip_type,
            };
            // 通知
            [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RoomMsg object:nil userInfo:chatDic];
        }
        if([msgtype isEqual:@"0"]) {
            if ([action isEqual:@"1"]) {
                //用户离开.离开的用户 id 在 ct 里边 'id'
                [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_UserLeave object:nil userInfo:msg];
                if(_socketRole == Live_Socket_Anchor){
                    NSString *leaveuid = minstr([[msg valueForKey:@"ct"] valueForKey:@"id"]);
                    if ((_linkAlertView && [_linkAlertView.applyUid isEqual:leaveuid]) || [leaveuid isEqual:_linkRequestUid]) {
                        _hostLinking = NO;
                        //退出的用户是发起连麦的人
                        [self destroyLinkMicAskTimer];
                        [self cancelLinkAlertShow];
                    }
                }
            }
            if ([action isEqual:@"0"]) {
                // 用户进入.离开的用户 id 在 ct 里边 'id'
                // 进入通知
                [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_UserEnter object:nil userInfo:msg];
                
                NSString *vipType = [NSString stringWithFormat:@"%@",[[msg valueForKey:@"ct"] valueForKey:@"vip_type"]];
                NSString *guardType = [NSString stringWithFormat:@"%@",[[msg valueForKey:@"ct"] valueForKey:@"guard_type"]];
                if ([vipType isEqual:@"1"] || [guardType isEqual:@"1"] || [guardType isEqual:@"2"]) {
                    //进场动画
                    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_EnterAni object:nil userInfo:msg];
                }
                // 进房间公屏提示
                NSDictionary *ctDic = [msg valueForKey:@"ct"];
                NSDictionary *chatDic = @{
                    @"userName":minstr([ctDic valueForKey:@"user_nickname"]),
                    @"contentChat":YZMsg(@" 进入了直播间"),
                    @"id":minstr([ctDic valueForKey:@"id"]),
                    @"titleColor":@"userLogin",
                    @"usertype":minstr([ctDic valueForKey:@"usertype"]),
                    @"guard_type":minstr([ctDic valueForKey:@"guard_type"]),
                    @"level":minstr([ctDic valueForKey:@"level"]),
                    @"vip_type":minstr([ctDic valueForKey:@"vip_type"]),
                };
                [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_RoomMsg object:nil userInfo:chatDic];
            }
        }
        
        if ([msgtype isEqual:@"1"] && [action isEqual:@"18"]) {
            // 关闭直播
            if(_socketRole == Live_Socket_User && self.socketEvent){
                self.socketEvent(Live_Socket_LiveOver, @{});
            }
        }
    }else if ([method isEqual:Soc_disconnect]){
        //用户离开.离开的用户 id 在 ct 里边 'id'
        [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_UserLeave object:nil userInfo:msg];
        
        if(_socketRole == Live_Socket_Anchor){
            NSString *leaveuid = minstr([[msg valueForKey:@"ct"] valueForKey:@"id"]);
            if ((_linkAlertView && [_linkAlertView.applyUid isEqual:leaveuid]) || [leaveuid isEqual:_linkRequestUid]) {
                _hostLinking = NO;
                //退出的用户是发起连麦的人
                [self destroyLinkMicAskTimer];
                [self cancelLinkAlertShow];
            }
        }
    }
    
}
#pragma mark - 连麦处理开始
- (void)showLinkAlert:(NSDictionary *)dic{
    [self cancelLinkAlertShow];
    _linkAlertView = [[YBLinkAlertView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andUserMsg:dic];
    _linkAlertView.timeL.text = [NSString stringWithFormat:@"%@(10)...",YZMsg(@"发起连麦请求")];
    [[UIApplication sharedApplication].delegate.window addSubview:_linkAlertView];
    [_linkAlertView show];
    WeakSelf;
    _linkAlertView.linkAlertEvent = ^(BOOL isAgree,BOOL isHostLink) {
        _linkMicAskLast = 10;
        [weakSelf destroyLinkMicAskTimer];
        if (isAgree) {
            //连麦请求-同意
            if(weakSelf.musicIsPlay){
                [weakSelf showMusicAlert:isHostLink eveDic:dic];
            }else{
                [weakSelf linkAlertAgree:isHostLink eveDic:dic];
            }
        }else{
            //连麦-拒绝
            [weakSelf linkAlertRefuse:isHostLink eveDic:dic];
        }
    };
}
-(void)linkAlertAgree:(BOOL)isHostLink eveDic:(NSDictionary *)dic {
    if (isHostLink) {
        //主播连麦-检查开播状态
        [self checkLinkLive:dic];
    }else {
        //用户连麦
        NSDictionary *socDic = @{
            @"action":@"2",
            @"touid":minstr([dic valueForKey:@"uid"]),
        };
        [self socketSendUserLink:socDic];
        _hostLinking = YES;
    }
}
-(void)linkAlertRefuse:(BOOL)isHostLink eveDic:(NSDictionary *)dic {
    if (isHostLink) {
        NSDictionary *socDic = @{
            @"action":@"3",
            @"pkuid":minstr([dic valueForKey:@"uid"]),
        };
        [[YBLiveSocket shareInstance]socketSendAnchorLink:socDic];
    }else {
        //用户连麦
        NSDictionary *socDic = @{
            @"action":@"3",
            @"touid":minstr([dic valueForKey:@"uid"]),
        };
        [self socketSendUserLink:socDic];
    }
    _hostLinking = NO;
}
// 伴奏提醒
-(void)showMusicAlert:(BOOL)isHostLink eveDic:(NSDictionary *)dic {
    NSDictionary *contentDic = @{
        @"title":YZMsg(@"提示"),
        @"msg":YZMsg(@"连麦时需要关闭背景音乐"),
        @"left":YZMsg(@"取消"),
        @"right":YZMsg(@"确定")};
    WeakSelf;
    [YBLiveAlert showAlertView:contentDic complete:^(int eventType) {
        if(eventType == 1){
            // 停止音乐
            weakSelf.socketEvent(Live_Music_Stop, @{});
            // 同意连麦
            [weakSelf linkAlertAgree:isHostLink eveDic:dic];
        }else {
            // 不停止音乐，拒绝连麦
            [weakSelf linkAlertRefuse:isHostLink eveDic:dic];
        }
    }];
}


//检查主播状态
-(void)checkLinkLive:(NSDictionary *)checkDic {
    NSDictionary *postDic = @{@"stream":minstr([checkDic valueForKey:@"stream"]),@"uid_stream":minstr([_roomDic valueForKey:@"stream"])};
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Zlivepk.CheckLive" andParameter:postDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        _linkMicAskLast = 10;
        [weakSelf destroyLinkMicAskTimer];
        if (code == 0) {
            _hostLinking = YES;
            NSString *newPull = minstr([[info firstObject] valueForKey:@"pull"]);
            NSDictionary *socDic = @{
                @"action":@"2",
                @"pkuid":minstr([checkDic valueForKey:@"uid"]),
                @"pkpull":newPull,
            };
            [[YBLiveSocket shareInstance]socketSendAnchorLink:socDic];
            
        }else{
            [MBProgressHUD showError:msg];
            _hostLinking = NO;
        }
    } fail:^{
        _linkMicAskLast = 10;
        [weakSelf destroyLinkMicAskTimer];
        _hostLinking = NO;
    }];
}
-(void)cancelLinkAlertShow {
    _linkMicAskLast = 10;
    if (_linkAlertView) {
        [_linkAlertView removeFromSuperview];
        _linkAlertView = nil;
    }
}
-(void)linkMicAskEvent {
    _linkMicAskLast -= 1;
    _linkAlertView.timeL.text = [NSString stringWithFormat:@"%@(%ds)...",YZMsg(@"发起连麦请求"),_linkMicAskLast];
    if (_linkMicAskLast <= 0) {
        if (_linkAlertView.isHostToHost) {
            NSDictionary *socDic = @{
                @"action":@"8",
                @"pkuid":_linkRequestUid,
            };
            [[YBLiveSocket shareInstance]socketSendAnchorLink:socDic];
        }else {
            NSDictionary *socDic = @{
                @"action":@"8",
                @"touid":_linkRequestUid,
            };
            [self socketSendUserLink:socDic];
        }
        [self destroyLinkMicAskTimer];
        [self cancelLinkAlertShow];
    }
}
-(void)destroyLinkMicAskTimer {
    if (_linkMicAskTimer) {
        [_linkMicAskTimer invalidate];
        _linkMicAskTimer = nil;
    }
}
#pragma mark - 连麦处理结束

#pragma mark - PK处理开始
-(void)showPKAlert:(NSDictionary *)dic {
    [self cancelPKAlert];
    
    _pkAlertView = [[YBAnchorPKAlert alloc]initWithFrame:CGRectMake(_window_width*0.15, _window_height/2-(_window_width*0.7/52*34)/2, _window_width*0.7, _window_width*0.7/52*34) andIsStart:NO];
    [[UIApplication sharedApplication].delegate.window addSubview:_pkAlertView];
    WeakSelf;
    _pkAlertView.anchorPkEvent = ^(AnchorPkAlertType pkAlertType) {
        [weakSelf pkAlertCallBack:pkAlertType];
    };
}
-(void)pkAlertCallBack:(AnchorPkAlertType)pkAlertType {
    [self cancelPKAlert];
    switch (pkAlertType) {
        case PkAlertType_unAgree:{
            [self socketSendLivePKAction:@"3"];
            NSDictionary *notDic = @{
                @"btn_show":@"1",
            };
            [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_PKBtn object:nil userInfo:notDic];
        }break;
        case PkAlertType_Agree:{
            [self socketSendLivePKAction:@"2"];
        }break;
        case PkAlertType_TimeOut:{
            [self socketSendLivePKAction:@"8"];
            NSDictionary *notDic = @{
                @"btn_show":@"1",
            };
            [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_PKBtn object:nil userInfo:notDic];
        }default:
            break;
    }
}
-(void)cancelPKAlert {
    if (_pkAlertView) {
        [_pkAlertView removeTimer];
        [_pkAlertView removeFromSuperview];
        _pkAlertView = nil;
    }
}
#pragma mark - PK处理结束

#pragma mark - 弹窗提示
-(void)showUserAlertMsg:(NSString *)msg {
    NSDictionary *contentDic = @{
        @"title":YZMsg(@"提示"),
        @"msg":msg,
        @"left":@"",
        @"right":YZMsg(@"确定")};
    [YBLiveAlert showAlertView:contentDic complete:^(int eventType) {
    
    }];
}

#pragma mark - socket 方法
/** 系统通知 */
-(void)socketSendSystem:(NSString *)conStr conStrEn:(NSString *)conStrEn{
    NSArray *socketArray =@[
        @{
            @"msg":@[
                @{
                    @"_method_":Soc_SystemNot,
                    @"action":@"13",
                    @"ct":conStr,
                    @"ct_en":conStrEn,
                    @"msgtype":@"4",
                    @"uid":@"",
                    @"uname":YZMsg(@"直播间消息"),
                    @"touid":@"",
                    @"touname":@""
                }
            ],
            @"retcode":@"000000",
            @"retmsg":@"ok"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
}
/** 踢人 */
-(void)socketSendKick:(NSDictionary *)conDic {
    NSString *touname = minstr([conDic valueForKey:@"touname"]);
    NSString *touid = minstr([conDic valueForKey:@"touid"]);
    // yb_lang
    NSString *ct_str = @"被踢出房间";
    NSString *ct_str_en = @" kicked out of the room";
    NSArray* socketArray = @[
        @{
            @"msg":
                @[@{
                    @"_method_":Soc_KickUser,
                    @"action":@"2",
                    @"ct":[NSString stringWithFormat:@"%@%@",touname,ct_str],
                    @"ct_en":[NSString stringWithFormat:@"%@%@",touname,ct_str_en],
                    @"uid":[Config getOwnID],
                    @"touid":touid,
                    @"showid":[Config getOwnID],
                    @"uname":@"",
                    @"msgtype":@"4",
                    @"timestamp":@"",
                    @"tougood":@"",
                    @"touname":@"",
                    @"ugood":@""
                }],
            @"retcode":@"000000",
            @"retmsg":@"OK"}
    ];
    [MBProgressHUD showError:YZMsg(@"踢人成功")];
    [_socketClient emit:@"broadcast" with:socketArray];
}
/** 禁言 */
-(void)socketSendShutUpUser:(NSDictionary *)conDic {
    // yb_lang
    NSString *msg ;
    NSString *msg_en;
    NSString *type = minstr([conDic valueForKey:@"type"]);
    NSString *touid = minstr([conDic valueForKey:@"touid"]);
    NSString *touname = minstr([conDic valueForKey:@"touname"]);
    if ([type isEqual:@"0"]) {
        msg = [NSString stringWithFormat:@"%@被永久禁言",touname];
        msg_en = [NSString stringWithFormat:@"%@ permanently banned from speaking",touname];
    }else{
        msg = [NSString stringWithFormat:@"%@被本场禁言",touname];
        msg_en = [NSString stringWithFormat:@"%@ forbidden by this venue",touname];
    }
    NSArray* socketArray = @[
        @{
            @"msg":
                @[@{
                    @"_method_":Soc_ShutUpUser,
                    @"action":@"1",
                    @"ct":msg,
                    @"ct_en":msg_en,
                    @"uid":[Config getOwnID],
                    @"touid":touid,
                    @"showid":[Config getOwnID],
                    @"uname":@"",
                    @"msgtype":@"4",
                    @"timestamp":@"",
                    @"tougood":@"",
                    @"touname":@"",
                    @"ugood":@"",
                    @"type":type
                }],
            @"retcode":@"000000",
            @"retmsg":@"OK"}
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
}
/** 设置取消管理 */
-(void)socketSendSetAdmin:(NSDictionary *)conDic {
    NSString *action = minstr([conDic valueForKey:@"action"]);
    NSString *touid = minstr([conDic valueForKey:@"touid"]);
    NSString *touname = minstr([conDic valueForKey:@"touname"]);
    //yb_lang
    NSString *cts;
    NSString *cts_en;
    if ([action isEqual:@"0"]) {
        //不是管理员
        cts = @"被取消管理员";
        cts_en = @" cancelled administrator";
        [MBProgressHUD showError:YZMsg(@"取消管理员成功")];
    }else{
        //是管理员
        cts = @"被设为管理员";
        cts_en = @" set as administrator";
        [MBProgressHUD showError:YZMsg(@"设置管理员成功")];
    }
    
    NSArray *socketArray =@[
        @{
            @"msg":@[
                @{
                    @"_method_":Soc_setAdmin,
                    @"action":action,
                    @"ct":[NSString stringWithFormat:@"%@%@",touname,cts],
                    @"ct_en":[NSString stringWithFormat:@"%@%@",touname,cts_en],
                    @"msgtype":@"1",
                    @"uid":[Config getOwnID],
                    @"uname":YZMsg(@"直播间消息"),
                    @"touid":touid,
                    @"touname":touname
                }
            ],
            @"retcode":@"000000",
            @"retmsg":@"ok"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
}
/** 更新映票 */
-(void)socketSendUpdateVotes:(NSDictionary *)conDic {
    NSString *votes = minstr([conDic valueForKey:@"votes"]);
    NSString *isfirst = minstr([conDic valueForKey:@"isfirst"]);
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_updateVotes,
                    @"action":@"1",
                    @"votes":votes,
                    @"msgtype": @"26",
                    @"uid":[Config getOwnID],
                    @"isfirst":isfirst
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
}
/** 僵尸粉 */
-(void)socketSendRequestFans {    
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_requestFans,
                    @"timestamp":@"",
                    @"msgtype": @"0",
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
}


/** 个人资料开关 */
-(void)socketSendLiveUdataSwitch:(NSDictionary *)conDic {
    int action = [minstr([conDic valueForKey:@"action"]) intValue];
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_LiveUdataSwitch,
                    @"action": @(action),
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
}

/** 弹幕 */
-(void)socketSendSendBarrage:(NSString *)conStr {
    
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_SendBarrage,
                    @"action": @"7",
                    @"ct":conStr,
                    @"msgtype": @"1",
                    @"timestamp": @"",
                    @"tougood": @"",
                    @"touid": @"0",
                    @"touname": @"",
                    @"ugood": [Config getOwnID],
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"equipment": @"app",
                    @"roomnum": _roomNum,
                    @"level":[Config getLevel],
                    @"usign":@"",
                    @"uhead":[Config getavatar],
                    @"sex":@"",
                    @"city":@"",
                    @"vip_type":[Config getVip_type],
                    @"liangname":[Config getliang]
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
}

/** 礼物 */
-(void)socketSendSendGift:(NSDictionary *)conDic {
    
    NSString *giftToken = minstr([conDic valueForKey:@"gifttoken"]);
    NSString *level = minstr([conDic valueForKey:@"level"]);
    NSString *evenSend = minstr([conDic valueForKey:@"evensend"]);
    
    //    NSArray *paintedPath = [conDic valueForKey:@"paintedPath"];
    //    NSString *paintedHeight = minstr([conDic valueForKey:@"paintedHeight"]);
    //    NSString *paintedWidth = minstr([conDic valueForKey:@"paintedWidth"]);
    
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_SendGift,
                    @"action": @"0",
                    @"ct":giftToken ,
                    @"msgtype": @"1",
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"equipment": @"app",
                    @"roomnum": _roomNum,
                    @"level":level,
                    @"evensend":evenSend,
                    @"uhead":[Config getavatar],
                    @"vip_type":[Config getVip_type],
                    @"liangname":[Config getliang],
                    @"livename":_anchorName,
                    //@"paintedPath":paintedPath,
                    //@"paintedHeight":paintedHeight,
                    //@"paintedWidth":paintedWidth,
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
}
/** 发送文字 */
-(void)socketSendSendMsg:(NSString *)conStr {
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_SendMsg,
                    @"action": @"0",
                    @"ct":conStr,
                    @"msgtype": @"2",
                    @"timestamp": @"",
                    @"touid": @"0",
                    @"ugood": [Config getOwnID],
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"equipment": @"app",
                    @"uhead":[Config getavatar],
                    @"level":[Config getLevel],
                    @"vip_type":[Config getVip_type],
                    @"usertype":_userType,
                    @"liangname":[Config getliang],
                    @"isAnchor":_socketRole == Live_Socket_Anchor ?@"1":@"0",
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
}
/** 超管关播 */
-(void)socketSendSuperStopLive {
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_stopLive,
                    @"action": @"19",
                    @"ct":@"",
                    @"msgtype": @"1",
                    @"timestamp": @"",
                    @"tougood": @"",
                    @"touid": @"0",
                    @"touname": @"",
                    @"ugood": [Config getOwnID],
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"equipment": @"app",
                    @"roomnum":_roomNum,
                    @"usign":@"",
                    @"uhead":[Config getavatar],
                    @"level":[Config getLevel],
                    @"city":@"",
                    @"sex":@""
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
}

/** 主播关播 */
-(void)socketSendEndLive {
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_StartEndLive,
                    @"action": @"18",
                    @"ct":@"直播关闭",
                    @"msgtype": @"1",
                    @"timestamp": @"",
                    @"tougood": @"",
                    @"touid": @"",
                    @"touname": @"",
                    @"ugood": @"",
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"equipment": @"app",
                    @"roomnum": _roomNum
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
    NSArray *socketArray2 =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_SendMsg,
                    @"action": @"18",
                    @"ct":@"直播关闭",
                    @"msgtype": @"1",
                    @"timestamp": @"",
                    @"tougood": @"",
                    @"touid": @"",
                    @"touname": @"",
                    @"ugood":@"",
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"level":[Config getLevel],
                    @"equipment": @"app",
                    @"roomnum": _roomNum
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray2];
    
}
/** 点亮 */
-(void)socketSendScreenLight:(NSDictionary *)conDic {
    NSString *userType = minstr([conDic valueForKey:@"user_type"]);
    
    NSInteger random = arc4random()%5;
    NSString *num = [NSString stringWithFormat:@"%ld",(long)random];
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_SendMsg,
                    @"action": @"0",
                    @"ct": YZMsg(@"我点亮了"),
                    @"ct_en": @"I'm lighted",
                    @"msgtype": @"2",
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"usertype":userType,
                    @"heart":num,
                    @"level":[Config getLevel],
                    @"vip_type":[Config getVip_type],
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
}

/** 用户连麦 */
-(void)socketSendUserLink:(NSDictionary *)conDic {
    
    NSString *action = minstr([conDic valueForKey:@"action"]);
    if([action isEqual:@"6"]){
        _hostLinking = NO;
    }
    NSString *playUrl = minstr([conDic valueForKey:@"playurl"]);
    NSString *touid = minstr([conDic valueForKey:@"touid"]);
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_ConnectVideo,
                    @"action":action,
                    @"msgtype": @"10",
                    @"uid":[Config getOwnID],
                    @"uname":[Config getOwnNicename],
                    @"uhead":[Config getavatar],
                    @"playurl":playUrl,
                    @"touid":touid,
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
}

/** 主播连麦 */
-(void)socketSendAnchorLink:(NSDictionary *)conDic {
    NSString *action = minstr([conDic valueForKey:@"action"]);
    NSString *pkuid = minstr([conDic valueForKey:@"pkuid"]);
    
    if([action isEqual:@"1"]){
        _linkRequestUid = pkuid;
    }
    
    // 只有action=1、action=2 时候 pkpull 有值
    NSString *pkpull = minstr([conDic valueForKey:@"pkpull"]);
    // 只有action=1 时候 stream 有值
    NSString *stream = minstr([conDic valueForKey:@"stream"]);
    
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_LiveConnect,
                    @"action":action,
                    @"msgtype": @"0",
                    @"uid":[Config getOwnID],
                    @"uname":[Config getOwnNicename],
                    @"uhead":[Config getavatarThumb],
                    @"level":[Config getLevel],
                    @"sex":[Config getSex],
                    @"pkuid":pkuid,
                    @"pkpull":pkpull,
                    @"stream":stream,
                    @"level_anchor":[Config level_anchor],
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
}

/** PK */
-(void)socketSendLivePKAction:(NSString *)action {
    
    if([YBToolClass checkNull:_linkRequestUid]){
        [MBProgressHUD showError:YZMsg(@"缺少信息")];
        return;
    }
    // 连麦人的uid
    NSString *pkuid = _linkRequestUid;
    // action=1时候需要
    NSString *stream = minstr([_roomDic valueForKey:@"stream"]);
    
    NSArray *socketArray =@[
        @{
            @"msg": @[
                @{
                    @"_method_": Soc_LivePK,
                    @"action":action,
                    @"msgtype": @"0",
                    @"uid":[Config getOwnID],
                    @"uname":[Config getOwnNicename],
                    @"uhead":[Config getavatarThumb],
                    @"level":[Config getLevel],
                    @"sex":[Config getSex],
                    @"pkuid":pkuid,
                    @"level_anchor":[Config level_anchor],
                    @"stream":stream,
                    @"ct":@""
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_socketClient emit:@"broadcast" with:socketArray];
    
}

@end

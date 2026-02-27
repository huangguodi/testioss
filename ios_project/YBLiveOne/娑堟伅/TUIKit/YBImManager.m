//
//  YBImManager.m
//  YBHiMo
//
//  Created by YB007 on 2021/9/15.
//  Copyright © 2021 YB007. All rights reserved.
//

#import "YBImManager.h"

#import <UserNotifications/UserNotifications.h>
#import "TUIKit.h"
//#import "TChatGroupController.h"
#import "THeader.h"
//#import <TPNS-iOS/XGPush.h>
#import "TTextMessageCell.h"
#import "TSystemMessageCell.h"
#import "TVoiceMessageCell.h"
#import "TImageMessageCell.h"
#import "TFaceMessageCell.h"
#import "TFaceView.h"
#import "TVideoMessageCell.h"
#import "TFileMessageCell.h"
//#import "TGoodsCell.h"
//#import "TLocationMessageCell.h"
#import "TGiftMessageCell.h"
#import "TCallCell.h"


@interface YBImManager()<V2TIMAdvancedMsgListener,V2TIMGroupListener>

@property(nonatomic,strong)AVPlayer *ringPlayer;
@property (nonatomic, strong) TUIKitConfig *config;
@property (nonatomic, strong) TMessageCellData *tMsgCelldata;

@end

@implementation YBImManager

static YBImManager *_imManager = nil;

+(instancetype)shareInstance;{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imManager = [[super allocWithZone:NULL]init];
    });
    return _imManager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}
#pragma mark - 加入群组
-(void)joinGroup; {
    NSString *groupId = minstr([common get_full_group_id]);
    if([YBToolClass checkNull:groupId]){
        return;
    }
    
    [[V2TIMManager sharedInstance] joinGroup:groupId msg:@"join" succ:^{
        NSLog(@"rk===>群组成功");
        [[V2TIMManager sharedInstance] addGroupListener:self];
    } fail:^(int code, NSString *desc) {
        NSLog(@"rk===>群组失败：%d---%@",code,desc);
    }];
    
}
/// 收到 RESTAPI 下发的自定义系统消息
- (void)onReceiveRESTCustomData:(NSString *)groupID data:(NSData *)data; {
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"收到消息%@",dict);
    NSString *method = minstr([dict valueForKey:@"method"]);
    if ([method isEqual:@"charge"]) {
       [[NSNotificationCenter defaultCenter] postNotificationName:@"userChargeSucess" object:dict];
   }
}

#pragma mark - 登录、登出
-(void)imLogin{
    
    [[V2TIMManager sharedInstance] login:[Config getOwnID] userSig:[Config lgetUserSign] succ:^{
        NSLog(@"IM登录success");
        //高级消息监听器
        [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
        // 加入群组
        [self joinGroup];
//        [[XGPushTokenManager defaultTokenManager] upsertAccountsByDict:@{@(0):[Config getOwnID]}];

    } fail:^(int code, NSString *desc) {
        // 如果返回以下错误码，表示使用 UserSig 已过期，请您使用新签发的 UserSig 进行再次登录。
        // 1. ERR_USER_SIG_EXPIRED（6206）
        // 2. ERR_SVR_ACCOUNT_USERSIG_EXPIRED（70001）
        // 注意：其他的错误码，请不要在这里调用登录接口，避免 IM SDK 登录进入死循环。
        [MBProgressHUD showError:YZMsg(@"IM登录失败，请重新登录")];
        NSLog(@"failure, code:%d, desc:%@", code, desc);
        [[YBToolClass sharedInstance] quitLogin];
    }];
}
-(void)imLogout; {
    
    [[V2TIMManager sharedInstance] logout:^{
        NSLog(@"success");
        NSLog(@"退出登录成功");
        [[V2TIMManager sharedInstance] removeAdvancedMsgListener:self];

    } fail:^(int code, NSString *desc) {
        NSLog(@"failure, code:%d, desc:%@", code, desc);
        NSLog(@"退出登录失败");

    }];
}

#pragma mark -  V2TIM 发送消息
-(void)sendV2ImMsg:(TMessageCellData *)msg andReceiver:(NSString *)receiverID complete:(ImSendV2MsgBlock)sendFinish{
    V2TIMMessage *timMsg =  [self transIMMsgFromUIMsg:msg];

    [[V2TIMManager sharedInstance]sendMessage:timMsg receiver:receiverID groupID:nil priority:V2TIM_PRIORITY_NORMAL onlineUserOnly:NO offlinePushInfo:nil progress:^(uint32_t progress) {
            
        } succ:^{
            if(sendFinish){
                sendFinish(YES,timMsg, @"发送成功");
                NSLog(@"imManagerSendTime---:%@ \n id:%@",timMsg.timestamp,timMsg.msgID);
            }
        } fail:^(int code, NSString *desc) {
            if(sendFinish){
                sendFinish(NO,timMsg, desc);
            }

        }];
}
#pragma mark -  V2TIM 发送自定义消息
-(void)sendV2CustomMsg:(V2TIMCustomElem *)customMsg andReceiver:(NSString *)receiverID complete:(ImSendV2MsgBlock)sendFinish{
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createCustomMessage:customMsg.data];
    
    [[V2TIMManager sharedInstance]sendMessage:message receiver:receiverID groupID:nil priority:V2TIM_PRIORITY_NORMAL onlineUserOnly:NO offlinePushInfo:nil progress:^(uint32_t progress) {
            
        } succ:^{
            if(sendFinish){
                sendFinish(YES,message, @"发送成功");
                NSLog(@"imManagerSendTime---:%@ \n id:%@",message.timestamp,message.msgID);
            }
        } fail:^(int code, NSString *desc) {
            if(sendFinish){
                sendFinish(NO,message, desc);
            }
        }];
}

#pragma mark -  V2TIM 收到新消息//高级消息监听
-(void)onRecvNewMessage:(V2TIMMessage *)msg complete:(ImRecevNewMsgBlock)newMsg{
    // NSLog(@"------wwwwww---%@",msg);
    WeakSelf;
    _tMsgCelldata = nil;

    // 解析出 groupID 和 userID
        NSString *groupID = msg.groupID;
        NSString *userID = msg.userID;
        // 判断当前是单聊还是群聊：
        // 如果 groupID 不为空，表示此消息为群聊；如果 userID 不为空，表示此消息为单聊
        if (msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
            if(msg.isSelf){
                TSystemMessageCellData *revoke = [[TSystemMessageCellData alloc] init];
                revoke.content = YZMsg(@"你撤回了一条消息");
                revoke.custom = msg;
                revoke.timestamp = msg.timestamp;
                _tMsgCelldata = revoke;
            }
            else{
                TSystemMessageCellData *revoke = [[TSystemMessageCellData alloc] init];
                revoke.content = YZMsg(@"对方撤回了一条消息");
                revoke.custom = msg;
                revoke.timestamp = msg.timestamp;
//                [rk_uiMsgs addObject:revoke];
                _tMsgCelldata = revoke;
            }
        }else if (msg.elemType == V2TIM_ELEM_TYPE_TEXT) {
            // 解析出 msg 中的文本消息
            V2TIMTextElem *textElem = msg.textElem;
            NSString *text = textElem.text;
            TTextMessageCellData *textData = [[TTextMessageCellData alloc] init];
            textData.content = text;
            _tMsgCelldata = textData;
            NSLog(@"onRecvNewMessage, text: %@", text);
        }else if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
            // 解析出 msg 中的自定义消息
            V2TIMCustomElem *customElem = msg.customElem;
            NSData *customData = customElem.data;
            NSLog(@"onRecvNewMessage, customData: %@", customData);
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:customData options:NSJSONReadingMutableContainers error:nil];
//            if ([dic valueForKey:@"method"]) {
//                if ([minstr([dic valueForKey:@"method"]) isEqual:@"GoodsMsg"]) {
//                    TGoodsCellData *goodsData = [[TGoodsCellData alloc]init];
//                    goodsData.goodsId = minstr([dic valueForKey:@"goodsid"]);
//                    data = goodsData;
//                }
//            }
            if ([dic valueForKey:@"method"]) {
                if ([minstr([dic valueForKey:@"method"]) isEqual:@"sendgift"]) {
                    TGiftMessageCellData *giftData = [[TGiftMessageCellData alloc]init];
                    giftData.giftName = minstr([dic valueForKey:@"giftname"]);
                    if (![lagType isEqual:ZH_CN] && ![YBToolClass checkNull:minstr([dic valueForKey:@"giftname_en"])]) {
                        giftData.giftName = minstr([dic valueForKey:@"giftname_en"]);
                    }
                    giftData.giftNum = minstr([dic valueForKey:@"giftcount"]);
                    giftData.giftIcon = minstr([dic valueForKey:@"gifticon"]);
                    _tMsgCelldata = giftData;
                   
                }
                if ([minstr([dic valueForKey:@"method"]) isEqual:@"call"]) {
                    int action = [minstr([dic valueForKey:@"action"]) intValue];
                    TCallCellData *callData = [[TCallCellData alloc]init];
                    callData.type = minstr([dic valueForKey:@"type"]);
                    switch (action) {
                        case 0:
                            if (msg.isSelf) {
                                callData.content = YZMsg(@"发起聊天");
                            }else{
                                callData.content = YZMsg(@"对方发起聊天");
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 1:
                            if (msg.isSelf) {
                                callData.content = YZMsg(@"已取消");
                            }else{
                                callData.content = YZMsg(@"对方已取消");
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 2:
                            if (msg.isSelf) {
                                callData.content = YZMsg(@"发起聊天");
                            }else{
                                callData.content = YZMsg(@"对方发起聊天");
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 3:
                            if (msg.isSelf) {
                                callData.content = YZMsg(@"已取消");
                            }else{
                                callData.content = YZMsg(@"对方已取消");
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 4:
                            if (msg.isSelf) {
                                callData.content = YZMsg(@"已接听");
                            }else{
                                callData.content = YZMsg(@"对方已接听");
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 5:
                            if (msg.isSelf) {
                                callData.content = YZMsg(@"已拒绝");
                            }else{
                                callData.content = YZMsg(@"对方已拒绝");
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 6:
                            if (msg.isSelf) {
                                callData.content = YZMsg(@"已接听");
                            }else{
                                callData.content = YZMsg(@"对方已接听");
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 7:
                            if (msg.isSelf) {
                                callData.content = YZMsg(@"已拒绝");
                            }else{
                                callData.content = YZMsg(@"对方已拒绝");
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 8:
                            if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([dic valueForKey:@"content_en"])]) {
                                callData.content = minstr([dic valueForKey:@"content_en"]);
                            }else{
                                callData.content = minstr([dic valueForKey:@"content"]);
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 9:
                            if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([dic valueForKey:@"content_en"])]) {
                                callData.content = minstr([dic valueForKey:@"content_en"]);
                            }else{
                                callData.content = minstr([dic valueForKey:@"content"]);
                            }
                            _tMsgCelldata = callData;

                            break;
                        case 10:
//                            continue;
                            break;
                        case 11:
//                            continue;
                            break;
                        case 12:
                            callData.content = YZMsg(@"匹配成功");
                            _tMsgCelldata = callData;

                            break;
                        case 110:
                            if ([lagType isEqual:EN] && ![YBToolClass checkNull:minstr([dic valueForKey:@"content_en"])]) {
                                callData.content = minstr([dic valueForKey:@"content_en"]);
                            }else{
                                callData.content = minstr([dic valueForKey:@"content"]);
                            }
                            _tMsgCelldata = callData;

                            break;
                            //ray end

                        default:
                            break;
                    }
                   
                }

            }

        }else if (msg.elemType == V2TIM_ELEM_TYPE_IMAGE) {

            V2TIMImageElem *imageElem = msg.imageElem;
            TImageMessageCellData *imageData = [[TImageMessageCellData alloc] init];
            imageData.path = imageElem.path;
            imageData.items = [NSMutableArray array];

            // 原图、大图、微缩图列表
            NSArray<V2TIMImage *> *imageList = imageElem.imageList;
            for (V2TIMImage *timImage in imageList) {
                
                TImageItem *itemData = [[TImageItem alloc] init];
                // 图片 ID，内部标识，可用于外部缓存 key
                NSString *uuid = timImage.uuid;
                itemData.uuid = uuid;

                // 图片类型
                //V2TIMImageType type = timImage.type;
                // 图片大小（字节）
                //int size = timImage.size;
                // 图片宽度
                int width = timImage.width;
                // 图片高度
                int height = timImage.height;
                
                itemData.size = CGSizeMake(width, height);
                itemData.url = timImage.url;
                if(timImage.type == V2TIM_IMAGE_TYPE_THUMB){
                    itemData.type = TImage_Type_Thumb;
                }
                else if(timImage.type == V2TIM_IMAGE_TYPE_LARGE){
                    itemData.type = TImage_Type_Large;
                }
                else if(timImage.type == V2TIM_IMAGE_TYPE_ORIGIN){
                    itemData.type = TImage_Type_Origin;
                }
                /*
                // 设置图片下载路径 imagePath，这里可以用 uuid 作为标识，避免重复下载
                NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"testImage%@", timImage.uuid]];
                // 判断 imagePath 下有没有已经下载过的图片文件
                if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                    // 下载图片
                    [timImage downloadImage:imagePath progress:^(NSInteger curSize, NSInteger totalSize) {
                        // 下载进度
                        NSLog(@"im===>[img]下载图片进度：curSize：%lu,totalSize:%lu",curSize,totalSize);
                    } succ:^{
                        // 下载成功
                        NSLog(@"im===>[img]下载图片完成");
                        imageData.thumbImage = [UIImage imageWithContentsOfFile:imagePath];

                    } fail:^(int code, NSString *msg) {
                        // 下载失败
                        NSLog(@"im===>[img]下载图片失败：code：%d,msg:%@",code,msg);
                    }];
                } else {
                    NSLog(@"im===>[img]图片存在");
                    // 图片已存在
                    imageData.thumbImage = [UIImage imageWithContentsOfFile:imagePath];
                }
                NSLog(@"图片信息：uuid:%@, type:%ld, size:%d, width:%d, height:%d", uuid, (long)type, size, width, height);
                */
                [imageData.items addObject:itemData];

            }
            _tMsgCelldata = imageData;

        }else if (msg.elemType == V2TIM_ELEM_TYPE_VIDEO) {
            //视频消息
            V2TIMVideoElem *videoElem = msg.videoElem;
            // 视频截图 ID,内部标识，可用于外部缓存 key
            NSString *snapshotUUID = videoElem.snapshotUUID;
            // 视频截图文件大小
            int snapshotSize = videoElem.snapshotSize;
            // 视频截图宽
            int snapshotWidth = videoElem.snapshotWidth;
            // 视频截图高
            int snapshotHeight = videoElem.snapshotHeight;
            // 视频 ID,内部标识，可用于外部缓存 key
            NSString *videoUUID = videoElem.videoUUID;
            // 视频文件大小
            int videoSize = videoElem.videoSize;
            // 视频时长
            int duration = videoElem.duration;
            // 设置视频截图文件路径，这里可以用 uuid 作为标识，避免重复下载
            NSString *snapshotPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"testVideoSnapshot%@",snapshotUUID]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:snapshotPath]) {
                // 下载视频截图
                [videoElem downloadSnapshot:snapshotPath progress:^(NSInteger curSize, NSInteger totalSize) {
                    // 下载进度
                    NSLog(@"%@", [NSString stringWithFormat:@"下载视频截图进度：curSize：%lu,totalSize:%lu",curSize,totalSize]);
                } succ:^{
                    // 下载成功
                    NSLog(@"下载视频截图完成");
                } fail:^(int code, NSString *msg) {
                    // 下载失败
                    NSLog(@"%@", [NSString stringWithFormat:@"下载视频截图失败：code：%d,msg:%@",code,msg]);
                }];
            } else {
                // 视频截图已存在
            }
            NSLog(@"视频截图信息：snapshotUUID:%@, snapshotSize:%d, snapshotWidth:%d, snapshotWidth:%d, snapshotPath:%@", snapshotUUID, snapshotSize, snapshotWidth, snapshotHeight, snapshotPath);

            // 设置视频文件路径，这里可以用 uuid 作为标识，避免重复下载
            NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"testVideo%@",videoUUID]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
                // 下载视频
                [videoElem downloadVideo:videoPath progress:^(NSInteger curSize, NSInteger totalSize) {
                    // 下载进度
                    NSLog(@"%@", [NSString stringWithFormat:@"下载视频进度：curSize：%lu,totalSize:%lu",curSize,totalSize]);
                } succ:^{
                    // 下载成功
                    NSLog(@"下载视频完成");
                } fail:^(int code, NSString *msg) {
                    // 下载失败
                    NSLog(@"%@", [NSString stringWithFormat:@"下载视频失败：code：%d,msg:%@",code,msg]);
                }];
            } else {
                // 视频已存在
            }
            NSLog(@"视频信息：videoUUID:%@, videoSize:%d, duration:%d, videoPath:%@", videoUUID, videoSize, duration, videoPath);
            
            TVideoMessageCellData *videoData = [[TVideoMessageCellData alloc] init];
            videoData.videoPath = videoElem.videoPath;
            videoData.snapshotPath = videoElem.snapshotPath;
            
            videoData.videoItem = [[TVideoItem alloc] init];
            videoData.videoItem.uuid = videoElem.videoUUID;
            videoData.videoItem.type = videoElem.videoType;
            videoData.videoItem.length = videoElem.videoSize;
            videoData.videoItem.duration = videoElem.duration;
            
            videoData.snapshotItem = [[TSnapshotItem alloc] init];
            videoData.snapshotItem.uuid = videoElem.snapshotUUID;
//            videoData.snapshotItem.type = videoElem.snapshot;
            videoData.snapshotItem.length = videoElem.snapshotSize;
            videoData.snapshotItem.size = CGSizeMake(videoElem.snapshotWidth, videoElem.snapshotHeight);
            _tMsgCelldata = videoData;

        }else if (msg.elemType == V2TIM_ELEM_TYPE_SOUND) {
            V2TIMSoundElem *soundElem = msg.soundElem;
            // 语音 ID,内部标识，可用于外部缓存 key
            NSString *uuid = soundElem.uuid;
            // 语音文件大小
            int dataSize = soundElem.dataSize;
            // 语音时长
            int duration = soundElem.duration;
            // 设置语音文件路径 soundPath，这里可以用 uuid 作为标识，避免重复下载
            NSString *soundPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"testSound%@",uuid]];
            // 判断 soundPath 下有没有已经下载过的语音文件
            if (![[NSFileManager defaultManager] fileExistsAtPath:soundPath]) {
                // 下载语音
                [soundElem downloadSound:soundPath progress:^(NSInteger curSize, NSInteger totalSize) {
                    // 下载进度
                    NSLog(@"下载语音进度：curSize：%lu,totalSize:%lu",curSize,totalSize);
                } succ:^{
                    // 下载成功
                    NSLog(@"下载语音完成");
                } fail:^(int code, NSString *msg) {
                    // 下载失败
                    NSLog(@"下载语音失败：code：%d,msg:%@",code,msg);
                }];
            } else {
                // 语音已存在
            }
            NSLog(@"语音信息：uuid:%@, dataSize:%d, duration:%d, soundPath:%@", uuid, dataSize, duration, soundPath);
            TVoiceMessageCellData *soundData = [[TVoiceMessageCellData alloc] init];
            soundData.duration = soundElem.duration;
            soundData.length = soundElem.dataSize;
            soundData.uuid = soundElem.uuid;
            _tMsgCelldata = soundData;

        }else if (msg.elemType == V2TIM_ELEM_TYPE_LOCATION) {
            V2TIMLocationElem *locationElem = msg.locationElem;
            // 地理位置信息描述
            NSString *desc = locationElem.desc;
            // 经度
            double longitude = locationElem.longitude;
            // 纬度
            double latitude = locationElem.latitude;
            NSLog(@"地理位置信息：desc：%@, longitude:%f, latitude:%f", desc, longitude, latitude);
//            TLocationMessageCellData *locatioData =[[TLocationMessageCellData alloc]init];
//            locatioData.latitude = [NSString stringWithFormat:@"%f",locationElem.latitude] ;
//            locatioData.longitude = [NSString stringWithFormat:@"%f",locationElem.longitude];
//            locatioData.desc = locationElem.desc;
//
//            data = locatioData;

        }else if (msg.elemType == V2TIM_ELEM_TYPE_FACE) {
            V2TIMFaceElem *faceElem = msg.faceElem;
            // 表情所在的位置
            int index = faceElem.index;
            // 表情自定义数据
            NSData *facedata = faceElem.data;
            NSLog(@"表情信息：index: %d, data: %@", index, facedata);
            
            TFaceMessageCellData *faceData = [[TFaceMessageCellData alloc] init];
            faceData.groupIndex = faceElem.index;
            faceData.faceName = [[NSString alloc] initWithData:faceElem.data encoding:NSUTF8StringEncoding];

            for (TFaceGroup *group in [[TUIKit sharedInstance] getConfig].faceGroups) {
                if(group.groupIndex == faceData.groupIndex){
                    NSString *path = [group.groupPath stringByAppendingPathComponent:faceData.faceName];
                    faceData.path = path;
                    break;
                }
            }
            _tMsgCelldata = faceData;
        }
    if(newMsg){
        _tMsgCelldata.custom = msg;
        newMsg(_tMsgCelldata);
    }
}
-(void)downLoad:(V2TIMImage *)v2imageDown ImgPath:(NSString *)path complete:(ImDownLoadImgBlock)downStatus{
                         // 下载图片
    [v2imageDown downloadImage:path progress:^(NSInteger curSize, NSInteger totalSize) {
        // 下载进度
        NSLog(@"下载图片进度：curSize：%lu,totalSize:%lu",curSize,totalSize);
    } succ:^{
        // 下载成功
        NSLog(@"下载图片完成");
        if(downStatus){
            downStatus(YES);
        }
    } fail:^(int code, NSString *msg) {
        // 下载失败
        NSLog(@"下载图片失败：code：%d,msg:%@",code,msg);
        if(downStatus){
            downStatus(NO);
        }

    }];

}
#pragma mark - 消息已读回执通知（如果自己发的消息支持已读回执，消息接收端调用了 sendMessageReadReceipts 接口，自己会收到该回调）
-(void)onRecvMessageReadReceipts:(NSArray<V2TIMMessageReceipt *> *)receiptList{
    
}

#pragma mark - C2C 对端用户会话已读通知（如果对端用户调用 markC2CMessageAsRead 接口，自己会收到该通知）
-(void)onRecvC2CReadReceipt:(NSArray<V2TIMMessageReceipt *> *)receiptList{
    
}

#pragma mark - 收到消息撤回
-(void)onRecvMessageRevoked:(NSString *)msgID{
    
}

#pragma mark - 消息内容被修改
- (void)onRecvMessageModified:(V2TIMMessage *)msg{
    
}
#pragma mark -获取所有会话列表
-(void)getAllConversationList:(ImGetConversationListBlock)covBlock{
    [[V2TIMManager sharedInstance] getConversationList:0
                                                 count:INT_MAX
                                                  succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {
        // 获取成功，list 为会话列表
        NSMutableArray *userArr = [NSMutableArray array];
        if (isFinished) {
            
            for (V2TIMConversation *conv in list) {
                if(conv.type == V2TIM_UNKNOWN){
                    continue;
                }
                //最后一条消息
                V2TIMMessage *lastMessage = [conv lastMessage];
                
                TConversationCellData *data = [[TConversationCellData alloc] init];
                data.unRead = [conv unreadCount];;
                data.subTitle = [self getLastDisplayString:lastMessage];
                if(conv.type == V2TIM_C2C){
                    data.head = TUIKitResource(@"default_head");
                }
                else if(conv.type == V2TIM_GROUP){
                    data.head = TUIKitResource(@"default_group");
                }
                
                data.convId = conv.userID;
                NSString *timest = [NSString stringWithFormat:@"%ld", (long)[lastMessage.timestamp timeIntervalSince1970]];
                data.timestamp = timest;
                NSLog(@"获取时间错==%@",timest);
                data.convType =conv.type;
                data.title = conv.showName;
               if ([data.convId isEqual:@"admin"]) {
                    data.time = [YBToolClass getDateDisplayString:lastMessage.timestamp];
                    [userArr insertObject:data atIndex:0];

                }else{
                    data.time = [YBToolClass getUserDateString:lastMessage.timestamp];
                    [userArr addObject:data];
                }
            }

            if(covBlock){
                covBlock(userArr, isFinished);
            }
        }
    } fail:^(int code, NSString *msg) {
        // 获取失败
        if(covBlock){
            covBlock(@[], code);
        }

    }];

}
#pragma mark -获取不包含粉丝、赞、艾特、评论的会话列表
-(void)getConversationList:(ImGetConversationListBlock)covBlock{
    [[V2TIMManager sharedInstance] getConversationList:0
                                                 count:INT_MAX
                                                  succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {
        // 获取成功，list 为会话列表
        NSMutableArray *userArr = [NSMutableArray array];
        if (isFinished) {
            
            for (V2TIMConversation *conv in list) {
                if(conv.type == V2TIM_UNKNOWN){
                    continue;
                }
                //最后一条消息
                V2TIMMessage *lastMessage = [conv lastMessage];
                
                TConversationCellData *data = [[TConversationCellData alloc] init];
                data.unRead = [conv unreadCount];;
                data.subTitle = [self getLastDisplayString:lastMessage];
                if(conv.type == V2TIM_C2C){
                    data.head = TUIKitResource(@"default_head");
                }
                else if(conv.type == V2TIM_GROUP){
                    data.head = TUIKitResource(@"default_group");
                }
                
                data.convId = conv.userID;
                NSString *timest = [NSString stringWithFormat:@"%ld", (long)[lastMessage.timestamp timeIntervalSince1970]];
                data.timestamp = timest;
                NSLog(@"获取时间错==%@",timest);
                data.convType =conv.type;
                data.title = conv.showName;
//                if(data.convType == TConv_Type_C2C){
//                    data.title = data.convId;
//                }else if(data.convType == TConv_Type_Group){
//                    data.title = conv.showName;
//                    continue;
//                }
                //rk_顶部红点
                if ([data.convId isEqual:@"dsp_fans"]) {
                    //粉丝
                    continue;
                }else if ([data.convId isEqual:@"dsp_like"]){
                    //赞
                    continue;
                }else if ([data.convId isEqual:@"dsp_at"]){
                    //@
                    continue;
                }else if ([data.convId isEqual:@"dsp_comment"]){
                    //评论
                    continue;
                }else if ([data.convId isEqual:@"admin"]) {
                    data.time = [YBToolClass getDateDisplayString:lastMessage.timestamp];
                    [userArr insertObject:data atIndex:0];

                }else{
                    data.time = [YBToolClass getUserDateString:lastMessage.timestamp];
                    [userArr addObject:data];
                }
            }

            if(covBlock){
                covBlock(userArr, isFinished);
            }
        }
    } fail:^(int code, NSString *msg) {
        // 获取失败
        if(covBlock){
            covBlock(@[], code);
        }

    }];

}
#pragma mark -获取指消息未读数 除去userlist用户 userlist为空则是返回所有消息未读数
-(void)getAllUnredNumExceptUser:(NSArray *)userList complete:(ImGetUnreadBlock)finish{
    if(userList && userList.count > 0){
       __block int unRead = 0;

        [[V2TIMManager sharedInstance]getConversationList:0 count:INT_MAX succ:^(NSArray<V2TIMConversation *> *list, uint64_t nextSeq, BOOL isFinished) {
            if(isFinished){
                // 获取成功，list 为会话列表
                NSMutableArray *userArr = [NSMutableArray arrayWithArray:list];
                
                for (V2TIMConversation *conv in list) {
                    if(conv.type == V2TIM_UNKNOWN){
                        continue;
                    }
                    for(NSString *userID in userList){
                        if ([conv.userID isEqual:userID]) {
                            [userArr removeObject:conv];
                        }
                    }
                }
                NSLog(@"immanager----userArr:%@",userArr);
                for (int i = 0; i < userArr.count; i ++) {
                    V2TIMConversation *conv = userArr[i];
                    int jjj = conv.unreadCount;
                    unRead += jjj;
                }
                if(finish){
                    finish(unRead);
                }

            }

        } fail:^(int code, NSString *desc) {
            
        }];
    }else{
        [[V2TIMManager sharedInstance] getTotalUnreadMessageCount:^(UInt64 totalCount) {
            // 获取成功，totalCount 为所有会话的未读消息总数
            // 更新 UI 上的未读数
            if(finish){
                finish((int)totalCount);
            }
        } fail:^(int code, NSString *desc) {
            // 获取失败
        }];

    }
}

#pragma mark -清空指定单聊会话的未读消息数
-(void)clearUnreadConvId:(NSString *)convid sendNot:(BOOL)send{
    [[V2TIMManager sharedInstance] markC2CMessageAsRead:convid // 待清空的单聊会话 ID
                                                   succ:^{
        // 清空成功
        // NSLog(@"clear  success");
    } fail:^(int code, NSString *msg) {
        // 清空失败
        NSLog(@"clear  fail");
    }];

}
#pragma mark -清空所有会话的未读消息数。
-(void)clearAllUnreadConv{
    [[V2TIMManager sharedInstance] markAllMessageAsRead:^{
        // 清空成功
        [MBProgressHUD showError:YZMsg(@"已忽略未读消息")];

    } fail:^(int code, NSString *desc) {
        // 清空失败
    }];

}


- (NSString *)getLastDisplayString:(V2TIMMessage *)lastMessage
{
    NSString *str = @"";
    if (lastMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        if(lastMessage.isSelf){
            return YZMsg(@"你撤回了一条消息");
        }
        else{
            return [NSString stringWithFormat:@"\"%@\"%@", YZMsg(@"对方"),YZMsg(@"撤回了一条消息")];
        }
    }else if(lastMessage.elemType == V2TIM_ELEM_TYPE_TEXT){
        
        NSString *text = lastMessage.textElem.text;
        str = text;
    }else if(lastMessage.elemType == V2TIM_ELEM_TYPE_CUSTOM){
        //自定义消息
//        V2TIMCustomElem *customElem =(V2TIMCustomElem *)lastMessage;
        NSData *customData = lastMessage.customElem.data;
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:customData options:NSJSONReadingMutableLeaves error:nil];
        if([minstr([jsonDict valueForKey:@"method"]) isEqual:@"GoodsMsg"]){
            str = YZMsg(@"[商品]");
        }else if([minstr([jsonDict valueForKey:@"method"]) isEqual:@"sendgift"]){
            str = YZMsg(@"[礼物]");
        }else if([minstr([jsonDict valueForKey:@"method"]) isEqual:@"call"]){
            str = YZMsg(@"[通话]");
        }
//        NSLog(@"onRecvNewMessage, customData: %@ \n str:%@", customData,receiveStr);

//        str = customElem.desc;
    }else if(lastMessage.elemType == V2TIM_ELEM_TYPE_IMAGE){
        //图片消息
        str = YZMsg(@"[图片]");
    }else if(lastMessage.elemType == V2TIM_ELEM_TYPE_SOUND){
        //语音消息
        str = YZMsg(@"[语音]");
    }else if(lastMessage.elemType == V2TIM_ELEM_TYPE_VIDEO){
        //视频消息
        str = YZMsg(@"[视频]");
    }else if(lastMessage.elemType == V2TIM_ELEM_TYPE_FACE){
        //表情消息
        str = @"[动画表情]";
    }else if(lastMessage.elemType == V2TIM_ELEM_TYPE_FILE){
        //文件消息
        str = @"[文件]";
    }else if(lastMessage.elemType == V2TIM_ELEM_TYPE_LOCATION){
        //位置消息
        str = @"[位置]";
    }
    return str;
}
+ (NSString *)getDateDisplayString:(NSDate *)date
{
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:date];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    
    NSDateComponents *comp =  [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    dateFmt.dateFormat = @"yyyy/MM/dd HH:mm:ss";

    return [dateFmt stringFromDate:date];
}
#pragma mark - 消息转换
- (V2TIMMessage *)transIMMsgFromUIMsg:(TMessageCellData *)data
{
    V2TIMMessage *msg = [[V2TIMMessage alloc] init];
    data.userHeader = [Config getavatar];
    
    if([data isKindOfClass:[TTextMessageCellData class]]){
        TTextMessageCellData *text = (TTextMessageCellData *)data;
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createTextMessage:text.content];
        msg = message;
    }
    else if([data isKindOfClass:[TFaceMessageCellData class]]){
        TFaceMessageCellData *image = (TFaceMessageCellData *)data;
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createFaceMessage:(int)image.groupIndex data:[image.faceName dataUsingEncoding:NSUTF8StringEncoding]];
        msg = message;
    }
    else if([data isKindOfClass:[TImageMessageCellData class]]){
        TImageMessageCellData *uiImage = (TImageMessageCellData *)data;

        // 创建图片消息
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createImageMessage:uiImage.path];
        msg = message;
    }
    else if([data isKindOfClass:[TVideoMessageCellData class]]){
        
        TVideoMessageCellData *uiVideo = (TVideoMessageCellData *)data;
        // 创建视频消息
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createVideoMessage:uiVideo.videoPath
                                                                             type:uiVideo.videoItem.type
                                                                         duration:(int)uiVideo.videoItem.duration
                                                                     snapshotPath:uiVideo.snapshotPath];
        msg = message;
    }
    else if([data isKindOfClass:[TVoiceMessageCellData class]]){
        TVoiceMessageCellData *uiSound = (TVoiceMessageCellData *)data;
        // 创建语音消息
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createSoundMessage:uiSound.path duration:uiSound.duration];
        msg = message;
    }
    else if([data isKindOfClass:[TFileMessageCellData class]]){
        TFileMessageCellData *uiFile = (TFileMessageCellData *)data;
        // 创建文件消息
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createFileMessage:uiFile.path fileName:uiFile.fileName];
        msg = message;
        
    }
//    else if([data isKindOfClass:[TGiftMessageCellData class]]){
//        TIMCustomElem *imFile = [[TIMCustomElem alloc] init];
//        TGiftMessageCellData *gift = (TGiftMessageCellData *)data;
//        imFile.data = gift.data;
//
//        [msg addElem:imFile];
//    }
//    else if([data isKindOfClass:[TGoodsCellData class]]){
//        TGoodsCellData *imGoods = (TGoodsCellData *)data;
//        V2TIMMessage *message = [[V2TIMManager sharedInstance] createCustomMessage:imGoods.data];
//        msg = message;
//
//    }

//    else if ([data isKindOfClass:[TLocationMessageCellData class]]){
//        TLocationMessageCellData *uiLocation = (TLocationMessageCellData *)data;
//        // 创建定位消息
//        V2TIMMessage *message = [[V2TIMManager sharedInstance] createLocationMessage:uiLocation.desc longitude:[uiLocation.longitude doubleValue] latitude:[uiLocation.latitude doubleValue]];
//        msg = message;
//    }
    return msg;
    
}
-(void)sendClearNot {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMCancelunread object:nil];
}

-(TConversationCellData *)createEmptyCellDataWithId:(NSString *)convid {
    TConversationCellData *data = [[TConversationCellData alloc] init];
    data.subTitle = @"";
    data.unRead = 0;
//    data.lastConv = nil;
    data.head = TUIKitResource(@"default_group");
    data.convId = convid;
    NSDate *nowDate = [NSDate date];
    NSString *timest = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
    data.timestamp = timest;
    data.convType = TConv_Type_C2C;
    data.title = data.convId;
    data.time = [YBToolClass getDateDisplayString:nowDate];
    return data;
}


//********************以下暂时不用***************************/
///// 播放、停止响铃
//-(void)playAudioCall; {
//    if (_ringPlayer) {
//        [_ringPlayer pause];
//        _ringPlayer = nil;
//    }
//    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"ring" withExtension:@"mp3"];
//    _ringPlayer = [[AVPlayer alloc] initWithURL:fileURL];
//    _ringPlayer.volume = 1.0;
//    [_ringPlayer play];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeyEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//}
///// 播放结束
//-(void)playeyEnd:(NSNotification*)notify{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    [self playAudioCall];
//}
//-(void)stopAudioCall; {
//    if (_ringPlayer) {
//        [_ringPlayer pause];
//        _ringPlayer = nil;
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    }
//}
//
/// 消息提示
//- (void)tryPlayMsgAlertWithSenderid:(NSString *)senderUid{
//    NSString *chatUid = strFormat([[NSUserDefaults standardUserDefaults] objectForKey:ybImChatingUid]);
//    BOOL iscall = [[NSUserDefaults standardUserDefaults] boolForKey:ybIsStartCallKey];
//    BOOL onRoom = [[NSUserDefaults standardUserDefaults] boolForKey:ybMatchRoomCtrKey];
//    if ([senderUid isEqual:chatUid] || iscall || onRoom || ![YBCommon voiceSwitch]) {
//        NSLog(@"不需要提示音");
//        return;
//    }
//    NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"messageVioce" withExtension:@"mp3"];
//    SystemSoundID soundID;
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl,&soundID);
//    AudioServicesPlaySystemSound(soundID);
//}

////收到邀请展示本地推送
//- (void)showLocalPush:(NSDictionary *)dic{
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//    // 标题
//    content.title = YZMsg(@"通话邀请");
//    content.subtitle = @"";
//    // 内容
//    content.body = [NSString stringWithFormat:@"%@%@%@%@",minstr([dic valueForKey:@"user_nickname"]),YZMsg(@"向你发起"),[minstr([dic valueForKey:@"type"]) intValue] == 1 ? YZMsg(@"视频"):YZMsg(@"语音"),YZMsg(@"通话邀请")];
//    // 添加通知的标识符，可以用于移除，更新等操作
//    NSString *identifier = @"noticeId";
//    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:nil];
//
//    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
//        NSLog(@"成功添加推送");
//    }];
//
//}

@end

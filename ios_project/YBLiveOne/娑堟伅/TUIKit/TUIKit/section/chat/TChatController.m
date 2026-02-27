//
//  TChatController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TChatController.h"
#import "THeader.h"
#import "TZImagePickerController.h"
#import "TImageMessageCell.h"
#import "ImageViewController.h"
#import "InvitationViewController.h"
#import "liwuview.h"
#import "PersonMessageViewController.h"
//#import "TIMManager.h"
//#import "TIMConversation+MsgExt.h"
#import "continueGift.h"
#import "expensiveGiftV.h"//礼物
#import "RechargeViewController.h"
#import "VIPViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ReportUserVC.h"
#import "YBScrollImageView.h"
#import "YBRAlertView.h"
#import "AuthenticateVC.h"
#import "TUIKit.h"
#import "TMoreCell.h"
#import "YBLiveSocket.h"

@interface TChatController () <TMessageControllerDelegate, TInputControllerDelegate,TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,sendGiftDelegate,haohuadelegate>{
    liwuview *giftView;
    UIButton *giftZheZhao;
    expensiveGiftV *haohualiwuV;//豪华礼物
    continueGift *continueGifts;//连送礼物
    UIView *liansongliwubottomview;
    YBAlertView *alert;
    NSDictionary *headerDic;
    int isAuth;

}
@property (nonatomic,strong)YBRAlertView *alert;

@property(nonatomic,strong)UIView *topAttentView;

@end

@implementation TChatController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSMutableArray *moreMenus = [NSMutableArray array];
    TMoreCellData *picture = [[TMoreCellData alloc] init];
    picture.title = YZMsg(@"相册");
    picture.path = TUIKitResource(@"more_picture");
    [moreMenus addObject:picture];

    TMoreCellData *camera = [[TMoreCellData alloc] init];
    camera.title = YZMsg(@"拍摄");
    camera.path = TUIKitResource(@"more_camera");
    [moreMenus addObject:camera];

    if (![[YBYoungManager shareInstance]isOpenYoung]) {
        TMoreCellData *gift = [[TMoreCellData alloc] init];
        gift.title = YZMsg(@"礼物");
        gift.path = TUIKitResource(@"more_gift");
        [moreMenus addObject:gift];

        TMoreCellData *video = [[TMoreCellData alloc] init];
        video.title = YZMsg(@"视频通话");
        video.path = TUIKitResource(@"more_video");
        [moreMenus addObject:video];
        
        TMoreCellData *audio = [[TMoreCellData alloc] init];
        audio.title = YZMsg(@"语音通话");
        audio.path = TUIKitResource(@"more_audio");
        [moreMenus addObject:audio];
    }
    [[TUIKit sharedInstance] getConfig].moreMenus = moreMenus;

    [_inputController.moreView setData:[[TUIKit sharedInstance] getConfig].moreMenus];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:nil];
    [self.view addGestureRecognizer:pan];

    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"ismessageing"];
    [[NSUserDefaults standardUserDefaults] setObject:_conversation.convId forKey:@"messageingUserID"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChatGiftEvent:) name:ybReceiveChatGiftEvent object:nil];

    self.titleL.text = _conversation.userName;
    self.rightBtn.hidden = NO;
    [self.rightBtn setImage:[UIImage imageNamed:@"三点"] forState:UIControlStateNormal];
    if ([_conversation.isVIP isEqual:@"1"] && ![YBToolClass isUp]) {
        UIImageView *vip = [[UIImageView alloc]init];
        vip.image = [UIImage imageNamed:@"vip"];
        [self.naviView addSubview:vip];
        [vip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleL.mas_right).offset(3);
            make.centerY.equalTo(self.titleL);
            make.width.mas_equalTo(25);
            make.height.mas_equalTo(15);
        }];
    }

    if(_uiFrom != Live_Im_Samll){
        [self setupViews];
    }
}

-(void)receiveChatGiftEvent:(NSNotification *)noti {
    NSDictionary *giftDic = noti.userInfo;
    [self reciveGiftMessage:giftDic];
}
- (void)setupViews {

    //message
    _messageController = [[TMessageController alloc] init];
    _messageController.uiFrom = _uiFrom;
    _messageController.view.frame = CGRectMake(0, 64+statusbarHeight, _window_width, _window_height - TTextView_Height - Bottom_SafeHeight-(64+statusbarHeight));
    _messageController.delegate = self;
    [self addChildViewController:_messageController];
    [self.view addSubview:_messageController.view];
    [_messageController setConversation:_conversation];
    if (![_conversation.convId isEqual:@"admin"]) {
        //input
        _inputController = [[TInputController alloc] init];
        _inputController.view.frame = CGRectMake(0, _window_height - TTextView_Height - Bottom_SafeHeight, _window_width, TTextView_Height + Bottom_SafeHeight);
        _inputController.uiFrom = _uiFrom;
        _inputController.delegate = self;
        [self addChildViewController:_inputController];
        [self.view addSubview:_inputController.view];
        
        liansongliwubottomview = [[UIView alloc]init];
        liansongliwubottomview.userInteractionEnabled = NO;
        [self.view addSubview:liansongliwubottomview];
        liansongliwubottomview.frame = CGRectMake(0, statusbarHeight + 140,300,140);
        
        if(_uiFrom == Live_Im_Samll){
            // 只有小窗口有关注
            [self.view addSubview:self.topAttentView];
            _topAttentView.hidden = [_conversation.isAtt intValue];;
            [_topAttentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.centerX.equalTo(self.view);
                make.top.equalTo(self.view.mas_top).offset(0);
                make.height.mas_equalTo(50);
            }];
        }
        
    }else{
        self.rightBtn.hidden = YES;
        _messageController.view.frame = CGRectMake(0, 64+statusbarHeight, _window_width, _window_height - Bottom_SafeHeight-(64+statusbarHeight));
    }

}
- (void)doPersonMessage{
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":_conversation.convId} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *subDic = [info firstObject];
            PersonMessageViewController *person = [[PersonMessageViewController alloc]init];
            person.liveDic = subDic;
            [[YBAppDelegate sharedAppDelegate] pushViewController:person animated:YES];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
- (void)doFollow{
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"User.SetAttent" andParameter:@{@"touid":_conversation.convId} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSString * isattention = minstr([infoDic valueForKey:@"isattent"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:ybPersonFollowEvent object:isattention];
            if(_uiFrom == Live_Im_Samll){
                // 改变状态
                NSDictionary *notiDic = @{
                    @"isattention":isattention,
                };
                [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Attention object:nil userInfo:notiDic];
                // socket
                // yb_lang
                NSString *socStr = [[Config getOwnNicename] stringByAppendingFormat:@"关注了主播"];
                NSString *socStrEn = [[Config getOwnNicename] stringByAppendingFormat:@" followed the anchor"];
                [[YBLiveSocket shareInstance]socketSendSystem:socStr conStrEn:socStrEn];
            }
            if ([isattention isEqual:@"1"]) {
                _conversation.isAtt = @"1";
                if(_topAttentView){
                    _topAttentView.hidden = YES;
                }
            }else{
                _conversation.isAtt = @"0";
                if(_topAttentView){
                    _topAttentView.hidden = NO;
                }
            }
        }

        [MBProgressHUD showError:msg];
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
- (void)doSetBlack{
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"User.SetBlack" andParameter:@{@"touid":_conversation.convId} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"isblack"]) isEqual:@"1"]) {
                _conversation.isblack = @"1";
            }else{
                _conversation.isblack = @"0";
            }
        }
        
        [MBProgressHUD showError:msg];
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
- (void)rightBtnClick{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"查看TA的主页") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doPersonMessage];
    }];
    [cancleAction setValue:color32 forKey:@"_titleTextColor"];

//    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"清除聊天记录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [action2 setValue:RGB_COLOR(@"#ff6262", 1) forKey:@"_titleTextColor"];
//    [alertContro addAction:action2];
    NSString *attStr;
    if ([_conversation.isAtt isEqualToString:@"1"]) {
        attStr = YZMsg(@"取消关注");
    }else{
        attStr = YZMsg(@"关注");
    }
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:attStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doFollow];
    }];
    [action3 setValue:color32 forKey:@"_titleTextColor"];

    NSString *blackStr;
    if ([_conversation.isblack isEqualToString:@"1"]) {
        blackStr = YZMsg(@"解除拉黑");
    }else{
        blackStr = YZMsg(@"拉黑");
    }

    UIAlertAction *action4 = [UIAlertAction actionWithTitle:blackStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doSetBlack];
    }];
    [action4 setValue:color32 forKey:@"_titleTextColor"];

    UIAlertAction *action5 = [UIAlertAction actionWithTitle:YZMsg(@"举报") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doReport];

    }];
    [action5 setValue:color32 forKey:@"_titleTextColor"];

    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [sureAction setValue:color96 forKey:@"_titleTextColor"];
    if ([_conversation.isauth isEqual:@"1"]) {
        [alertContro addAction:cancleAction];
        [alertContro addAction:action3];
    }
    [alertContro addAction:action4];
    [alertContro addAction:action5];
    [alertContro addAction:sureAction];

    [self presentViewController:alertContro animated:YES completion:nil];

}
//举报
-(void)doReport{
    ReportUserVC *report = [[ReportUserVC alloc]init];
    report.touid =_conversation.convId;
    [[YBAppDelegate sharedAppDelegate]pushViewController:report animated:YES];
}

- (void)doReturn{
    if (haohualiwuV) {
        haohualiwuV.delegate = nil;
        [haohualiwuV stopHaoHUaLiwu];
        [haohualiwuV removeFromSuperview];
        haohualiwuV = nil;
    }
    if (continueGifts) {
        [continueGifts removeFromSuperview];
        continueGifts = nil;
    }

    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"ismessageing"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"messageingUserID"];

    [[YBImManager shareInstance]clearUnreadConvId:_conversation.convId sendNot:YES];

//    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMCancelunread object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inputController:(TInputController *)inputController didChangeHeight:(CGFloat)height{
    CGFloat navSpace = naviHight;
    if (_uiFrom == Live_Im_Samll) {
        navSpace = 0;
    }
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = _messageController.view.frame;
        msgFrame.size.height = self.view.frame.size.height - height-navSpace;
        //未知原因-19.6,这里重置一下起始位置
        msgFrame.origin.y = navSpace;
        _messageController.view.frame = msgFrame;
        CGRect inputFrame = _inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        _inputController.view.frame = inputFrame;
        [_messageController scrollToBottom:NO];
        //NSLog(@"rk=========================ani:%@",_messageController.view);
    } completion:^(BOOL finished) {
        //NSLog(@"rk=========================finishi\n===:%@\n===%@",_messageController.view,_inputController.view);
    }];
    /*
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = ws.messageController.view.frame;
        msgFrame.size.height = ws.view.frame.size.height - height-64-statusbarHeight;
        ws.messageController.view.frame = msgFrame;
//        if (ws.messageController.view.height >= _window_height - TTextView_Height - Bottom_SafeHeight-(64+statusbarHeight)) {
//            ws.messageController.view.height = _window_height - TTextView_Height - Bottom_SafeHeight-(64+statusbarHeight);
//            msgFrame = ws.messageController.view.frame;
//
//        }
        CGRect inputFrame = ws.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        ws.inputController.view.frame = inputFrame;
        [ws.messageController scrollToBottom:NO];
    } completion:nil];
    */
}
-(void)inputResetHeight
{
    [_inputController reset];

}

- (void)inputController:(TInputController *)inputController didSendMessage:(TMessageCellData *)msg
{
    [self checkBlack:msg];
}

- (void)inputController:(TInputController *)inputController didSelectMoreAtIndex:(NSInteger)index
{
    NSLog(@"----------%ld",index);
    [_inputController reset];
    if (index == 0) {
        TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
        imagePC.preferredLanguage = [lagType isEqual:ZH_CN] ? @"zh-Hans":@"en";
        imagePC.allowCameraLocation = YES;
        imagePC.allowTakeVideo = NO;
        imagePC.allowPickingVideo = NO;
        imagePC.doneBtnTitleStr = YZMsg(@"发送");
        imagePC.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:imagePC animated:YES completion:nil];
    }else if (index == 1){
        
        if([[YBYoungManager shareInstance] isOpenYoung]){
            //拍摄
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.cameraCaptureMode =UIImagePickerControllerCameraCaptureModePhoto;
            picker.delegate = self;
            picker.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:picker animated:YES completion:nil];
            
        }else {
            //语音通话
            if ([YBToolClass checkAudioAuthorization] == 2) {
                //弹出麦克风权限
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            [self sendVideoOrAudio:@"2"];
                        }else{
                            [MBProgressHUD showError:YZMsg(@"未允许麦克风权限，不能语音通话")];
                        }
                    });
                }];
            }else{
                if ([YBToolClass checkAudioAuthorization] == 1) {
                    [self sendVideoOrAudio:@"2"];
                }else{
                    [MBProgressHUD showError:YZMsg(@"请前往设置中打开麦克风权限")];
                    return;
                }
                
            }
        }

    }else if (index == 2){
        //拍摄
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode =UIImagePickerControllerCameraCaptureModePhoto;
        picker.delegate = self;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:picker animated:YES completion:nil];

    }else if (index == 4){
        //礼物
       
        if ([_conversation.isauth isEqual:@"1"]) {
            [self doliwu];
        }else{
            [MBProgressHUD showError:YZMsg(@"对方未认证")];
        }
    }else if (index == 6){
        //视频通话
//
        if ([YBToolClass checkVideoAuthorization] == 2) {
            //弹出相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self checkYuyinQuanxian];
                    }else{
                        [MBProgressHUD showError:YZMsg(@"未允许摄像头权限，不能视频通话")];
                    }
                });
                
            }];
        }else{
            if ([YBToolClass checkVideoAuthorization] == 1) {
                [self checkYuyinQuanxian];
            }else{
                [MBProgressHUD showError:YZMsg(@"请前往设置中打开摄像头权限")];
            }
        }

    }
//    if(_delegate && [_delegate respondsToSelector:@selector(chatController:didSelectMoreAtIndex:)]){
//        [_delegate chatController:self didSelectMoreAtIndex:index];
//    }
}
- (void)checkYuyinQuanxian{
    if ([YBToolClass checkAudioAuthorization] == 2) {
        //弹出麦克风权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self sendVideoOrAudio:@"1"];
                }else{
                    [MBProgressHUD showError:YZMsg(@"未允许麦克风权限，不能视频通话")];
                }
            });
        }];
    }else{
        if ([YBToolClass checkAudioAuthorization] == 1) {
            [self sendVideoOrAudio:@"1"];
        }else{
            [MBProgressHUD showError:YZMsg(@"请前往设置中打开麦克风权限")];
            return;
        }
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    for (int i = 0;i < photos.count;i++) {
        UIImage *img = photos[i];
        [self sendImageMessage:img andIndex:i];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageOrientation imageOrientation=  image.imageOrientation;
        if(imageOrientation != UIImageOrientationUp)
        {
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        [self sendImageMessage:image andIndex:0];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)didTapInMessageController:(TMessageController *)controller
{
    [_inputController reset];
}

- (BOOL)messageController:(TMessageController *)controller willShowMenuInCell:(TMessageCell *)cell
{
    if([_inputController.textView.inputTextView isFirstResponder]){
        _inputController.textView.inputTextView.overrideNextResponder = cell;
        return YES;
    }
    return NO;
}

- (void)didHideMenuInMessageController:(TMessageController *)controller
{
    _inputController.textView.inputTextView.overrideNextResponder = nil;
}

- (void)messageController:(TMessageController *)controller didSelectMessages:(NSMutableArray *)msgs atIndex:(NSInteger)index
{
    TMessageCellData *currentdata = msgs[index];

    NSMutableArray *imgarr = [NSMutableArray array];
    NSInteger currentIndex = 0;
    for (int i = 0; i < msgs.count; i ++) {
        TMessageCellData *data = msgs[i];
        if([data isKindOfClass:[TImageMessageCellData class]]){
            TImageMessageCellData *imgData = (TImageMessageCellData *)data;
            if (imgData.thumbImage) {
                [imgarr addObject:imgData.thumbImage];
            }
        }
    }
    for (int k = 0; k < imgarr.count; k ++) {
        TImageMessageCellData *imgDatass = (TImageMessageCellData *)currentdata;
        UIImage *currentimg = imgarr[k];
        if (imgDatass.thumbImage == currentimg) {
            currentIndex = k;
            break;
        }
    }

    //NSLog(@"==-=-=-=-=-=-=-=-=-=:::%@", imgarr);
    YBScrollImageView *imgView = [[YBScrollImageView alloc] initWithImageArray:imgarr andIndex:currentIndex andMine:NO isCanScrol:YES andBlock:^(NSArray * _Nonnull array) {
    }];
    [imgView hideDelete];
    [[UIApplication sharedApplication].keyWindow addSubview:imgView];

//    TMessageCellData *data = msgs[index];
//    if([data isKindOfClass:[TImageMessageCellData class]]){
//        ImageViewController *image = [[ImageViewController alloc] init];
//        image.data = (TImageMessageCellData *)data;
//        [self presentViewController:image animated:YES completion:nil];
//    }

//    if(_delegate && [_delegate respondsToSelector:@selector(chatController:didSelectMessages:atIndex:)]){
//        [_delegate chatController:self didSelectMessages:msgs atIndex:index];
//    }
}

- (void)sendImageMessage:(UIImage *)image andIndex:(int)index;
{
    [self checkBlack:image];
}

- (void)sendVideoMessage:(NSURL *)url
{
    [_messageController sendVideoMessage:url];
}

- (void)sendFileMessage:(NSURL *)url
{
    [_messageController sendFileMessage:url];
}
#pragma mark ============gift=============
- (void)doliwu{
    if (!giftView) {
        NSDictionary *dic = @{@"uid":_conversation.convId,@"showid":@"0"};
        giftView = [[liwuview alloc]initWithDic:dic andMyDic:nil];
        giftView.giftDelegate = self;
        giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
        [self.view addSubview:giftView];
        giftZheZhao = [UIButton buttonWithType:0];
        giftZheZhao.frame = CGRectMake(0, 0, _window_width, _window_height-(_window_width/2+100+ShowDiff));
        [giftZheZhao addTarget:self action:@selector(giftZheZhaoClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:giftZheZhao];
        giftZheZhao.hidden = YES;
    }
    [UIView animateWithDuration:0.2 animations:^{
        giftView.frame = CGRectMake(0,_window_height-(_window_width/2+100+ShowDiff), _window_width, _window_width/2+100+ShowDiff);
    } completion:^(BOOL finished) {
        giftZheZhao.hidden = NO;
    }];

}
- (void)giftZheZhaoClick{
    giftZheZhao.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
    } completion:^(BOOL finished) {
    }];
    
}

-(void)sendGiftSuccess:(NSMutableDictionary *)playDic{
//    [_messageController sendCustomMessage:playDic];
//    NSString *type = minstr([playDic valueForKey:@"type"]);
//    
//    if (!continueGifts) {
//        continueGifts = [[continueGift alloc]initWithFrame:CGRectMake(0, 0, liansongliwubottomview.width, liansongliwubottomview.height)];
//        [liansongliwubottomview addSubview:continueGifts];
//        //初始化礼物空位
//        [continueGifts initGift];
//    }
//    if ([type isEqual:@"1"]) {
//        [self expensiveGift:playDic];
//    }
//    else{
//        [continueGifts GiftPopView:playDic andLianSong:@"Y"];
//    }

}
- (void)pushCoinV{
    RechargeViewController *recharge = [[RechargeViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:recharge animated:YES];
}

/************ 礼物弹出及队列显示开始 *************/
-(void)expensiveGiftdelegate:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        [self.view addSubview:haohualiwuV];
    }
    if (giftData == nil) {
        
        
    }
    else
    {
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }
}
-(void)expensiveGift:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        [self.view addSubview:haohualiwuV];
    }
    if (giftData == nil) {}else{
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }
}
- (void)reciveGiftMessage:(NSDictionary *)giftDic{
    NSString *type = minstr([giftDic valueForKey:@"type"]);
    
    if (!continueGifts) {
        continueGifts = [[continueGift alloc]initWithFrame:CGRectMake(0, 0, liansongliwubottomview.width, liansongliwubottomview.height)];
        [liansongliwubottomview addSubview:continueGifts];
        //初始化礼物空位
        [continueGifts initGift];
    }
    if ([type isEqual:@"1"]) {
        [self expensiveGift:giftDic];
    }
    else{
        [continueGifts GiftPopView:giftDic andLianSong:@"Y"];
    }

}
#pragma mark ============视频语音通话=============
- (void)sendVideoOrAudio:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"token=%@&touid=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",[Config getOwnToken],_conversation.convId,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.checkstatus" andParameter:@{@"touid":_conversation.convId,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"status"]) isEqual:@"0"]) {
                [self userInvitationAnchor:type];
            }else{
                [self anchorInvitationlUser:type];
            }
            
        }else if(code == 1002){
            //自己与对方都未认证
            [self messagetip:type];
        }
        else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
}
-(void)messagetip:(NSString *)type{
    NSString *tistr = YZMsg(@"您未认证，暂不支持视频通话");
    if ([type isEqual:@"2"]) {
        tistr = YZMsg(@"您未认证，暂不支持语音通话");
    }
    WeakSelf;
    if (!_alert) {
        _alert = [[YBRAlertView alloc]initWithTitle:YZMsg(@"提示") Msg:tistr LeftMsg:YZMsg(@"取消") RightMsg:YZMsg(@"去认证") PlaceHodler:YZMsg(@"") Style:YBAlertNormal];

        [self.view addSubview:_alert];
        _alert.actionEvent = ^(NSString * _Nonnull type, NSString * _Nonnull tipstr) {
            [weakSelf.alert removeFromSuperview];
            weakSelf.alert = nil;
        if([type isEqual:@"1"]){
             [weakSelf requestData];
         }
        };
    }
    
    
}
- (void)requestData{
    [self getOldAuthMessage];
//    WeakSelf;
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地 build
//    //NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];version
//    //NSLog(@"当前应用软件版本:%@",appCurVersion);
//    NSString *build = [NSString stringWithFormat:@"%@",app_build];
//
//    [YBToolClass postNetworkWithUrl:@"User.GetBaseInfo" andParameter:@{@"ios_version":build} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        if (code == 0) {
//            headerDic = [info firstObject];
//
//            isAuth = [minstr([headerDic valueForKey:@"isauth"]) intValue];
//            if (isAuth == 0) {
//                //未认证
////                [self authclic:nil];
//                [weakSelf getOldAuthMessage];
//            }else if (isAuth == 1){
//                [MBProgressHUD showError:YZMsg(@"您的认证资料正在飞速审核中")];
//            }else if (isAuth == 3){
//                [MBProgressHUD showError:YZMsg(@"认证失败，请重新认证")];
//                [weakSelf getOldAuthMessage];
////                if ([minstr([headerDic valueForKey:@"oldauth"]) isEqual:@"1"]) {
////                    [self getOldAuthMessage];
////                }else{
////                    [self authclic:nil];
////                }
//            }
//
//        }
//
//    } fail:^{
//
//    }];
}

- (void)getOldAuthMessage{
    AuthenticateVC *auth = [[AuthenticateVC alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];

}
-(void)authclic:(NSDictionary *)dic{
    AuthenticateVC *auth = [[AuthenticateVC alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];
}
- (void)userInvitationAnchor:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",_conversation.convId,[Config getOwnToken],type,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.Checklive" andParameter:@{@"liveuid":_conversation.convId,@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"0",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":type,
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID]
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            V2TIMCustomElem * custom_elem = [[V2TIMCustomElem alloc] init];
            [custom_elem setData:data];
            WeakSelf;
            [[YBImManager shareInstance]sendV2CustomMsg:custom_elem andReceiver:_conversation.convId complete:^(BOOL isSuccess, V2TIMMessage *sendMsg, NSString *desc) {
                if(isSuccess){
                    NSLog(@"SendMsg Succ");
                    [weakSelf showWaitView:infoDic andType:type];
                    NSArray *objA = [NSArray arrayWithObject:msg];
                    [[NSNotificationCenter defaultCenter]postNotificationName:ybImNeedRefresh object:objA];
                }else{
                    [MBProgressHUD showError:YZMsg(@"消息发送失败")];
                    [MBProgressHUD showError:YZMsg(@"消息发送失败")];
                    [weakSelf sendMessageFaild:infoDic andType:type];
                }
            }];
        }else if(code == 800){
            [self showYuyue:type andMessage:msg];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];

}
- (void)showYuyue:(NSString *)type andMessage:(NSString *)msg{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"预约") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self SetSubscribe:type];
    }];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];
    
}
- (void)SetSubscribe:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr(_conversation.convId),[Config getOwnToken],type,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Subscribe.SetSubscribe" andParameter:@{@"liveuid":minstr(_conversation.convId),@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    } fail:^{
    }];
    
}

- (void)anchorInvitationlUser:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"token=%@&touid=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",[Config getOwnToken],_conversation.convId,type,[Config getOwnID]]];
    
    [YBToolClass postNetworkWithUrl:@"Live.anchorLaunch" andParameter:@{@"touid":_conversation.convId,@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"2",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":minstr([infoDic valueForKey:@"type"]),
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID],
                                  @"total":minstr([infoDic valueForKey:@"total"])
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            V2TIMCustomElem * custom_elem = [[V2TIMCustomElem alloc] init];
            [custom_elem setData:data];
            WeakSelf;
            [[YBImManager shareInstance]sendV2CustomMsg:custom_elem andReceiver:_conversation.convId complete:^(BOOL isSuccess, V2TIMMessage *sendMsg, NSString *desc) {
                if(isSuccess){
                    NSLog(@"SendMsg Succ");
                    [weakSelf showWaitView:infoDic andType:minstr([infoDic valueForKey:@"type"]) andModel:nil];
                    NSArray *objA = [NSArray arrayWithObject:msg];
                    [[NSNotificationCenter defaultCenter]postNotificationName:ybImNeedRefresh object:objA];
                }else{
                    NSLog(@"SendMsg Failed:%d->%@", code, desc);
                    [MBProgressHUD showError:YZMsg(@"消息发送失败")];
                }
            }];

        }else if(code == 800){
            [self showYuyue:type andMessage:msg];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];

}
- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type andModel:(id )model{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:_conversation.convId forKey:@"id"];
    [muDic setObject:_conversation.userHeader forKey:@"avatar"];
    [muDic setObject:_conversation.userName forKey:@"user_nickname"];
    [muDic setObject:_conversation.level_anchor forKey:@"level_anchor"];
    if ([type isEqual:@"1"]) {
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"video_value"];
    }else{
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"voice_value"];
    }
    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue]+4 andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:navi animated:YES completion:nil];
    
}

- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:_conversation.convId forKey:@"id"];
    [muDic setObject:_conversation.userHeader forKey:@"avatar"];
    [muDic setObject:_conversation.userName forKey:@"user_nickname"];
    [muDic setObject:_conversation.level_anchor forKey:@"level_anchor"];
    if ([type isEqual:@"1"]) {
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"video_value"];
    }else{
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"voice_value"];
    }
    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue] andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:navi animated:YES completion:nil];
    
}
- (void)sendMessageFaild:(NSDictionary *)infoDic andType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",_conversation.convId,minstr([infoDic valueForKey:@"showid"]),[Config getOwnToken],[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.UserHang" andParameter:@{@"liveuid":_conversation.convId,@"showid":minstr([infoDic valueForKey:@"showid"]),@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    } fail:^{
    }];
    
}


- (void)checkBlack:(id)datamsg{
    [YBToolClass postNetworkWithUrl:@"Im.Check" andParameter:@{@"touid":_conversation.convId} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        _inputController.menuView.sendButton.userInteractionEnabled = YES;
        if (code == 0) {
            [_inputController.textView clearInput];
            if ([datamsg isKindOfClass:[UIImage class]]) {
                [_messageController sendImageMessage:datamsg andIndex:0];
            }else{
                [_messageController sendMessage:datamsg];
            }
        }else if (code == 900){
            [_inputController.textView resignFirstResponder];
            [self didTapInMessageController:_messageController];
            [self showAlertView:msg andMessage:datamsg];
        }else if (code == 901){
            [_inputController.textView resignFirstResponder];
            [self didTapInMessageController:_messageController];
            [self showYoungTipMsg:msg];

        }else{
            [_inputController.textView clearInput];
            [_inputController.inputView resignFirstResponder];
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        _inputController.menuView.sendButton.userInteractionEnabled = YES;

    }];
}
-(void)showYoungTipMsg:(NSString *)msg{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //收费
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }];
        [cancleAction setValue:[UIColor grayColor] forKey:@"_titleTextColor"];
        [alertContro addAction:cancleAction];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"去关闭") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[YBYoungManager shareInstance]checkYoungStatus:YoungFrom_Center];

        }];
        [sureAction setValue:normalColors_live forKey:@"_titleTextColor"];
        [alertContro addAction:sureAction];
        [self presentViewController:alertContro animated:YES completion:nil];
    });

}
- (void)showAlertView:(NSString *)message andMessage:(id)datamsg{
    WeakSelf;
    if (!alert) {
        alert = [[YBAlertView alloc]initWithTitle:YZMsg(@"提示") andMessage:message andButtonArrays:@[YZMsg(@"开通会员"),YZMsg(@"付费发送")] andButtonClick:^(int type) {
            if (type == 2) {
                [weakSelf doPayWithData:datamsg];
            }else if (type == 1) {
                [weakSelf doVIP];
            }
            [weakSelf removeAlertView];
            
        }];
        [self.view addSubview:alert];

    }
}
- (void)removeAlertView{
    if (alert) {
        [alert removeFromSuperview];
        alert = nil;
    }
    
}
- (void)doVIP{
    
    [self removeAlertView];
    VIPViewController *vip = [[VIPViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:vip animated:YES];
}
- (void)doPayWithData:(id)datamsg{

    [YBToolClass postNetworkWithUrl:@"Im.BuyIm" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [_inputController.textView clearInput];

            if ([datamsg isKindOfClass:[UIImage class]]) {
                [_messageController sendImageMessage:datamsg andIndex:0];
            }else{
                [_messageController sendMessage:datamsg];
            }
            [self removeAlertView];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{

    }];
    
}
- (void)dealloc{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"ismessageing"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"messageingUserID"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - 私信
- (UIView *)topAttentView {
    if (!_topAttentView) {
        _topAttentView = [[UIView alloc]init];
        _topAttentView.backgroundColor = [UIColor whiteColor];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"提示关闭"] forState:0];
        [closeBtn addTarget:self action:@selector(clickFollowClose) forControlEvents:UIControlEventTouchUpInside];
        [_topAttentView addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(40);
            make.centerY.equalTo(_topAttentView.mas_centerY);
            make.left.equalTo(_topAttentView.mas_left).offset(5);
        }];
        
        UILabel *desL = [[UILabel alloc]init];
        desL.text = YZMsg(@"点击关注，可及时看到对方动态");
        desL.font = SYS_Font(12);
        desL.textColor =  RGB_COLOR(@"#828282", 1);
        desL.numberOfLines = 2;
        [_topAttentView addSubview:desL];
        [desL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(closeBtn.mas_right).offset(5);
            make.centerY.equalTo(_topAttentView);
        }];
        
        UIButton *followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //YZMsg(@"关注-chattop")
        [followBtn setTitle:YZMsg(@"关注") forState:0];
        followBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        followBtn.layer.cornerRadius = 10;
        followBtn.layer.masksToBounds = YES;
        followBtn.titleLabel.font = SYS_Font(12);
        followBtn.layer.borderColor = Pink_Cor.CGColor;
        followBtn.layer.borderWidth = 1;
        [followBtn setTitleColor:Pink_Cor forState:0];
        
        [followBtn addTarget:self action:@selector(doFollow) forControlEvents:UIControlEventTouchUpInside];
        [_topAttentView addSubview:followBtn];
        [followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_topAttentView.mas_centerY);
            make.right.equalTo(_topAttentView.mas_right).offset(-15);
            make.left.greaterThanOrEqualTo(desL.mas_right).offset(10);
            make.height.mas_equalTo(20);
        }];
        
        [desL setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [followBtn setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    }
    return _topAttentView;;
}
-(void)clickFollowClose {
    _topAttentView.hidden = YES;
}

- (void)liveImRequest;{
    [self setupViews];
    if (_conversation) {
        [_messageController setConversation:_conversation];
        _topAttentView.hidden = [_conversation.isAtt intValue];
    }
    self.naviView.hidden = YES;
    [self changeSmallHeight];
    _topAttentView.top = 0;
}
-(void)changeSmallHeight;{
    _messageController.view.frame = CGRectMake(0, 0, _window_width, self.view.height - TTextView_Height - Bottom_SafeHeight);
    if([_conversation.convId isEqual:@"admin"]){
        _messageController.view.frame = CGRectMake(0, 0, _window_width, self.view.height);
    }
    _inputController.view.frame = CGRectMake(0, _messageController.view.bottom, _window_width, TTextView_Height + Bottom_SafeHeight);
}



@end

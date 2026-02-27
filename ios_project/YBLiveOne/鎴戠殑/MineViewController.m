//
//  MineViewController.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MineViewController.h"
#import "mineListCell.h"
#import "EditMsgViewController.h"
#import "instructionCell.h"
#import "MineImpressViewController.h"
#import "MineWalletViewController.h"
#import "GiftCabinetViewController.h"
#import "SettingViewController.h"
#import "RechargeViewController.h"
#import "FollowUserViewController.h"
#import "FansViewController.h"
#import "MIneVideoViewController.h"
#import "minePicAuthViewController.h"
#import "VIPViewController.h"
#import "BackWallViewController.h"
#import "MyZoneViewController.h"
#import "SetMeiYanVC.h"
#import "AuthenticateVC.h"
#import "EditInfoViewController.h"
#import "HeaderInfoCell.h"
#import "myProfitVC.h"
#import "YBFunctionCell.h"
#import "ConversationChatSwitchView.h"
#import "PersonMessageViewController.h"
#import "RoomManagementVC.h"
#import "TaskCenterVC.h"
#import "LikeUserVC.h"

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,mineListCellDelegate,functionCellDelegate>{
    NSArray *listArray;
    NSDictionary *headerDic;
    UIPickerView *coinPicker;
    NSArray *videoArray;
    int videoMaxSelectIndex;
    int curVideoIndex;

    NSArray *audioArray;
    int audioMaxSelectIndex;
    int curAudioIndex;

    NSString *curVideoValue;
    NSString *curAudioValue;
    
    UIView *pickBackView;
    UIView *wihteView;
    BOOL isVideo;
    UIView *instructionView;
    
    UITableView *instructionTable;
    NSArray *instructionArray;
    int isAuth;
}
//音视频
@property (nonatomic, strong)ConversationChatSwitchView *conversationView;
@property (nonatomic, strong)UITableView *mineTable;

@end

@implementation MineViewController
- (void)viewWillAppear:(BOOL)animated{
    [self requestData];
}
-(void)Yongnotification{
    if (self.mineTable) {
        [self.mineTable removeFromSuperview];
        self.mineTable = nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Yongnotification) name:@"openYoung_notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Yongnotification) name:@"closeYoung_notification" object:nil];

}

-(UITableView *)mineTable{
    if (!_mineTable) {
        _mineTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height-48-ShowDiff) style:1];
        _mineTable.delegate = self;
        _mineTable.dataSource = self;
        _mineTable.separatorStyle = 0;
        _mineTable.backgroundColor = RGBA(245, 246, 247, 1);
        _mineTable.estimatedRowHeight = 0;
        if (@available(iOS 11.0,*)) {
            _mineTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }

        if (@available(iOS 15.0, *)) {
            _mineTable.sectionHeaderTopPadding = 0;
        }
        [self.view addSubview:self.mineTable];

    }
    return _mineTable;
}
- (void)requestData{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地 build
    //NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];version
    //NSLog(@"当前应用软件版本:%@",appCurVersion);
    NSString *build = [NSString stringWithFormat:@"%@",app_build];

    [YBToolClass postNetworkWithUrl:@"User.GetBaseInfo" andParameter:@{@"ios_version":build} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            headerDic = [info firstObject];
            LiveUser *user = [Config myProfile];
            user.avatar = minstr([headerDic valueForKey:@"avatar"]);
            user.avatar_thumb = minstr([headerDic valueForKey:@"avatar_thumb"]);
            user.isauth = minstr([headerDic valueForKey:@"isauth"]);
            user.sex = minstr([headerDic valueForKey:@"sex"]);
            user.user_nickname = minstr([headerDic valueForKey:@"user_nickname"]);
            user.signature = minstr([headerDic valueForKey:@"signature"]);
            user.coin = minstr([headerDic valueForKey:@"coin"]);
            user.level = minstr([headerDic valueForKey:@"level"]);
            user.level_anchor = minstr([headerDic valueForKey:@"level_anchor"]);
            user.isuser_auth = minstr([headerDic valueForKey:@"isuser_auth"]);
            [Config updateProfile:user];
            NSString *isVip = minstr([headerDic valueForKey:@"isvip"]);
            [Config saveVipandliang:@{@"vip_type":isVip}];
            
            curVideoValue = minstr([headerDic valueForKey:@"video_value"]);
            curAudioValue = minstr([headerDic valueForKey:@"voice_value"]);
            curAudioIndex = 0;
            curVideoIndex = 0;
            videoArray = [headerDic valueForKey:@"videolist"];
            videoMaxSelectIndex = (int)[videoArray count] - 1;
            for (int i = 0; i < videoArray.count; i++) {
                NSDictionary *dic = videoArray[i];
                if ([minstr([dic valueForKey:@"coin"]) isEqual:curVideoValue]) {
                    curVideoIndex = i;
                }
                if ([minstr([dic valueForKey:@"canselect"]) isEqual:@"0"]) {
                    videoMaxSelectIndex = i-1;
                    if (videoMaxSelectIndex<0) {
                        videoMaxSelectIndex = 0;
                    }
                    break;
                }
            }
            audioArray = [headerDic valueForKey:@"voicelist"];
            audioMaxSelectIndex = (int)[audioArray count] - 1;
            for (int i = 0; i < audioArray.count; i++) {
                NSDictionary *dic = audioArray[i];
                if ([minstr([dic valueForKey:@"coin"]) isEqual:curAudioValue]) {
                    curAudioIndex = i;
                }
                if ([minstr([dic valueForKey:@"canselect"]) isEqual:@"0"]) {
                    audioMaxSelectIndex = i-1;
                    if (audioMaxSelectIndex < 0) {
                        audioMaxSelectIndex = 0;
                    }

                    break;
                }
            }

            isAuth = [minstr([headerDic valueForKey:@"isauth"]) intValue];
            listArray = [headerDic valueForKey:@"list"];
            [self.mineTable reloadData];
        }

    } fail:^{
        
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == instructionTable) {
        return 1;
    }
    if ([[YBYoungManager shareInstance]isOpenYoung]) {
        return 2;
    }else{
        if (listArray.count > 0) {
            return 2;
        }else{
            return 1;
        }

    }

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == instructionTable) {
        return instructionArray.count;
    }
    if ([[YBYoungManager shareInstance]isOpenYoung]) {
        return 1;
    }else{
        if (section == 0) {
            return 1;
        }else{
            return 1;
        }

    }
//    return listArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == instructionTable) {
        instructionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"instructionCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"instructionCell" owner:nil options:nil] lastObject];
        }
        NSDictionary *dic = instructionArray[indexPath.row];
        [cell.levelImgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])]];
        cell.coinL.text = [NSString stringWithFormat:@"≤ %@",minstr([dic valueForKey:@"coin"])];
        return cell;

    }else{
//        if ([[YBYoungManager shareInstance]isOpenYoung]) {
//            static NSString *identifier = @"userinfocell";
//            YBFunctionCell *cell = [[YBFunctionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier andListArr:listArray];
//            cell.dataDic  =listArray;
//            cell.delegate = self;
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//
//        }else{
            
            WeakSelf;
            if (indexPath.section == 0) {
                HeaderInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mineHeaderCELL"];
                if (!cell) {
                    cell = [[HeaderInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mineHeaderCELL"];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellData =headerDic;
                cell.btnEvent = ^(NSString *btnType) {
                    if ([btnType isEqual:@"设置"]) {
                        [weakSelf setting];
                    }else if ([btnType isEqual:@"编辑"]){
                        [weakSelf doEditVC];
                    }else if ([btnType isEqual:@"关注"]){
                        [weakSelf doFollowUser];
                    }else if ([btnType isEqual:@"喜欢"]){
                        [weakSelf dolikeUser];
                    }else if ([btnType isEqual:@"粉丝"]){
                        [weakSelf doFansUser];
                    }else if ([btnType isEqual:@"余额"]){
                        [weakSelf doRecharge];
                    }else if ([btnType isEqual:@"收益"]){
                        [weakSelf doMyProfitVC];
                    }else if ([btnType isEqual:@"vip"]){
                        [weakSelf doVIP];
                    }else if ([btnType isEqual:@"邀请"]){
                        [weakSelf yaoqingClick];
                    }else if ([btnType isEqual:@"我的钱包"]){
                        [weakSelf mineWallet];
                    }else if ([btnType isEqual:@"我要认证"]){
                        [weakSelf mineAuth];
                    }else if ([btnType isEqual:@"美颜预设"]){
                        [weakSelf setMYNormalValue];
                    }
                };
                return cell;
            }else{
                static NSString *identifier = @"userinfocell";
                YBFunctionCell *cell = [[YBFunctionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier andListArr:listArray];
                cell.dataDic  =listArray;
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
//        }

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == instructionTable) {
        return 40;
    }
    if ([[YBYoungManager shareInstance]isOpenYoung]) {
        if (indexPath.section == 0) {
            return  24+statusbarHeight+40+100;
        }else{
                int numbs =(int)listArray.count/4;
                int ysnumbs =listArray.count%4;
                if (ysnumbs > 0) {
                    numbs = numbs+1;
                }
                
                return  ((_window_width-30)/4)*numbs+50;
        }
    }else{
        if (indexPath.section == 0) {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地 build
            NSString *buildsss = [NSString stringWithFormat:@"%@",app_build];

            if (@available(iOS 15.0, *)) {
                if (![buildsss isEqual:[common ios_shelves]]) {
                    return 600;
                }
                return 550-160-17;//隐藏增值功能

            }else{
                if (![buildsss isEqual:[common ios_shelves]]) {
                    return 600;
                }
                return 530-160-17;//隐藏增值功能

            }
        }else{
            int numbs =(int)listArray.count/4;
            int ysnumbs =listArray.count%4;
            if (ysnumbs > 0) {
                numbs = numbs+1;
            }
            
            return  ((_window_width-30)/4)*numbs+50;
        }

    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView == instructionTable) {
        return 0;
    }else{
        if (section == 0) {
            return 10;
        }
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == instructionTable) {
        return 40;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 10)];
    view.backgroundColor = colorf5;
    return view;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == instructionTable) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, instructionTable.width, 40)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width/2, 40)];
        label1.font = SYS_Font(12);
        label1.textColor = RGB_COLOR(@"#646464", 1);
        label1.text = YZMsg(@"主播星级");
        label1.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label1];
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(view.width/2, 0, view.width/2, 40)];
        label2.font = SYS_Font(12);
        label2.textColor = RGB_COLOR(@"#646464", 1);
        label2.text = YZMsg(@"收费价格");
        label2.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label2];
        [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, view.width, 1) andColor:RGB_COLOR(@"#dcdcdc", 1) andView:view];
        return view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        int idValue = [minstr([listArray[indexPath.row] valueForKey:@"id"]) intValue];
        switch (idValue) {
            case 1:
                //我的钱包
                [self mineWallet];
                break;
            case 2:
                //我要认证
                [self mineAuth];
                break;
            case 3:
                //我的动态
                [self pushMyZone];
                break;
            case 4:
                //我的印象
                [self mineImpress];
                break;
            case 5:
                //礼物柜
                [self getMineGift];
                break;
            case 6:
                //视频接听
                [self setMineVideoCoin];
                break;
            case 7:
                //语音接听
                [self setMineAudioCoin];
                break;
            case 8:
                //勿扰
                break;
            case 9:
                //个性设置
                [self setting];
                break;
            case 11:
                //背景墙
                [self mineBackWall];
                break;
            case 12:
                //我的视频
                [self mineVideo];
                break;
            case 13:
                //我的相册
                [self minePic];
                break;
            case 14:
                //分享赚钱
                [self goWebView:minstr([listArray[indexPath.row] valueForKey:@"href"])];
                break;
            case 15:
                [self setMYNormalValue];
                break;
            case 16:
                [self goWebView:minstr([listArray[indexPath.row] valueForKey:@"href"])];
                break;

            case 10:
                //会员中心
                [self doVIP];
                break;

            default:
                break;
        }
    }
}

-(void)clickFunction:(NSDictionary *)dic
{
    int idValue = [dic[@"id"] intValue];//选项ID
    switch (idValue) {
        case 1:
            //我的钱包
            [self mineWallet];
            break;
        case 2:
            //我要认证
            [self mineAuth];
            break;
        case 3:
            //我的动态
            [self pushMyZone];
            break;
        case 4:
            //我的印象
            [self mineImpress];
            break;
        case 5:
            //礼物柜
            [self getMineGift];
            break;
        case 6:
            //视频接听
            [self setMineVideoCoin];
            break;
        case 7:
            //语音接听
            [self setMineAudioCoin];
            break;
        case 8:
            //勿扰
            break;
        case 9:
            //个性设置
            [self setting];
            break;
        case 10:
            //会员中心
            [self doVIP];
            break;
        case 11:
            //背景墙
            [self mineBackWall];
            break;
        case 12:
            //我的视频
            [self mineVideo];
            break;
        case 13:
            //我的相册
            [self minePic];
            break;
        case 14:
            //分享赚钱
            [self goWebView:minstr([dic valueForKey:@"href"])];
            break;
        case 15:
            //通话设置
            [self showChatSet];
            break;
        case 16:
//            [self goWebView:minstr([dic valueForKey:@"href"])];
            [self toYoungSet];
            break;
        case 17:{
            [self roomManeger];
        }break;
        case 18:
            //任务中心
            [self taskCenter];
            break;

        default:
            break;
    }

}
#pragma mark -任务中心
-(void)taskCenter{
    TaskCenterVC *taskCenter = [[TaskCenterVC alloc]init];
    [[YBAppDelegate sharedAppDelegate]pushViewController:taskCenter animated:YES];
}
-(void)roomManeger {
    RoomManagementVC *VC = [[RoomManagementVC alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:VC animated:YES];
    
}

-(void)showChatSet{
    WeakSelf;
    _conversationView = [[ConversationChatSwitchView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andInfoDic:headerDic];
    _conversationView.btnEvent = ^(NSString *btnTitle) {
        if ([btnTitle isEqual:@"视频"]) {
            [weakSelf setMineVideoCoin];
        }else if ([btnTitle isEqual:@"语音"]){
            [weakSelf setMineAudioCoin];

        }else if ([btnTitle isEqual:@"开关"]){
            [weakSelf requestData];
            return;
        }
        [weakSelf.conversationView removeFromSuperview];
        weakSelf.conversationView = nil;
    };
    [[UIApplication sharedApplication].keyWindow addSubview:_conversationView];

}
#pragma mark ============pickView=============

- (void)creatPickView{
    pickBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    pickBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [[UIApplication sharedApplication].keyWindow addSubview:pickBackView];
    wihteView = [[UIView alloc]initWithFrame:CGRectMake(30, _window_height, _window_width-60, 200)];
    wihteView.backgroundColor = [UIColor whiteColor];
    wihteView.layer.cornerRadius = 10;
    wihteView.layer.masksToBounds  = YES;
    [pickBackView addSubview:wihteView];
    
    UIButton *messageBtn = [UIButton buttonWithType:0];
    messageBtn.frame = CGRectMake(15, 7, 85, 30);
    if ([lagType isEqual:ZH_CN]) {
        messageBtn.frame = CGRectMake(15, 7, 155, 30);
    }
    [messageBtn setImage:[UIImage imageNamed:@"mine_message"] forState:0];
    [messageBtn setTitle:YZMsg(@"收费标准说明") forState:0];
    [messageBtn setTitleColor:color96 forState:0];
    messageBtn.titleLabel.font = SYS_Font(10);
    [messageBtn addTarget:self action:@selector(messageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [wihteView addSubview:messageBtn];
    UIButton *closeBtn = [UIButton buttonWithType:0];
    closeBtn.frame = CGRectMake(wihteView.width-41, 0, 41, 41);
    [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [closeBtn addTarget:self action:@selector(closebtnClick) forControlEvents:UIControlEventTouchUpInside];
    [wihteView addSubview:closeBtn];

    coinPicker = [[UIPickerView alloc]initWithFrame:CGRectMake((wihteView.width-80)/2, 40, 80, 120)];
    coinPicker.backgroundColor = [UIColor whiteColor];
    coinPicker.delegate = self;
    coinPicker.dataSource = self;
    coinPicker.showsSelectionIndicator = YES;
    [wihteView addSubview:coinPicker];

    UILabel *leftL = [[UILabel alloc]initWithFrame:CGRectMake(20, 90, (wihteView.width-80)/2-20, 20)];
    leftL.font = SYS_Font(14);
    leftL.textColor = RGB_COLOR(@"#646464", 1);
    leftL.text = YZMsg(@"向TA收费");
    leftL.textAlignment = NSTextAlignmentCenter;
    [wihteView addSubview:leftL];
    
    UILabel *rightL = [[UILabel alloc]initWithFrame:CGRectMake(coinPicker.right, 90, (wihteView.width-80)/2-20, 20)];
    rightL.font = SYS_Font(14);
    rightL.textColor = RGB_COLOR(@"#646464", 1);
    rightL.text = [common name_coin];
    rightL.textAlignment = NSTextAlignmentCenter;
    [wihteView addSubview:rightL];

    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 160, wihteView.width, 1) andColor:RGB_COLOR(@"#DCDCDC", 1) andView:wihteView];
    
    UIButton *sureBtn = [UIButton buttonWithType:0];
    sureBtn.frame = CGRectMake(0, 160, wihteView.width, 40);
    [sureBtn setTitleColor:normalColors forState:0];
    [sureBtn setTitle:YZMsg(@"确定") forState:0];
    sureBtn.titleLabel.font = SYS_Font(14);
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [wihteView addSubview:sureBtn];
    [self showCoinPicker];
}
- (void)showCoinPicker{
    if (isVideo) {
        [coinPicker selectRow:curVideoIndex inComponent:0 animated:YES];
    }else{
        [coinPicker selectRow:curAudioIndex inComponent:0 animated:YES];
    }
    [coinPicker reloadAllComponents];
    pickBackView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        wihteView.center = pickBackView.center;
    }];
}
- (void)messageBtnClick{
    NSString *url;
    if (isVideo) {
        url = @"User.GetVideoInfo";
    }else{
        url = @"User.GetVoiceInfo";
    }
    [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            instructionArray = info;
            if (instructionView) {
                [instructionView removeFromSuperview];
                instructionView = nil;
            }
            if (!instructionView) {
                instructionView = [[UIView alloc]initWithFrame:CGRectMake(30, _window_height, _window_width-60, 330)];
                instructionView.backgroundColor = [UIColor whiteColor];
                instructionView.layer.cornerRadius = 10;
                instructionView.layer.masksToBounds  = YES;
                [pickBackView addSubview:instructionView];
                UIButton *closeBtn = [UIButton buttonWithType:0];
                closeBtn.frame = CGRectMake(wihteView.width-41, 0, 41, 41);
                [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
                closeBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
                [closeBtn addTarget:self action:@selector(closeInstructionViewClick) forControlEvents:UIControlEventTouchUpInside];
                [instructionView addSubview:closeBtn];
                UILabel *labelll = [[UILabel alloc]initWithFrame:CGRectMake(instructionView.width/2-90, 13, 180, 47)];
                labelll.textAlignment = NSTextAlignmentCenter;
                labelll.font = SYS_Font(14);
                labelll.text = YZMsg(@"收费说明");
                [instructionView addSubview:labelll];
                
                instructionTable = [[UITableView alloc]initWithFrame:CGRectMake(35, 60, instructionView.width-70, 244) style:0];
                instructionTable.delegate = self;
                instructionTable.dataSource = self;
                instructionTable.separatorStyle = 0;
                [instructionView addSubview:instructionTable];
                
            }
            [self showInstructionTable];

        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];

}
- (void)showInstructionTable{
    [instructionTable reloadData];
    instructionView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        instructionView.center = pickBackView.center;
    }];
}
- (void)closeInstructionViewClick{
    [UIView animateWithDuration:0.3 animations:^{
        instructionView.y = _window_height;
    }completion:^(BOOL finished) {
        instructionView.hidden = YES;
    }];

}
- (void)closebtnClick{
    [UIView animateWithDuration:0.3 animations:^{
        wihteView.y = _window_height;
    }completion:^(BOOL finished) {
        pickBackView.hidden = YES;
    }];

}
- (void)sureBtnClick{
    NSString *url;
    NSDictionary *dic;
    NSInteger index = [coinPicker selectedRowInComponent: 0];
    if (isVideo) {
        if (index > videoMaxSelectIndex) {
            [MBProgressHUD showError:YZMsg(@"等级不够,无法使用此价格")];
            return;
        }
    }else{
        if (index > audioMaxSelectIndex) {
            [MBProgressHUD showError:YZMsg(@"等级不够,无法使用此价格")];
            return;
        }

    }

    if (isVideo) {
        url = @"User.SetVideoValue";
        dic = @{@"value":minstr([videoArray[index] valueForKey:@"coin"])};
    }else{
        url = @"User.SetVoiceValue";
        dic = @{@"value":minstr([audioArray[index] valueForKey:@"coin"])};
    }
    [YBToolClass postNetworkWithUrl:url andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [self requestData];
            [self closebtnClick];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}
#pragma mark- Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (isVideo) {
        return [videoArray count];
    }
    return [audioArray count];

}


#pragma mark- Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (isVideo) {
        return minstr([[videoArray objectAtIndex: row] valueForKey:@"coin"]);
    }
    return minstr([[audioArray objectAtIndex: row] valueForKey:@"coin"]);

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (isVideo) {
        if (row > videoMaxSelectIndex) {
            [pickerView selectRow:videoMaxSelectIndex inComponent:0 animated:YES];
        }
    }else{
        if (row > audioMaxSelectIndex) {
            [pickerView selectRow:audioMaxSelectIndex inComponent:0 animated:YES];
        }

    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 80;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 40)];
    myView.textAlignment = NSTextAlignmentCenter;
    if (isVideo) {
        myView.text = minstr([[videoArray objectAtIndex: row] valueForKey:@"coin"]);
    }else{
        myView.text = minstr([[audioArray objectAtIndex: row] valueForKey:@"coin"]);
    }
    myView.font = [UIFont systemFontOfSize:16];
    myView.backgroundColor = [UIColor clearColor];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, 80, 1) andColor:RGB_COLOR(@"#DCDCDC", 1) andView:myView];
    return myView;
}

#pragma mark ============mineHeaderCellDeleagte=============
-(void)doMyProfitVC{
    myProfitVC *profit = [[myProfitVC alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:profit animated:YES];

}
- (void)yaoqingClick{
    
    NSString *loadUrl = [NSString stringWithFormat:@"%@/index.php?s=appapi/agent/index&uid=%@&token=%@",h5url,[Config getOwnID],[Config getOwnToken]];
    loadUrl = [loadUrl stringByAppendingFormat:@"&lang=%@",[RookieTools serviceLang]];
    YBWebViewController *web = [[YBWebViewController alloc]init];
    web.urls = loadUrl;
    [[YBAppDelegate sharedAppDelegate] pushViewController:web animated:YES];

}
-(void)toYoungSet{
    [[YBYoungManager shareInstance]checkYoungStatus:YoungFrom_Center];

}
- (void)doCoinVC{
    [self doRecharge];
}
- (void)doEditVC{
    if ([[Config getIsauth] isEqual:@"1"]) {
        [MBProgressHUD showMessage:@""];
        [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":[Config getOwnID]} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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

    }else{
        EditInfoViewController *auth = [[EditInfoViewController alloc]init];
        [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];
    }
}
- (void)doFansUser{
    FansViewController *fans = [[FansViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:fans animated:YES];
}
-(void)dolikeUser{
    LikeUserVC *like = [[LikeUserVC alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:like animated:YES];

}
- (void)doFollowUser{
    FollowUserViewController *follow = [[FollowUserViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:follow animated:YES];
}
#pragma mark ============cell点击事件=============
- (void)mineImpress{
    MineImpressViewController *mine = [[MineImpressViewController alloc]init];
    mine.touid = [Config getOwnID];
    [[YBAppDelegate sharedAppDelegate] pushViewController:mine animated:YES];
}
-(void)pushMyZone{
    MyZoneViewController *zone =[[MyZoneViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:zone animated:YES];

}
- (void)mineAuth{
    AuthenticateVC *auth = [[AuthenticateVC alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];
}
- (void)setMineVideoCoin{
    isVideo = YES;
    if (!pickBackView) {
        [self creatPickView];
    }else{
        [self showCoinPicker];
    }

}
- (void)setMineAudioCoin{
    isVideo = NO;
    if (!pickBackView) {
        [self creatPickView];
    }else{
        [self showCoinPicker];
    }

}
- (void)mineWallet{
    MineWalletViewController *wallter = [[MineWalletViewController alloc]init];
    wallter.coin = minstr([headerDic valueForKey:@"coin"]);
    [[YBAppDelegate sharedAppDelegate] pushViewController:wallter animated:YES];
}
- (void)getMineGift{
    GiftCabinetViewController *gift = [[GiftCabinetViewController alloc]init];
    gift.userID = [Config getOwnID];
    [[YBAppDelegate sharedAppDelegate] pushViewController:gift animated:YES];
}
- (void)setting{
    SettingViewController *set = [[SettingViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:set animated:YES];
}
- (void)doRecharge{
    RechargeViewController *recharge = [[RechargeViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:recharge animated:YES];
}
- (void)mineVideo{
    MIneVideoViewController *video = [[MIneVideoViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:video animated:YES];
}
- (void)minePic{
    minePicAuthViewController *pic = [[minePicAuthViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:pic animated:YES];
}
- (void)doVIP{
    VIPViewController *vip = [[VIPViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:vip animated:YES];
}
- (void)mineBackWall{
    BackWallViewController *wall = [[BackWallViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:wall animated:YES];
}
- (void)goWebView:(NSString *)url{
    NSString *loadUrl = [NSString stringWithFormat:@"%@&uid=%@&token=%@",url,[Config getOwnID],[Config getOwnToken]];
    YBWebViewController *web = [[YBWebViewController alloc]init];
    web.urls = loadUrl;
    [[YBAppDelegate sharedAppDelegate] pushViewController:web animated:YES];
}
-(void)setMYNormalValue{
    SetMeiYanVC *MYVc = [[SetMeiYanVC alloc]init];
    [[YBAppDelegate sharedAppDelegate]pushViewController:MYVc animated:YES];
}

-(void)levelTapClick{
    NSString *loadUrl;
    if ([minstr([headerDic valueForKey:@"oldauth"]) isEqual:@"1"]) {
        loadUrl = [NSString stringWithFormat:@"%@/appapi/level/level_a",h5url];

    }else{
        loadUrl = [NSString stringWithFormat:@"%@/appapi/level/level",h5url];

    }
    loadUrl = [loadUrl stringByAppendingFormat:@"?lang=%@",[RookieTools serviceLang]];
    YBWebViewController *web = [[YBWebViewController alloc]init];
    web.urls = loadUrl;
    [[YBAppDelegate sharedAppDelegate] pushViewController:web animated:YES];

}
#pragma mark ============mineCellDelegate=============
- (void)reloadMineList{
    [self requestData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

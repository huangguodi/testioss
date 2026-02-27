//
//  MessageViewController.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MessageViewController.h"
#import "TConversationCell.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
//#import "IMMessageExt.h"
//#import <ImSDK/ImSDK.h>

#import "TUIKit.h"
#import "TChatController.h"
#import "SubscribeViewController.h"
#import "SystemViewController.h"

@interface MessageViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate,V2TIMConversationListener,V2TIMAdvancedMsgListener>{
    NSString *subscribeNum;
    NSMutableDictionary *sysDic;
    int syscount;//是否有系统消息
    TConversationCellData *conver_admin1;//系统通知
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation MessageViewController
#pragma mark - navi
-(void)creatNavi {
    
    UIView *navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];
    
    //标题
    UILabel *midLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 22+statusbarHeight, 60, 42)];
    midLabel.backgroundColor = [UIColor clearColor];
    midLabel.font = [UIFont boldSystemFontOfSize:22];
    if (![lagType isEqual:ZH_CN]) {
        midLabel.font = [UIFont boldSystemFontOfSize:15];
        midLabel.frame = CGRectMake(0, 22+statusbarHeight, 90, 42);
    }
    midLabel.text = YZMsg(@"消息");
    midLabel.textAlignment = NSTextAlignmentCenter;
    [navi addSubview:midLabel];
    
    UILabel *lineLb = [[UILabel alloc]init];
    lineLb.backgroundColor = RGBA(162,0,255, 0.59);
    lineLb.layer.cornerRadius =5;
    lineLb.layer.masksToBounds = YES;
    [midLabel addSubview:lineLb];
    [lineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(midLabel.mas_centerX);
        make.bottom.equalTo(midLabel.mas_bottom).offset(-7);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(30);
    }];

    UIButton *rightBTN = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightBTN setTitle:YZMsg(@"一键已读") forState:UIControlStateNormal];
    rightBTN.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBTN addTarget:self action:@selector(weidu:) forControlEvents:UIControlEventTouchUpInside];
    [rightBTN setTitleColor:RGB_COLOR(@"#323232", 1) forState:UIControlStateNormal];
    rightBTN.frame = CGRectMake(_window_width - 80,24 + statusbarHeight, 80, 40);
    rightBTN.titleLabel.textAlignment = NSTextAlignmentCenter;
    [navi addSubview:rightBTN];
    
    //私信
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 63+statusbarHeight, _window_width, 1) andColor:colorf5 andView:navi];
    
}
//忽略未读
-(void)weidu:(UIButton *)sender{
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    NSString *issystem = @"0";
    NSString *lastReadSysMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReadSysMessage"];
    if ((![minstr([sysDic valueForKey:@"time"]) isEqual:lastReadSysMessage] || [YBToolClass checkNull:lastReadSysMessage])&& syscount == 1){
        issystem = @"1";
    }else{
        issystem = @"0";
    }
    [[NSUserDefaults standardUserDefaults] setObject:minstr([sysDic valueForKey:@"time"]) forKey:@"lastReadSysMessage"];
    [sysDic setObject:@"0" forKey:@"unRead"];
    
    [[YBImManager shareInstance]clearAllUnreadConv];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [MBProgressHUD showError:YZMsg(@"已忽略未读消息")];
//    });

//    for (int i = 0; i < _data.count; i ++) {
//         //TIMConversation *conv = arrayd[i];
//        TConversationCellData *data = _data[i];
//        data.unRead = 0;
//        [_data replaceObjectAtIndex:i withObject:data];
//    }
   
    
   
   
//    TIMManager *manager = [TIMManager sharedInstance];
//    NSArray *convs = [manager getConversationList];
//    NSMutableArray *arrayd = [NSMutableArray array];
//    int unRead = 0;
//
//    for (int i = 0; i < convs.count; i ++) {
//        TIMConversation *conv = convs[i];
//        if([conv getType] == TIM_SYSTEM){
//
//            continue;
//        }
//        if([conv getType] == TIM_GROUP){
//
//            continue;
//        }
//        [arrayd addObject:conv];
//
//
//    }
//    for (int i = 0; i < arrayd.count; i ++) {
//         TIMConversation *conv = arrayd[i];
//         int jjj = [conv getUnReadMessageNum];
//               unRead += jjj;
//        if (jjj> 0) {
//
//            [conv setReadMessage:nil succ:^{
//
//                } fail:^(int code, NSString *msg) {
//
//                }];
//        }
//
//               if (i == arrayd.count-1) {
//
//                   //设置item角标数字
//                   if (unRead > 0 || [issystem isEqual:@"1"]) {
//                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                           [MBProgressHUD showError:YZMsg(@"已忽略未读消息")];
//                       });
//
//
//
//                   }else{
//                       [self messagetip];
//                   }
//               }
//    }
//    if (arrayd.count == 0 ) {
//        if ([issystem isEqual:@"0"]) {
//            [self messagetip];
//        }else{
//
//            [MBProgressHUD showError:YZMsg(@"已忽略未读消息")];
//        }
//
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMCancelunread object:nil];
    [_tableView reloadData];
}
-(void)messagetip{
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:YZMsg(@"暂无未读消息") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"确定") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancel setValue:normalColors forKey:@"_titleTextColor"];
    [alertControl addAction:cancel];
    [[[YBAppDelegate sharedAppDelegate]topViewController]presentViewController:alertControl animated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [[V2TIMManager sharedInstance] addConversationListener:self];
//    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];

    subscribeNum = YZMsg(@"暂无预约");
    sysDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"sysnotice"];
    [self creatNavi];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-48-ShowDiff)];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = 0;
    [self.view addSubview:_tableView];
    _data = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sysnotice:) name:@"sysnotice" object:nil];
 
}

- (void)requestSystemData{
    [YBToolClass postNetworkWithUrl:@"Im.GetSysNotice" andParameter:@{@"p":@"1"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            if ([info count] > 0) {
                syscount = 1;
                NSDictionary *dic = [info firstObject];

                sysDic = dic.mutableCopy;
                NSString *lastReadSysMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReadSysMessage"];
                [sysDic setObject:minstr([dic valueForKey:@"addtime"]) forKey:@"time"];

                if ([minstr([dic valueForKey:@"addtime"]) isEqual:lastReadSysMessage]) {
                    [sysDic setObject:@"0" forKey:@"unRead"];
                }else{
                    [sysDic setObject:@"9999999" forKey:@"unRead"];
                }

                [_tableView reloadData];
//                [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMCancelunread object:nil];
            }
        }
    } fail:^{
    }];
}

- (void)sysnotice:(NSNotification *)not{
    NSDictionary *dic = [not object];
    sysDic = [dic mutableCopy];
    NSString *lastReadSysMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReadSysMessage"];
    if ([minstr([dic valueForKey:@"time"]) isEqual:lastReadSysMessage]) {
        [sysDic setObject:@"0" forKey:@"unRead"];
    }else{
        [sysDic setObject:@"9999999" forKey:@"unRead"];
    }
    [_tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMCancelunread object:nil];

}
- (void)viewWillAppear:(BOOL)animated
{
//    _data = [NSMutableArray array];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshConversations:) name:TUIKitNotification_TIMRefreshListener object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChanged:) name:TUIKitNotification_TIMConnListener object:nil];
    [self requestNums];
    [self updateConversations];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestSystemData];
    });
}
- (void)requestNums{
    [YBToolClass postNetworkWithUrl:@"Subscribe.GetSubscribeNums" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            subscribeNum = [NSString stringWithFormat:@"%@%@%@",YZMsg(@"我有"),minstr([[info firstObject] valueForKey:@"nums"]),YZMsg(@"个预约")];
            [_tableView reloadData];
        }
    } fail:^{
        
    }];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark --消息监听
- (void)onTotalUnreadMessageCountChanged:(UInt64)totalUnreadCount {
    [self updateConversations];
}
//-(void)onRecvNewMessage:(V2TIMMessage *)msg
//{
//    [self updateConversations];
//}
///// 收到消息撤回
//- (void)onRecvMessageRevoked:(NSString *)msgID;
//{
//    [self updateConversations];
//}

- (void)updateConversations
{
    
//    _data = [NSMutableArray array];
    WeakSelf;
//     _data = [NSMutableArray array];
    [[YBImManager shareInstance]getAllConversationList:^(NSMutableArray *CovList, BOOL isSuccess) {
            if(isSuccess){
                weakSelf.data = CovList;
                [self requestUserMessage];
            }
    }];
}
- (void)requestUserMessage{
    NSString *uids = @"";
    for (TConversationCellData *data in _data) {
        uids = [uids stringByAppendingFormat:@"%@,",data.convId];
    }
    if (uids.length > 0) {
        //去掉最后一个逗号
        uids = [uids substringToIndex:[uids length] - 1];
    }
    [YBToolClass postNetworkWithUrl:[NSString stringWithFormat:@"Im.GetMultiInfo&uids=%@",uids] andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            for (int i = 0; i < [info count]; i ++) {
                TConversationCellData *data = _data[i];
                NSDictionary *dic = info[i];
                data.userName = minstr([dic valueForKey:@"user_nickname"]);
                data.userHeader = minstr([dic valueForKey:@"avatar"]);
                data.isauth = minstr([dic valueForKey:@"isauth"]);
                data.level_anchor = minstr([dic valueForKey:@"level_anchor"]);
                data.isAtt = minstr([dic valueForKey:@"u2t"]);
                data.isVIP = minstr([dic valueForKey:@"isvip"]);
                data.isblack = minstr([dic valueForKey:@"isblack"]);
            }
            [_tableView reloadData];
        }
    } fail:^{
        
    }];

}
- (void)onRefreshConversations:(NSNotification *)notification
{
    [self updateConversations];

//    TIMConversation * conv =[[notification object] firstObject];
//    TIMMessage *msg = [conv getLastMsg];
//
//    if (!msg) {
//        return;
//    }
//    int ad = -1;
//    for (int i = 0; i < _data.count; i ++) {
//        TConversationCellData *data = _data[i];
//
//        if ([data.convId isEqual:[conv getReceiver]]) {
//            ad = 0;
//            data.unRead = [conv getUnReadMessageNum];
//            data.subTitle = [self getLastDisplayString:conv];
//            if ([data.convId isEqual:@"admin"]) {
//                data.time = [self getDateDisplayString:msg.timestamp];
//            }else{
//
//            data.time = [self getUserDateString:msg.timestamp];
//
//            }
//            NSString *timest = [NSString stringWithFormat:@"%ld", (long)[msg.timestamp timeIntervalSince1970]];
//            data.timestamp = timest;
//            [_data replaceObjectAtIndex:i withObject:data];
//           // [_tableView reloadData];
//        }
//    }
//    if (ad == -1) {
//
//        TConversationCellData *data = [[TConversationCellData alloc] init];
//        data.unRead = [conv getUnReadMessageNum];
//        data.subTitle = [self getLastDisplayString:conv];
//        if([conv getType] == TIM_C2C){
//            data.head = TUIKitResource(@"default_head");
//        }
//        else if([conv getType] == TIM_GROUP){
//            data.head = TUIKitResource(@"default_group");
//        }
//        data.convId = [conv getReceiver];
//        NSString *timest = [NSString stringWithFormat:@"%ld", (long)[msg.timestamp timeIntervalSince1970]];
//        data.timestamp = timest;
//        data.convType = (TConvType)[conv getType];
//
//        if(data.convType == TConv_Type_C2C){
//            data.title = data.convId;
//        }
//        else if(data.convType == TConv_Type_Group){
//            data.title = [conv getGroupName];
//
//        }
//        if ([data.convId isEqual:@"admin"]) {
//            data.time = [self getDateDisplayString:msg.timestamp];
//            [_data insertObject:data atIndex:0];
//
//        }else{
//            data.time = [self getUserDateString:msg.timestamp];
//            [_data addObject:data];
//
//        }
//
//    }
//    _data = [self sortConversation:_data];
//
//    [self requestUserMessage];
//   // [self updateConversations];
}
#pragma mark --排序conversation
- (NSMutableArray *)sortConversation:(NSMutableArray *)conversationArr {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (TConversationCellData *im_con in conversationArr) {
        NSLog(@"获取数据===%@===%lu===%@",im_con.convId,(unsigned long)im_con.convType,im_con.timestamp);
        if ([im_con.convId isEqual:@"admin"]){
           
            conver_admin1 = im_con;
      }
        if (im_con.convType == TConv_Type_C2C) {
            [dict setValue:im_con forKey:im_con.timestamp];
        }
       
        
    }
    NSArray *arrKey = [dict allKeys];
    //将key排序
    NSArray *sortedArray = [arrKey sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
        
        return [obj2 compare:obj1];//正序
    }];
    NSLog(@"获取排序数组===%@==%@",arrKey,sortedArray);


    NSMutableArray *m_array = [NSMutableArray array];
    for (NSString *key in sortedArray) {
        [m_array addObject:[dict objectForKey:key]];
    }
    NSLog(@"获取数据===%@",m_array);
    if (conver_admin1) {
        [m_array removeObject:conver_admin1];
        [m_array insertObject:conver_admin1 atIndex:0];
    }

    conver_admin1 = nil;

    return m_array;
    
}
- (void)onNetworkChanged:(NSNotification *)notification
{
//    TNetStatus status = (TNetStatus)[notification.object intValue];
//    switch (status) {
//        case TNet_Status_Succ:
//            [_titleView setTitle:YZMsg(@"消息")];
//            [_titleView stopAnimating];
//            break;
//        case TNet_Status_Connecting:
//            [_titleView setTitle:@"连接中..."];
//            [_titleView startAnimating];
//            break;
//        case TNet_Status_Disconnect:
//            [_titleView setTitle:@"消息(未连接)"];
//            [_titleView stopAnimating];
//            break;
//        case TNet_Status_ConnFailed:
//            [_titleView setTitle:@"消息(未连接)"];
//            [_titleView stopAnimating];
//            break;
//
//        default:
//            break;
//    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([[YBYoungManager shareInstance] isOpenYoung]) {
        return 2;
    }else{
        return 3;

    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[YBYoungManager shareInstance] isOpenYoung]) {
        if (section == 1) {
            return _data.count;
        }
        return 1;

    }else{
        if (section == 2) {
            return _data.count;
        }
        return 1;

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TConversationCell getSize].height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ([[YBYoungManager shareInstance] isOpenYoung]) {
        return 0;
    }
    if (section == 0) {
        return 5;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if ([[YBYoungManager shareInstance] isOpenYoung]) {
        return nil;
    }
    if (section == 0) {
        UIView *vvv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 5)];
        vvv.backgroundColor = colorf5;
        return vvv;
    }
    return nil;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[YBYoungManager shareInstance] isOpenYoung]) {
        if (indexPath.section == 1) {
            return YES;
        }
        return NO;

    }else{
        if (indexPath.section == 2) {
            return YES;
        }
        return NO;

    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YZMsg(@"删除");
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TConversationCellData *conv = _data[indexPath.row];
    NSMutableArray *new_a = [NSMutableArray arrayWithArray:_data];
    [new_a removeObjectAtIndex:indexPath.row];
    _data = [NSMutableArray arrayWithArray:new_a];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    [[YBImManager shareInstance]clearUnreadConvId:conv.convId sendNot:YES];
    NSString *userid =  [NSString stringWithFormat:@"c2c_%@",conv.convId];
    [[V2TIMManager sharedInstance] deleteConversation:userid succ:^{
        NSLog(@"success");
    } fail:^(int code, NSString *desc) {
        NSLog(@"failure, code:%d, desc:%@", code, desc);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([[YBYoungManager shareInstance] isOpenYoung]) {
        if (indexPath.section == 0) {
            SystemViewController *system = [[SystemViewController alloc]init];
            [[YBAppDelegate sharedAppDelegate] pushViewController:system animated:YES];
        }else if (indexPath.section == 1) {
            TChatController *chat = [[TChatController alloc] init];
            chat.conversation = _data[indexPath.row];
            [[YBAppDelegate sharedAppDelegate] pushViewController:chat animated:YES];

        }
    }else{
        if (indexPath.section == 0) {
            SubscribeViewController *subscribe = [[SubscribeViewController alloc]init];
            [[YBAppDelegate sharedAppDelegate] pushViewController:subscribe animated:YES];
        }else if (indexPath.section == 1) {
            SystemViewController *system = [[SystemViewController alloc]init];
            [[YBAppDelegate sharedAppDelegate] pushViewController:system animated:YES];
        }else if (indexPath.section == 2) {
            TChatController *chat = [[TChatController alloc] init];
            chat.conversation = _data[indexPath.row];
            [[YBAppDelegate sharedAppDelegate] pushViewController:chat animated:YES];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TConversationCell *cell  = [tableView dequeueReusableCellWithIdentifier:TConversationCell_ReuseId];
    if(!cell){
        cell = [[TConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TConversationCell_ReuseId];
    }
    if ([[YBYoungManager shareInstance] isOpenYoung]) {
        if (indexPath.section == 0) {
            TConversationCellData *dataa = [[TConversationCellData alloc] init];
            dataa.head = @"系统头像";
            dataa.title = YZMsg(@"系统消息");
            dataa.userName = YZMsg(@"系统消息");
            if (sysDic) {
                dataa.subTitle = minstr([sysDic valueForKey:@"content"]);
                dataa.time = [self getDateDisplayString:[self nsstringConversionNSDate:minstr([sysDic valueForKey:@"time"])]];
                dataa.unRead = [[sysDic valueForKey:@"unRead"] intValue];
            }else{
                dataa.subTitle = @"--";
                dataa.time = @"--";
            }
            [cell setData:dataa];

        }else{
            TConversationCellData *celldata =[_data objectAtIndex:indexPath.row];
            [cell setData:celldata];
        }

    }else{
        if (indexPath.section == 0) {
            TConversationCellData *dataa = [[TConversationCellData alloc] init];
            dataa.head = @"预约头像";
            dataa.title = YZMsg(@"预约");
            dataa.userName = YZMsg(@"预约");
            dataa.subTitle = subscribeNum;
            [cell setData:dataa];

        }else if (indexPath.section == 1){
            TConversationCellData *dataa = [[TConversationCellData alloc] init];
            dataa.head = @"系统头像";
            dataa.title = YZMsg(@"系统消息");
            dataa.userName = YZMsg(@"系统消息");
            if (sysDic) {
                dataa.subTitle = minstr([sysDic valueForKey:@"content"]);
                dataa.time = [self getDateDisplayString:[self nsstringConversionNSDate:minstr([sysDic valueForKey:@"time"])]];
                dataa.unRead = [[sysDic valueForKey:@"unRead"] intValue];
            }else{
                dataa.subTitle = @"--";
                dataa.time = @"--";
            }
            [cell setData:dataa];

        }else{
            TConversationCellData *celldata =[_data objectAtIndex:indexPath.row];
            [cell setData:celldata];
        }

    }
    return cell;
}
-(NSDate *)nsstringConversionNSDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datestr = [dateFormatter dateFromString:dateStr];
    return datestr;
}

//- (void)setData:(NSMutableArray *)data
//{
//    _data = data;
//    [_tableView reloadData];
//}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

//- (UIModalPresentationStyle)

//- (NSString *)getLastDisplayString:(TIMConversation *)conv
//{
//    NSString *str = @"";
//    TIMMessageDraft *draft = [conv getDraft];
//    if(draft){
//        for (int i = 0; i < draft.elemCount; ++i) {
//            TIMElem *elem = [draft getElem:i];
//            if([elem isKindOfClass:[TIMTextElem class]]){
//                TIMTextElem *text = (TIMTextElem *)elem;
//                str = [NSString stringWithFormat:@"[%@]%@", YZMsg(@"草稿"),text.text];
//                break;
//            }
//            else{
//                continue;
//            }
//        }
//        return str;
//    }
//    
//    TIMMessage *msg = [conv getLastMsg];
//    if(msg.status == TIM_MSG_STATUS_LOCAL_REVOKED){
//        if(msg.isSelf){
//            return YZMsg(@"你撤回了一条消息");
//        }
//        else{
//            return [NSString stringWithFormat:@"\"%@\"%@", YZMsg(@"对方"),YZMsg(@"撤回了一条消息")];
//        }
//    }
//    for (int i = 0; i < msg.elemCount; ++i) {
//        TIMElem *elem = [msg getElem:i];
//        if([elem isKindOfClass:[TIMTextElem class]]){
//            TIMTextElem *text = (TIMTextElem *)elem;
//            str = text.text;
//            break;
//        }
//        else if([elem isKindOfClass:[TIMCustomElem class]]){
//            TIMCustomElem *custom = (TIMCustomElem *)elem;
////            str = custom.ext;
//            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:custom.data options:NSJSONReadingMutableContainers error:nil];
//            if ([minstr([jsonDic valueForKey:@"method"]) isEqual:@"sendgift"]) {
//                str = [NSString stringWithFormat:@"[%@]",minstr([jsonDic valueForKey:@"giftname"])];
//                if (![lagType isEqual:ZH_CN] && ![YBToolClass checkNull:minstr([jsonDic valueForKey:@"giftname_en"])]) {
//                    str = [NSString stringWithFormat:@"[%@]",minstr([jsonDic valueForKey:@"giftname_en"])];
//                }
//            }else if ([minstr([jsonDic valueForKey:@"method"]) isEqual:@"call"]){
//                str = YZMsg(@"[通话]");
//            }
//            break;
//        }
//        else if([elem isKindOfClass:[TIMImageElem class]]){
//            str = YZMsg(@"[图片]");
//            break;
//        }
//        else if([elem isKindOfClass:[TIMSoundElem class]]){
//            str = YZMsg(@"[语音]");
//            break;
//        }
//        else if([elem isKindOfClass:[TIMVideoElem class]]){
//            str = YZMsg(@"[视频]");
//            break;
//        }
//        else if([elem isKindOfClass:[TIMFaceElem class]]){
//            str = @"[动画表情]";
//            break;
//        }
//        else if([elem isKindOfClass:[TIMFileElem class]]){
//            str = @"[文件]";
//            break;
//        }
//        else if([elem isKindOfClass:[TIMGroupTipsElem class]]){
//            TIMGroupTipsElem *tips = (TIMGroupTipsElem *)elem;
//            switch (tips.type) {
//                case TIM_GROUP_TIPS_TYPE_INFO_CHANGE:
//                {
//                    for (TIMGroupTipsElemGroupInfo *info in tips.groupChangeList) {
//                        switch (info.type) {
//                            case TIM_GROUP_INFO_CHANGE_GROUP_NAME:
//                            {
//                                str = [NSString stringWithFormat:@"\"%@\"修改群名为\"%@\"", tips.opUser, info.value];
//                            }
//                                break;
//                            case TIM_GROUP_INFO_CHANGE_GROUP_INTRODUCTION:
//                            {
//                                str = [NSString stringWithFormat:@"\"%@\"修改群简介为\"%@\"", tips.opUser, info.value];
//                            }
//                                break;
//                            case TIM_GROUP_INFO_CHANGE_GROUP_NOTIFICATION:
//                            {
//                                str = [NSString stringWithFormat:@"\"%@\"修改群公告为\"%@\"", tips.opUser, info.value];
//                            }
//                                break;
//                            case TIM_GROUP_INFO_CHANGE_GROUP_OWNER:
//                            {
//                                str = [NSString stringWithFormat:@"\"%@\"修改群主为\"%@\"", tips.opUser, info.value];
//                            }
//                                break;
//                            default:
//                                break;
//                        }
//                    }
//                }
//                    break;
//                case TIM_GROUP_TIPS_TYPE_KICKED:
//                {
//                    NSString *users = [tips.userList componentsJoinedByString:@"、"];
//                    str = [NSString stringWithFormat:@"\"%@\"将\"%@\"剔出群组", tips.opUser, users];
//                }
//                    break;
//                case TIM_GROUP_TIPS_TYPE_INVITE:
//                {
//                    NSString *users = [tips.userList componentsJoinedByString:@"、"];
//                    str = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入群组", tips.opUser, users];
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//        else{
//            continue;
//        }
//    }
//    return str;
//}
-(NSString *)getUserDateString:(NSDate *)date{
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];

    dateFmt.dateFormat = @"MM/dd HH:mm";

    return [dateFmt stringFromDate:date];

}
- (NSString *)getDateDisplayString:(NSDate *)date
{
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:date];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    
    NSDateComponents *comp =  [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    
//    if (nowCmps.year != myCmps.year) {
//        dateFmt.dateFormat = @"yyyy/MM/dd";
//    }
//    else{
//        if (nowCmps.day==myCmps.day) {
//            dateFmt.AMSymbol = YZMsg(@"上午");
//            dateFmt.PMSymbol = YZMsg(@"下午");
//            dateFmt.dateFormat = @"aaa hh:mm";
//        } else if((nowCmps.day-myCmps.day)==1) {
//            dateFmt.AMSymbol = YZMsg(@"上午");
//            dateFmt.PMSymbol = YZMsg(@"下午");
//            dateFmt.dateFormat = YZMsg(@"昨天");
//        } else {
//            if ((nowCmps.day-myCmps.day) <=7) {
//                switch (comp.weekday) {
//                    case 1:
//                        dateFmt.dateFormat = YZMsg(@"星期日");
//                        break;
//                    case 2:
//                        dateFmt.dateFormat = YZMsg(@"星期一");
//                        break;
//                    case 3:
//                        dateFmt.dateFormat = YZMsg(@"星期二");
//                        break;
//                    case 4:
//                        dateFmt.dateFormat = YZMsg(@"星期三");
//                        break;
//                    case 5:
//                        dateFmt.dateFormat = YZMsg(@"星期四");
//                        break;
//                    case 6:
//                        dateFmt.dateFormat = YZMsg(@"星期五");
//                        break;
//                    case 7:
//                        dateFmt.dateFormat = YZMsg(@"星期六");
//                        break;
//                    default:
//                        break;
//                }
//            }else {
//                dateFmt.dateFormat = @"yyyy/MM/dd";
//            }
//        }
//    }
    dateFmt.dateFormat = @"yyyy/MM/dd HH:mm:ss";

    return [dateFmt stringFromDate:date];
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

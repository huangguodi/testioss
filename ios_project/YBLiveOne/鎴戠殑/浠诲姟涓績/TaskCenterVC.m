//
//  TaskCenterVC.m
//  YBLiveOne
//
//  Created by yunbao01 on 2023/12/6.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "TaskCenterVC.h"
#import "TaskCenterCell.h"
#import "EditInfoViewController.h"
#import "AuthenticateVC.h"
#import "EditTrendsViewController.h"
#import "AppDelegate.h"
@interface TaskCenterVC ()<UITableViewDelegate, UITableViewDataSource,taskCenterDelegate>
{
    UIImageView *headImg;
    UIView *headView;
    NSDictionary *infoDic;
}
@property (nonatomic, strong)UITableView *listTable;
@property (nonatomic, strong)NSArray *daily_taskArray ;
@property (nonatomic, strong)NSArray *user_taskArray ;

@end

@implementation TaskCenterVC
-(void)getTaskList{
    [YBToolClass postNetworkWithUrl:@"User.getTaskList" andParameter:@{@"uid":[Config getOwnID],@"token":[Config getOwnToken]} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            infoDic = [info firstObject];
            _daily_taskArray = [infoDic valueForKey:@"daily_task_list"];
            _user_taskArray = [infoDic valueForKey:@"user_task_list"];

            [self.listTable reloadData];
            }else{
                [MBProgressHUD showError:msg];
            }
    } fail:^{
        
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self getTaskList];
}
-(void)doReturn{
    [[YBAppDelegate sharedAppDelegate]popViewController:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviView.hidden = YES;
    self.view.backgroundColor = RGBA(245, 245, 245, 1);
    self.daily_taskArray = [NSArray array];
    self.user_taskArray = [NSArray array];

    headImg = [[UIImageView alloc]init];
    headImg.frame = CGRectMake(0, 0, _window_width, _window_width *0.564);
    headImg.image = [UIImage imageNamed:@"centertaskTop"];
    headImg.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:headImg];
    
    UIButton *_returnBtn = [UIButton buttonWithType:0];
    _returnBtn.frame = CGRectMake(16, 24+statusbarHeight, 30, 30);
    [_returnBtn setImage:[UIImage imageNamed:@"white_backImg"] forState:0];
    [_returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_returnBtn];
    
    UILabel *bigTitle = [[UILabel alloc]init];
    bigTitle.frame = CGRectMake(_returnBtn.right-16, 24+statusbarHeight+40, _window_width-50, 40);
    bigTitle.font = [UIFont boldSystemFontOfSize:38];
    bigTitle.textColor = UIColor.whiteColor;
    bigTitle.text = YZMsg(@"任务中心");
    [headImg addSubview:bigTitle];
    
    UILabel *subTitle = [[UILabel alloc]init];
    subTitle.frame = CGRectMake(bigTitle.left, bigTitle.bottom+7, _window_width-50, 40);
    subTitle.font = [UIFont systemFontOfSize:18];
    subTitle.textColor = UIColor.whiteColor;
    subTitle.text = YZMsg(@"完成任务可获得丰厚奖励");
    [headImg addSubview:subTitle];

    
    [self.view addSubview:self.listTable];

}
-(UITableView *)listTable{
    if(!_listTable){
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(12, headImg.bottom-20, _window_width-24, _window_height-headImg.bottom-10) style:UITableViewStylePlain];
        _listTable.delegate = self;
        _listTable.dataSource = self;
        _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listTable.backgroundColor = UIColor.clearColor;
        _listTable.tableHeaderView = headView;
        _listTable.estimatedRowHeight = 80;
    }
    return _listTable;
}
//-(UIView *)creatHeadview{
//    if(!headView){
//        
//    }
//    return headView;
//}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return _user_taskArray.count;
    }else{
        return _daily_taskArray.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"TaskCenterCell%ld",indexPath.row];
    TaskCenterCell *cell = [[TaskCenterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if(indexPath.section == 0){
        NSDictionary *userDataDic =_user_taskArray[indexPath.row];
        cell.dataDic =userDataDic;
        if([minstr([userDataDic valueForKey:@"status"]) isEqual:@"0"]){
            [cell.statusBtn setTitle: YZMsg(@"去完成")  forState:0];
            [cell.statusBtn setBackgroundColor:normalColors];
            cell.statusBtn.userInteractionEnabled =YES;
        }else{
            [cell.statusBtn setTitle: YZMsg(@"已完成")  forState:0];
            [cell.statusBtn setBackgroundColor:UIColor.grayColor];
            cell.statusBtn.userInteractionEnabled =NO;
        }

    }else{
        NSDictionary *dailyDic =_daily_taskArray[indexPath.row];
        cell.dataDic =dailyDic;
        if([minstr([dailyDic valueForKey:@"status"]) isEqual:@"0"]){
            [cell.statusBtn setTitle: YZMsg(@"去完成")  forState:0];
            [cell.statusBtn setBackgroundColor:normalColors];
            cell.statusBtn.userInteractionEnabled =YES;
        }else  if([minstr([dailyDic valueForKey:@"status"]) isEqual:@"1"]){
            [cell.statusBtn setTitle: YZMsg(@"可领取")  forState:0];
            [cell.statusBtn setBackgroundColor:normalColors];
            cell.statusBtn.userInteractionEnabled =YES;
        }else{
            [cell.statusBtn setTitle: YZMsg(@"已完成")  forState:0];
            [cell.statusBtn setBackgroundColor:UIColor.grayColor];
            cell.statusBtn.userInteractionEnabled =NO;
        }

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width-24, 50)];
    headView.backgroundColor = UIColor.whiteColor;
    headView.layer.mask = [[YBToolClass sharedInstance] setViewLeftTop:10 andRightTop:10 andView:headView];
    
    UILabel *headTitle = [[UILabel alloc]init];
    headTitle.font = [UIFont boldSystemFontOfSize:16];
    headTitle.textColor = UIColor.blackColor;
    if(section == 0){
        headTitle.text =[infoDic valueForKey:@"user_task_title"];
    }else{
        headTitle.text =[infoDic valueForKey:@"daily_task_title"];
    }
    [headView addSubview:headTitle];
    [headTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(16);
        make.centerY.equalTo(headView.mas_centerY);
    }];
    return headView;

}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0){
        return 15;
    }else{
        return 0;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 10)];
    footView.backgroundColor = RGBA(245, 245, 245, 1);
    return footView;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat sectionHeaderHeight = 50;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y> 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }else{
        if(scrollView.contentOffset.y >= sectionHeaderHeight){
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}
-(void)taskStatusClick:(NSDictionary *)dataDic
{
    NSString *sing =minstr([dataDic valueForKey:@"sign"]);
    if ([sing isEqual:@"up_avatar"]){
        //上传头像
        EditInfoViewController *auth = [[EditInfoViewController alloc]init];
        [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];
    }else if ([sing isEqual:@"user_auth"]){
        //实名认证
        AuthenticateVC *auth = [[AuthenticateVC alloc]init];
        [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];
    }else if ([sing isEqual:@"anchor_auth"]){
        //主播认证
        AuthenticateVC *auth = [[AuthenticateVC alloc]init];
        [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];
    }else if ([sing isEqual:@"update_info"]){
        //完善资料
        EditInfoViewController *auth = [[EditInfoViewController alloc]init];
        [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];
    }else if([sing isEqual:@"daily_signin"]){
        //每日签到
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showBonus" object:nil];
    }else if([sing isEqual:@"publish_dynamic"]){
        //发布动态
        EditTrendsViewController *editTrends = [[EditTrendsViewController alloc]init];
        [[YBAppDelegate sharedAppDelegate] pushViewController:editTrends animated:YES];
    }else if([sing isEqual:@"like_dynamic"]){
        //点赞动态
        [[YBAppDelegate sharedAppDelegate] popViewController:NO];
        UIApplication *app =[UIApplication sharedApplication];

        AppDelegate *app2 = (AppDelegate *)app.delegate;
        app2.ybtab.selectedIndex = 1;
    }else if([sing isEqual:@"send_privatemsg"]){
        //发送私信
        //点赞动态
        [[YBAppDelegate sharedAppDelegate] popViewController:NO];
        UIApplication *app =[UIApplication sharedApplication];

        AppDelegate *app2 = (AppDelegate *)app.delegate;
        app2.ybtab.selectedIndex = 2;

    }else if([sing isEqual:@"voice_call"]){
        //语音通话
        [[YBAppDelegate sharedAppDelegate] popViewController:NO];
        UIApplication *app =[UIApplication sharedApplication];

        AppDelegate *app2 = (AppDelegate *)app.delegate;
        app2.ybtab.selectedIndex = 0;

    }else if([sing isEqual:@"video_call"]){
        //视频通话
        [[YBAppDelegate sharedAppDelegate] popViewController:NO];
        UIApplication *app =[UIApplication sharedApplication];

        AppDelegate *app2 = (AppDelegate *)app.delegate;
        app2.ybtab.selectedIndex = 0;

    }else if([sing isEqual:@"open_live"]){
        //开启直播
        [[YBAppDelegate sharedAppDelegate] popViewController:NO];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Golive" object:nil];
    }
}
-(void)reloadTaskList{
    [self getTaskList];
}
@end

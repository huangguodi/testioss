//
//  UserListViewController.m
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "UserListViewController.h"
#import "userlistCell.h"
#import "YBUserScreenView.h"
#import "PersonMessageViewController.h"
#import "SearchModel.h"
#import "PersonMessageViewController.h"
#import "TChatController.h"
@interface UserListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    CGFloat oldOffset;
    int page;
    YBUserScreenView *screenView;
}
@property(nonatomic,strong) UITableView *tableviews;
@property(nonatomic,strong)NSMutableArray *infoArray;
@property (nonatomic,strong) NSString *screenType;
@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.naviView.hidden = YES;
    _screenType = @"1";
    page = 1;
    oldOffset = 0;
    self.infoArray = [NSMutableArray array];
    [self creatUI];
    [self pullData];
}
-(void)creatUI{
    _tableviews = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height-64-statusbarHeight-60-_window_width / 6) style:UITableViewStylePlain];
    _tableviews.delegate = self;
    _tableviews.dataSource = self;
    _tableviews.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableviews.showsHorizontalScrollIndicator = NO;
    _tableviews.showsVerticalScrollIndicator = NO;
    _tableviews.backgroundColor = [UIColor whiteColor];//RGB(240, 240, 240);
    _tableviews.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self pullData];
    }];
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    _tableviews.mj_footer = footer;
//    [footer setTitle:YZMsg(@"数据加载中...") forState:MJRefreshStateRefreshing];
//    [footer setTitle:YZMsg(@"没有更多了哦~") forState:MJRefreshStateIdle];
    [footer setTitle:YZMsg(@"没有更多数据了") forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:15.0f];
    footer.automaticallyHidden = YES;
  
    self.view.backgroundColor = [UIColor whiteColor];;
    [self.view addSubview:_tableviews];
//    _tableviews.contentInset = UIEdgeInsetsMake(64+statusbarHeight, 0, 0, 0);
}
-(void)refreshFooter{
    page +=1;
    [self pullData];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    userlistCell *cell = [userlistCell cellWithTab:tableView indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SearchModel *model = self.infoArray[indexPath.row];
    cell.model = model;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchModel *model = self.infoArray[indexPath.row];
    if ([model.isauthor_auth isEqual:@"1"]) {
        [MBProgressHUD showMessage:@""];
        [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":model.userID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
        //进入聊天页面
        //消息
        TConversationCellData *data = [[TConversationCellData alloc] init];
        data.convId = model.userID;
        data.convType = TConv_Type_C2C;
        data.title = model.user_nickname;
        data.userHeader = model.avatar;
        data.userName = model.user_nickname;
        data.level_anchor = model.level;
        data.isauth = model.isauth;
        data.isAtt = model.isAtt;
        data.isVIP = model.isVip;
        data.isblack = model.isblack;
        TChatController *chat = [[TChatController alloc] init];
        chat.conversation = data;
        [[YBAppDelegate sharedAppDelegate] pushViewController:chat animated:YES];
    }
   
}
-(void)pullData{
    [YBToolClass postNetworkWithUrl:@"User.getUserList" andParameter:@{@"p":@(page),@"type":_screenType} success:^(int code,id info,NSString *msg) {
        [_tableviews.mj_header endRefreshing];
        [_tableviews.mj_footer endRefreshing];
        
        if (code == 0) {
            NSArray *list = info;
            if (page == 1) {
                [_infoArray removeAllObjects];
            }
            for (NSDictionary *dic in list) {
                SearchModel *model = [[SearchModel alloc]initWithDic:dic];
                [_infoArray addObject:model];
            }
            if (list.count <= 0 && _infoArray.count > 0) {
                [_tableviews.mj_footer endRefreshingWithNoMoreData];
            }
            
        }
        [_tableviews reloadData];
        if (_infoArray.count == 0) {
            [PublicView showTextNoData:_tableviews text1:@"" text2:YZMsg(@"暂无数据")];
        }else{
            [PublicView hiddenImgNoData:_tableviews];
        }

    } fail:^{
        [_tableviews.mj_header endRefreshing];
        [_tableviews.mj_footer endRefreshing];
        if (_infoArray.count == 0) {
            [PublicView showTextNoData:_tableviews text1:@"" text2:YZMsg(@"暂无数据")];
        }else{
            [PublicView hiddenImgNoData:_tableviews];
        }

    }];
}
#pragma mark ============筛选弹窗=============
- (void)showYBScreendView{
    if (!screenView) {
        screenView = [[YBUserScreenView alloc]init];
        [[UIApplication sharedApplication].keyWindow addSubview:screenView];
    }
    WeakSelf;
    screenView.block = ^(NSDictionary * _Nonnull dic) {
        weakSelf.screenType = [dic valueForKey:@"type"];
        page = 1;
        [weakSelf pullData];
    };
    [screenView show];
}
#pragma mark ================ 隐藏和显示tabbar ===============

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    oldOffset = scrollView.contentOffset.y;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > oldOffset) {
        if (scrollView.contentOffset.y > 0) {
            _pageView.hidden = YES;
            [self hideTabBar];
        }
    }else{
        _pageView.hidden = NO;
        [self showTabBar];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%f",oldOffset);
}
- (void)hideTabBar {
    
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    self.tabBarController.tabBar.hidden = YES;
}
- (void)showTabBar

{
    if (self.tabBarController.tabBar.hidden == NO)
    {
        return;
    }
    self.tabBarController.tabBar.hidden = NO;
    
}


@end

//
//  AuthenticateVC.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/11/26.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "AuthenticateVC.h"
#import "AuthCell.h"
#import "IdentityAuthVC.h"
#import "AnchorAuthVC.h"
@interface AuthenticateVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSDictionary *infoDic;
}
@property (nonatomic, strong)UITableView *listTable;
@property (nonatomic, strong)NSArray *dataArr;
@end

@implementation AuthenticateVC
//获取用户实名认证和主播认证状态

-(void)requestAuthStatus{
    NSDictionary *parDic = @{@"uid":[Config getOwnID],@"token":[Config getOwnToken]};
    [YBToolClass postNetworkWithUrl:@"Auth.getAuthStatus" andParameter:parDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSArray *infos = info;
            infoDic = [infos firstObject];
            _dataArr = [infoDic valueForKey:@"auth_info"];
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
    [self requestAuthStatus];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = YZMsg(@"我要认证");
    self.view.backgroundColor = RGBA(245, 245, 245, 1);
    _dataArr =[NSArray array];
    [self.view addSubview:self.listTable];
    
}
-(UITableView *)listTable{
    if (!_listTable) {
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-ShowDiff) style:0];
        _listTable.delegate = self;
        _listTable.dataSource = self;
        _listTable.separatorStyle = 0;
        _listTable.backgroundColor = UIColor.clearColor;
    }
    return _listTable;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AuthCell *cell = [AuthCell cellWithTab:tableView andIndexPath:indexPath];
    cell.cellData = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _dataArr[indexPath.row];
    if ([minstr([dic valueForKey:@"auth_type"]) isEqual:@"user_auth"]) {
        IdentityAuthVC *idauth = [[IdentityAuthVC alloc]init];
        idauth.authDic = dic;
        [[YBAppDelegate sharedAppDelegate]pushViewController:idauth animated:YES];
    }else{
        if (![minstr([infoDic valueForKey:@"user_auth_status"]) isEqual:@"1"]) {
            [MBProgressHUD showError:YZMsg(@"请先进行实名认证")];
            return;
        }
        AnchorAuthVC *idauth = [[AnchorAuthVC alloc]init];
        idauth.authDic = dic;
        [[YBAppDelegate sharedAppDelegate]pushViewController:idauth animated:YES];
    }
}
@end

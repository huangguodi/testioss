//
//  OnlineUserView.m
//  YBLive
//
//  Created by ybRRR on 2023/6/21.
//  Copyright © 2023 cat. All rights reserved.
//

#import "OnlineUserView.h"
#import "OnlineUserCell.h"

@interface OnlineUserView ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *listTable;
    NSArray *_infoArr;
}
@end


@implementation OnlineUserView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = RGBA(1, 1, 1, 0.4);
        _infoArr = [NSArray array];
        
        UIView *backView = [[UIView alloc]init];
        backView.frame = CGRectMake(0, _window_height *0.3, _window_width, _window_height *0.7);
        backView.backgroundColor = UIColor.whiteColor;
        [self addSubview:backView];
        
        UILabel *titleLb = [[UILabel alloc]init];
        titleLb.frame = CGRectMake(50, 10, _window_width-100, 30);
        titleLb.text = YZMsg(@"在线观众");
        titleLb.font = [UIFont boldSystemFontOfSize:16];
        titleLb.textColor = UIColor.blackColor;
        titleLb.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:titleLb];
        
        UIButton *closeBtn = [UIButton buttonWithType:0];
        closeBtn.frame = CGRectMake(_window_width-40, 10, 30, 30);
        [closeBtn setImage:[UIImage imageNamed:@"standardClose"] forState:0];
        [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:closeBtn];
        
        listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, titleLb.bottom+10, _window_width, backView.height-50) style:UITableViewStylePlain];
        listTable.delegate = self;
        listTable.dataSource = self;
        listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [backView addSubview:listTable];
        
    }
    return self;
}

- (void)setLiveDic:(NSDictionary *)liveDic {
    _liveDic = liveDic;
    [self getUserRank];
}

-(void)getUserRank{
    NSDictionary *dic = @{
                          @"uid":[Config getOwnID],
                          @"token":[Config getOwnToken],
                          @"liveuid":minstr([_liveDic valueForKey:@"liveuid"]),
                          @"stream":minstr([_liveDic valueForKey:@"stream"]),
                        };
    [YBToolClass postNetworkWithUrl:@"Zlive.getUserRank" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if(code == 0){
            _infoArr = [NSArray arrayWithArray:info];
            [listTable reloadData];
        }else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
}
-(void)closeBtnClick{
    if(self.onlineEvent){
        self.onlineEvent(Live_Online_Close, @{});
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _infoArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OnlineUserCell *cell = [OnlineUserCell cellWithTab:tableView andIndexPath:indexPath];
    cell.numLb.text =[NSString stringWithFormat:@"%ld",indexPath.row+1];
    if(indexPath.row == 0){
        cell.numLb.textColor = RGB_COLOR(@"#FF4C4C", 1);
    }else if (indexPath.row == 1){
        cell.numLb.textColor = RGB_COLOR(@"#FFAD4C", 1);
    }else if (indexPath.row == 2){
        cell.numLb.textColor = RGB_COLOR(@"#FFEC4C", 1);
    }
    cell.dataDic = _infoArr[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *user =_infoArr[indexPath.row];
    NSDictionary *notiDic = @{
        @"id":minstr([user valueForKey:@"id"]),
        @"name":minstr([user valueForKey:@"user_nickname"]),
    };
    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Userinfo object:nil userInfo:notiDic];
}
@end

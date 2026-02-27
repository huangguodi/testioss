//
//  GuardRankVC.m
//  YBLiveOne
//
//  Created by yunbao01 on 2023/12/9.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "GuardRankVC.h"
#import "GuardRankModel.h"
#import "GuardRankCell.h"
#import "PersonMessageViewController.h"

@interface GuardRankVC ()<UITableViewDelegate,UITableViewDataSource> {
    int paging;
    NSArray *oneArr;                  //收益-消费
    NSArray *twoArr;                  //日-周-月-总
    NSMutableArray *btnArray;        //日-周-月-总 按钮数组
    int selectTypeIndex;
    UIImageView  *navi;
//    YBNoWordView *noNetwork;
    MJRefreshAutoNormalFooter *rankFooter;
    UIImageView *headerImgView;
}
@property (nonatomic,strong) UITableView *tableView;
//@property (nonatomic,strong) NSArray *models;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation GuardRankVC

-(void)pullData {
    paging = 1;
    NSDictionary *postDic = @{@"uid":[Config getOwnID],
                              @"type":twoArr[selectTypeIndex],
                              @"p":@(paging)
                              };
    [YBToolClass postNetworkWithUrl:@"User.guardList" andParameter:postDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
//        noNetwork.hidden = YES;
        _tableView.hidden = NO;
        if (code == 0) {
            NSArray *infoA = info;
            if (paging == 1) {
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:infoA];
            if (infoA.count <=10) {
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.tableView reloadData];
            if (paging == 1) {
                [self resetTableHeaderView];
            }
            if (_dataArray.count == 0) {
                [rankFooter setTitle:YZMsg(@"虚位以待") forState:MJRefreshStateNoMoreData];
            }else{
                [rankFooter setTitle:@"" forState:MJRefreshStateNoMoreData];

            }
        }else {
            [MBProgressHUD showError:msg];
        }

        } fail:^{
            [_tableView.mj_header endRefreshing];
            [_tableView.mj_footer endRefreshing];
            if (_dataArray.count == 0) {
    //            noNetwork.hidden = NO;
                _tableView.hidden = YES;
            }
            [MBProgressHUD showError:YZMsg(@"网络请求失败")];

        }];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self pullData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataArray = [NSMutableArray array];
    oneArr = @[@"User.guardList"];
    twoArr = @[@"day",@"week",@"month",@"total"];
    [self creatNavi];
    
    paging = 1;
    [self.view addSubview:self.tableView];
    [self creatTableHeaderView];
    [self pullData];
}
-(UIImage *)drawBckgroundImage:(CGFloat)r :(CGFloat)g :(CGFloat)b {
    CGSize size = CGSizeMake(2, 35);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, r/255.0, g/255.0, b/255.0, 1);
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
#pragma mark -
#pragma mark - 点击事件
-(void)clickFollowBtn:(UIButton *)btn {

    btn.enabled = NO;
    GuardRankModel *model = [[GuardRankModel alloc] initWithDic:[_dataArray objectAtIndex:btn.tag - 10085]];
    if ([model.uidStr isEqual:[Config getOwnID]]) {
        [MBProgressHUD showError:YZMsg(@"不能关注自己")];
        btn.enabled = YES;
        return;
    }
    
    [YBToolClass postNetworkWithUrl:@"User.SetAttent" andParameter:@{@"touid":model.uidStr} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        btn.enabled = YES;
        if (code == 0) {
            NSString *isAtt = YBValue([info firstObject], @"isattent");
            NSMutableDictionary *needReloadDic = [NSMutableDictionary dictionaryWithDictionary:_dataArray[btn.tag - 10085]];
            [needReloadDic setValue:isAtt forKey:@"isAttention"];
            NSMutableArray *m_arr = [NSMutableArray arrayWithArray:_dataArray];
            [m_arr replaceObjectAtIndex:(btn.tag - 10085) withObject:needReloadDic];
            _dataArray = [m_arr mutableCopy];
            
            if (btn.tag >= 10088) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:(btn.tag - 10088) inSection:0];
                [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }else{
                btn.selected = !btn.selected;
            }
        }
    } fail:^{
        btn.enabled = YES;
    }];
}
#pragma mark -
#pragma mark - UITableViewDelegate,UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 ) {
        return 0.01;
    }
    return 0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count <= 3) {
        return 0;
    }
    return self.dataArray.count-3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GuardRankModel *model = [[GuardRankModel alloc] initWithDic:[_dataArray objectAtIndex:indexPath.row+3]];
    GuardRankCell *cell = [GuardRankCell cellWithTab:tableView indexPath:indexPath];
    [cell.followBtn setImage:[UIImage imageNamed:getImagename(@"rank_fan_normal")] forState:UIControlStateNormal];
    [cell.followBtn setImage:[UIImage imageNamed:getImagename(@"rank_fan_select")] forState:UIControlStateSelected];

    cell.otherMCL.text = [NSString stringWithFormat:@"NO.%ld",indexPath.row+4];
    cell.model = model;
    
    [cell.followBtn addTarget:self action:@selector(clickFollowBtn:) forControlEvents:UIControlEventTouchUpInside];
    cell.followBtn.tag = 10088 + indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GuardRankModel *model = [[GuardRankModel alloc] initWithDic:[_dataArray objectAtIndex:indexPath.row+3]];
    [self pushUserMessageVC:model.uidStr];
}
#pragma mark -
#pragma mark - tableView
-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, navi.height, _window_width, _window_height-(navi.height)) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor =RGBA(114,85,245, 1);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            paging = 1;
            [self pullData];
        }];
        rankFooter =[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            paging ++;
            [self pullData];
        }];

        _tableView.mj_footer =rankFooter;
}
    return _tableView;
}
- (void)resetTableHeaderView{
    if (!headerImgView) {
        headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_width/750*638)];
    }
    headerImgView.userInteractionEnabled = YES;
    headerImgView.backgroundColor = UIColor.clearColor;
    headerImgView.image = [UIImage imageNamed:@"rank_贡献new"];
    navi.image = [UIImage imageNamed:@"rank_navi"];
    [headerImgView removeAllSubviews];
    
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:1]];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    
    if (_dataArray.count > 2) {
        [headerImgView addSubview:[self creatTopCellWithUserMsg:_dataArray[0] andNum:1]];
        [headerImgView addSubview:[self creatTopCellWithUserMsg:_dataArray[1] andNum:2]];
        [headerImgView addSubview:[self creatTopCellWithUserMsg:_dataArray[2] andNum:3]];
    }else if (_dataArray.count == 2) {
        [headerImgView addSubview:[self creatTopCellWithUserMsg:_dataArray[0] andNum:1]];
        [headerImgView addSubview:[self creatTopCellWithUserMsg:_dataArray[1] andNum:2]];
        [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    }else if (_dataArray.count == 1) {
        [headerImgView addSubview:[self creatTopCellWithUserMsg:_dataArray[0] andNum:1]];
        [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
        [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    }else{
        [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:1]];
        [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
        [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    }
    
    _tableView.tableHeaderView = headerImgView;

}
- (void)creatTableHeaderView{
    headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_width/750*638)];
    headerImgView.userInteractionEnabled = YES;
    headerImgView.backgroundColor = UIColor.clearColor;
//    headerImgView.image = [UIImage imageNamed:@"rank_收益"];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:1]];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    _tableView.tableHeaderView = headerImgView;
}
- (UIView *)creatTopCellWithUserMsg:(NSDictionary *)dic andNum:(int)num{
    UIView *view = [[UIView alloc]init];
    CGFloat width;
    UITapGestureRecognizer *tap;
    if (num == 1) {
        width = _window_width/375*130;
        view.frame = CGRectMake(_window_width/375*123, 0, width, _window_width/750*412);
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(num1Click:)];

    }
    if (num == 2) {
        width = _window_width/375*104;
        view.frame = CGRectMake(_window_width/375*22, 0, width, _window_width/750*461);
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(num2Click:)];
    }
    if (num == 3) {
        width = _window_width/375*105;
        view.frame = CGRectMake(_window_width/375*249, 0, width, _window_width/750*481);
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(num3Click:)];
        
    }
    [view addGestureRecognizer:tap];
//    view.backgroundColor = [UIColor whiteColor];
    if (dic) {
        
        //关注按钮
        UIButton *attionBtn = [UIButton buttonWithType:0];
        if (num == 1) {
            attionBtn.frame = CGRectMake(view.width/2-_window_width/375*22, view.height - _window_width/375*31, _window_width/375*44, _window_width/375*20);
        }
        if (num == 2) {
            attionBtn.frame = CGRectMake(view.width/2-_window_width/375*22, view.height - _window_width/375*35, _window_width/375*44, _window_width/375*20);
        }
        if (num == 3) {
            attionBtn.frame = CGRectMake(view.width/2-_window_width/375*22, view.height - _window_width/375*30, _window_width/375*44, _window_width/375*20);
        }

//        [attionBtn setImage:[UIImage imageNamed:getImagename(@"fans_关注_white")] forState:UIControlStateNormal];
//        [attionBtn setImage:[UIImage imageNamed:getImagename(@"fans_已关注")] forState:UIControlStateSelected];
        [attionBtn setImage:[UIImage imageNamed:getImagename(@"rank_fan_normal")] forState:UIControlStateNormal];
        [attionBtn setImage:[UIImage imageNamed:getImagename(@"rank_fan_select")] forState:UIControlStateSelected];

        if ([minstr([dic valueForKey:@"isAttention"]) isEqual:@"1"]) {
            attionBtn.selected = YES;
        }else{
            attionBtn.selected = NO;
        }
        attionBtn.tag = 10084+num;
        [attionBtn addTarget:self action:@selector(clickFollowBtn:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:attionBtn];

        
        UILabel *votesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, attionBtn.top-_window_width/375*29, view.width, _window_width/375*29)];
        votesLabel.font = [UIFont systemFontOfSize:11];
        votesLabel.textAlignment = NSTextAlignmentCenter;
        votesLabel.textColor = [UIColor whiteColor];
//        votesLabel.text = [NSString stringWithFormat:@"%@%@",minstr([dic valueForKey:@"totalcoin"]),[common name_votes]];
        [votesLabel setAttributedText:[self setAttStr:minstr([dic valueForKey:@"totalcoin"])]];
        [view addSubview:votesLabel];

        //性别
        UIImageView *sexImgView = [[UIImageView alloc]init];
        sexImgView.frame = CGRectMake(view.width/2-_window_width/375*20, votesLabel.top - _window_width/375*15, _window_width/375*18, _window_width/375*15);
        if ([minstr([dic valueForKey:@"sex"]) isEqual:@"1"]) {
            sexImgView.image = [UIImage imageNamed:@"sex_man"];
        }else{
            sexImgView.image = [UIImage imageNamed:@"sex_woman"];
        }
        [view addSubview:sexImgView];

        //等级
        UIImageView *levelImgView = [[UIImageView alloc]init];
        levelImgView.frame = CGRectMake(view.width/2, sexImgView.top, sexImgView.height * 2, sexImgView.height);
//        NSDictionary *levelDic = [common getUserLevelMessage:minstr([dic valueForKey:@"level"])];
//        [levelImgView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
        [levelImgView sd_setImageWithURL:[NSURL URLWithString:minstr([common getUserLevelMessage:minstr([dic valueForKey:@"level"])])]];
        [view addSubview:levelImgView];

        
        //名字
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.frame = CGRectMake(0, levelImgView.top-_window_width/375*28, view.width, _window_width/375*28);
        nameLabel.font = [UIFont boldSystemFontOfSize:15];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.text = minstr([dic valueForKey:@"user_nickname"]);
        [view addSubview:nameLabel];

        //头像边框
        UIImageView *headerImgView = [[UIImageView alloc]init];
        headerImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"rank_header%d",num]];
        //头像
        UIImageView *iconImgView = [[UIImageView alloc]init];
        
        

        if (num == 1) {
            iconImgView.frame = CGRectMake(view.width/2-view.width*13/25/2, 10+view.width/25*6, view.width*13/25, view.width*13/25);
            if (![YBToolClass checkNull:[dic valueForKey:@"avatar_thumb"]]) {
                 [iconImgView sd_setImageWithURL:[NSURL URLWithString:[dic valueForKey:@"avatar_thumb"]]];
            }
            [view addSubview:iconImgView];
            headerImgView.frame =CGRectMake(view.width/2-view.width*195/250/2, 10, view.width*195/250, view.width*195/250);
        }else{
            iconImgView.frame = CGRectMake(view.width/2-view.width*9/20/2, 10+view.width/200*45, view.width*9/20, view.width*9/20);
            if (![YBToolClass checkNull:[dic valueForKey:@"avatar_thumb"]]) {
                [iconImgView sd_setImageWithURL:[NSURL URLWithString:[dic valueForKey:@"avatar_thumb"]]];
            }
            [view addSubview:iconImgView];
            headerImgView.frame =CGRectMake(view.width/2-view.width*14/20/2, 10, view.width*14/20, view.width*14/20);
        }
        iconImgView.layer.cornerRadius = iconImgView.width/2;
        iconImgView.layer.masksToBounds = YES;
        iconImgView.bottom = nameLabel.top-2;
        headerImgView.bottom = nameLabel.top+10;
        [view addSubview:headerImgView];
        
    }else{
//        UIImageView *nothingImgView = [[UIImageView alloc]initWithFrame:CGRectMake(view.width*0.3, 50, view.width*0.4, view.width*0.4)];
//        nothingImgView.image = [UIImage imageNamed:@"rank_nothing"];
//        [view addSubview:nothingImgView];
//
//        UILabel *nothingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, nothingImgView.bottom+10, view.width, 20)];
//        nothingLabel.text = YZMsg(@"暂时空缺");
//        nothingLabel.textAlignment = NSTextAlignmentCenter;
//        nothingLabel.textColor = RGB_COLOR(@"#c8c8c8", 1);
//        nothingLabel.font = [UIFont systemFontOfSize:13];
//        [view addSubview:nothingLabel];
    }
    return view;
}
- (NSMutableAttributedString *)setAttStr:(NSString *)votes{
    NSString *name = [common name_votes];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",votes,name]];
//    [att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#ffffff", 1) range:NSMakeRange(votes.length+1, name.length)];
    return att;
}
-(void)returnBtnClick{
    [[YBAppDelegate sharedAppDelegate]popViewController:YES];
}
#pragma mark -
#pragma mark - navi
-(void)creatNavi {
    
    CGFloat naviHeight = _window_width/75*21+statusbarHeight > 105 ?  _window_width/75*21+statusbarHeight:105;
    navi = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, naviHeight)];
    navi.userInteractionEnabled = YES;
    navi.image = [UIImage imageNamed:@"rank_navi"];
    [self.view addSubview:navi];
    
    UIButton *returnBtn = [UIButton buttonWithType:0];
    returnBtn.frame = CGRectMake(16, 20+statusbarHeight, 40, 40);
    [returnBtn setImage:[UIImage imageNamed:@"personBack"] forState:0];
    [returnBtn addTarget:self action:@selector(returnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:returnBtn];
    
    UILabel *navTitle = [[UILabel alloc]init];
    navTitle.frame =  CGRectMake(_window_width/2-80, 27+statusbarHeight, 160, 30);
    navTitle.font = [UIFont systemFontOfSize:16];
    navTitle.textColor = UIColor.whiteColor;
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.text =YZMsg(@"守护榜单");
    [navi addSubview:navTitle];

    btnArray = [NSMutableArray array];
    NSArray *sgArr2 = [NSArray arrayWithObjects:YZMsg(@"日榜"),YZMsg(@"周榜"),YZMsg(@"月榜"),YZMsg(@"总榜"), nil];
    CGFloat speace = (_window_width*0.84 - 60*4)/3;
    for (int i = 0; i < sgArr2.count; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(_window_width*0.08+i*(60+speace), navTitle.bottom+15, 60, 24);
        [btn setTitle:sgArr2[i] forState:0];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.layer.cornerRadius = 3.0;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 1.0;
        btn.layer.borderColor = [UIColor clearColor].CGColor;
        btn.tag = 1000086+i;
        if (i == 0) {
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        [btn addTarget:self action:@selector(changeRankType:) forControlEvents:UIControlEventTouchUpInside];
        [navi addSubview:btn];
        [btnArray addObject:btn];
    }
}
- (void)changeRankType:(UIButton *)sender{
    selectTypeIndex = (int)sender.tag - 1000086;
    for (UIButton *btn in btnArray) {
        if (btn == sender) {
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
        }else{
            btn.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }
    paging = 1;

    [self pullData];
}
- (void)num1Click:(id)tap{
    if (_dataArray.count>0) {
        GuardRankModel *model = [[GuardRankModel alloc] initWithDic:[_dataArray objectAtIndex:0]];
        [self pushUserMessageVC:model.uidStr];
    }else{
//        [MBProgressHUD showError:YZMsg(@"暂时空缺")];
    }
}

- (void)num2Click:(id)tap{
    if (_dataArray.count>1) {
        GuardRankModel *model = [[GuardRankModel alloc] initWithDic:[_dataArray objectAtIndex:1]];
        [self pushUserMessageVC:model.uidStr];
    }else{
//        [MBProgressHUD showError:YZMsg(@"暂时空缺")];
    }
    
}

- (void)num3Click:(id)tap{
    if (_dataArray.count>2) {
        GuardRankModel *model = [[GuardRankModel alloc] initWithDic:[_dataArray objectAtIndex:2]];
        [self pushUserMessageVC:model.uidStr];
    }else{
//        [MBProgressHUD showError:YZMsg(@"暂时空缺")];
    }
    
}
- (void)pushUserMessageVC:(NSString *)uid{
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":uid} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

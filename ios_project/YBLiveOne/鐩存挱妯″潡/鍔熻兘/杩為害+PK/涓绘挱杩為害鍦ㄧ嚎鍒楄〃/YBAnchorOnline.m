//
//  YBAnchorOnline.m
//  YBVideo
//
//  Created by YB007 on 2020/10/16.
//  Copyright © 2020 cat. All rights reserved.
//

#import "YBAnchorOnline.h"

#import "YBAnchorOnlineCell.h"

@interface YBAnchorOnline()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>{
    UIView *whiteView;
    UITableView *listTable;
    int page;
    NSMutableArray *infoArray;
    UIButton *searchBtn;
    UIButton *closeBtn;
    
    int searchP;
    UITableView *searchTable;
    UILabel *searchNotingL;
    NSMutableArray *searchInfo;
}

@property (nonatomic,strong)UITextField *searchT;

@end

@implementation YBAnchorOnline

+(instancetype)showAnchorListOnView:(UIView *)superView;{
    YBAnchorOnline *view = [[YBAnchorOnline alloc]init];
    view.frame = CGRectMake(0, 0, _window_width, _window_height);
    [superView addSubview:view];
    [view setupView];
    return view;
}

-(void)setupView {
    page = 1;
    searchP = 1;
    infoArray = [NSMutableArray array];
    searchInfo = [NSMutableArray array];
    
    UIButton *button = [UIButton buttonWithType:0];
    button.frame = CGRectMake(0, 0, _window_width, _window_height*0.45);
    [button addTarget:self action:@selector(hideBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, _window_height*0.55)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:whiteView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = whiteView.bounds;
    maskLayer.path = maskPath.CGPath;
    whiteView.layer.mask = maskLayer;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
    [whiteView addSubview:headerView];
    
    //头部视图
    closeBtn = [UIButton buttonWithType:0];
    closeBtn.frame = CGRectMake(0, 5, 30, 30);
    [closeBtn setImage:[[UIImage imageNamed:@"gray_close"] imageChangeColor:[UIColor grayColor]] forState:0];
    [closeBtn setImage:[[UIImage imageNamed:@"gray_back"] imageChangeColor:[UIColor grayColor]] forState:UIControlStateSelected];
    closeBtn.selected = NO;
    [closeBtn addTarget:self action:@selector(hideSelf) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [headerView addSubview:closeBtn];
    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2-80, 0, 160, 40)];
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.font = [UIFont systemFontOfSize:13];
    titleL.textColor = RGB_COLOR(@"#626364", 1);
    titleL.text = YZMsg(@"当前在线主播");
    [headerView addSubview:titleL];
    
    searchBtn = [UIButton buttonWithType:0];
    searchBtn.frame = CGRectMake(_window_width-30, 5, 30, 30);
    [searchBtn setImage:[UIImage imageNamed:@"连麦-搜索"] forState:0];
    [searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    searchBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [headerView addSubview:searchBtn];
    
    _searchT = [[UITextField alloc]initWithFrame:CGRectMake(_window_width-40, 5, 0, 30)];
    _searchT.delegate = self;
    _searchT.placeholder = YZMsg(@"请输入您要搜索的主播昵称或ID");
    _searchT.backgroundColor = RGB_COLOR(@"#f1f1f1", 1);
    //TextField
    _searchT.layer.cornerRadius = 15;
    _searchT.layer.masksToBounds = YES;
    _searchT.font = [UIFont systemFontOfSize:14];
    _searchT.leftViewMode = UITextFieldViewModeAlways;
    _searchT.keyboardType = UIKeyboardTypeWebSearch;
    [headerView addSubview:_searchT];
    CGRect leftRect = CGRectMake(0, 0, 30, 30);
    if (@available(iOS 13.0,*)) {
        leftRect = CGRectMake(5, 5, 20, 20);
    }
    UIImageView *leftImgView = [[UIImageView alloc]initWithFrame:leftRect];
    leftImgView.image = [UIImage imageNamed:@"left_search"];
    _searchT.leftView = leftImgView;
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, _window_width, 1) andColor:RGB_COLOR(@"#f4f5f6", 1) andView:headerView];
    
    listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, headerView.bottom, _window_width, whiteView.height-40) style:0];
    listTable.delegate = self;
    listTable.dataSource = self;
    listTable.emptyDataSetSource = self;
    listTable.emptyDataSetDelegate = self;
    listTable.separatorStyle = 0;
    [whiteView addSubview:listTable];
    listTable.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        page = 1;
        [self requestData];
    }];
    listTable.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        page ++;
        [self requestData];
    }];
    
    searchTable = [[UITableView alloc]initWithFrame:CGRectMake(0, headerView.bottom, _window_width, whiteView.height-40) style:0];
    searchTable.delegate =self;
    searchTable.dataSource = self;
    searchTable.separatorStyle = 0;
    searchTable.hidden = YES;
    searchTable.backgroundColor = [UIColor whiteColor];
    [whiteView addSubview:searchTable];
    searchTable.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        searchP = 1;
        [self searchAnchorWithText:_searchT.text];
    }];
    searchTable.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        searchP ++;
        [self searchAnchorWithText:_searchT.text];
    }];
    searchNotingL = [[UILabel alloc]initWithFrame:CGRectMake(0, searchTable.height/2-10, searchTable.width, 20)];
    searchNotingL.font = [UIFont systemFontOfSize:13];
    searchNotingL.text = YZMsg(@"没有搜索到相关内容");
    searchNotingL.textAlignment = NSTextAlignmentCenter;
    searchNotingL.textColor = RGB_COLOR(@"#969696", 1);
    searchNotingL.hidden = YES;
    [searchTable addSubview:searchNotingL];
    
    UITapGestureRecognizer *tapSearchTba = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideBtnClick)];
    [searchTable addGestureRecognizer:tapSearchTba];
    
    [self requestData];
    
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = YZMsg(@"暂时没有主播");
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName: ybNodataFont,
                                 NSForegroundColorAttributeName: ybNodataCol,
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
    return 0;
}
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}

- (void)showOnlineView{
    [UIView animateWithDuration:0.3 animations:^{
        whiteView.frame = CGRectMake(0, _window_height*0.45, _window_width, _window_height*0.55);
    }];

}

- (void)requestData{
    
    [YBToolClass postNetworkWithUrl:@"Zlivepk.GetLiveList" andParameter:@{@"p":@(page)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [listTable.mj_header endRefreshing];
        [listTable.mj_footer endRefreshing];
        if (code == 0) {
            if (page == 1) {
                [infoArray removeAllObjects];
            }
            NSArray *infos = info;
            [infoArray addObjectsFromArray:infos];
            
            [listTable reloadData];
        }
    } fail:^{
        [listTable.mj_header endRefreshing];
        [listTable.mj_footer endRefreshing];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == listTable) {
        return infoArray.count;
    }
    return searchInfo.count;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YBAnchorOnlineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YBAnchorOnlineCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"YBAnchorOnlineCell" owner:nil options:nil] lastObject];
    }
    
    if (tableView == listTable) {
        cell.dataDic = infoArray[indexPath.row];
    }else{
        cell.dataDic = searchInfo[indexPath.row];
    }
    WeakSelf;
    cell.anchorOnlineCellEvent = ^(NSDictionary *cellDic) {
        [weakSelf cellBtnClickEvent:cellDic];
    };
    
    
    return cell;
}

-(void)cellBtnClickEvent:(NSDictionary *)cellDic {
    NSInteger timespece =  [self dateTimeDifferenceWithStartTime:minstr([cellDic valueForKey:@"starttime"])];
    if (timespece < 30) {
        [MBProgressHUD showError:YZMsg(@"对方刚开播，请稍后连麦")];
        return;
    }
    NSDictionary *postDic = @{@"stream":minstr([cellDic valueForKey:@"stream"]),@"uid_stream":_myStream};
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Zlivepk.CheckLive" andParameter:postDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *myNewPull = minstr([[info firstObject] valueForKey:@"pull"]);
            if (weakSelf.anchorListEvent) {
                weakSelf.anchorListEvent(AnchorListType_StartLink, cellDic, @{@"pull":myNewPull});
            }
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == searchTable) {
        [self hideBtnClick];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
#pragma mark - 搜索
- (void)searchAnchorWithText:(NSString *)text{
    
    [YBToolClass postNetworkWithUrl:@"Zlivepk.Search" andParameter:@{@"key":text,@"p":@(searchP)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [searchTable.mj_header endRefreshing];
        [searchTable.mj_footer endRefreshing];
        if (code == 0) {
            if (searchP == 1) {
                [searchInfo removeAllObjects];
            }
            NSArray *infos = info;
            [searchInfo addObjectsFromArray:infos];
            if (searchInfo.count > 0) {
                searchNotingL.hidden = YES;
            }else{
                searchNotingL.hidden = NO;
            }
            [searchTable reloadData];
        }else{
            [MBProgressHUD showError:msg];
            searchNotingL.hidden = NO;
        }
    } fail:^{
        searchNotingL.hidden = YES;
        [searchTable.mj_header endRefreshing];
        [searchTable.mj_footer endRefreshing];
    }];

}
#pragma mark - searchBar代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hideBtnClick];
    [self searchAnchorWithText:_searchT.text];
    return YES;
}

- (void)hideBtnClick{
    [_searchT resignFirstResponder];
}
- (void)cancelSearch{
    _searchT.text = @"";
    _searchT.frame = CGRectMake(_window_width-40, 5, 0, 30);
    searchBtn.hidden = NO;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [searchTable.layer addAnimation:transition forKey:nil];
    searchTable.hidden = YES;
    [searchInfo removeAllObjects];
    [searchTable reloadData];
}

- (void)hideSelf{
    if (closeBtn.selected) {
        closeBtn.selected = NO;
        [_searchT resignFirstResponder];
        [self cancelSearch];
        return;
    }
    if (self.anchorListEvent) {
        self.anchorListEvent(AnchorListType_Dismiss, @{}, @{});
    }
}

- (void)searchBtnClick{
    closeBtn.selected = YES;
    searchBtn.hidden = YES;
    [_searchT becomeFirstResponder];
    searchTable.hidden = NO;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [searchTable.layer addAnimation:transition forKey:nil];
    
    [UIView animateWithDuration:0.3 animations:^{
        _searchT.frame = CGRectMake(40, 5, _window_width-80, 30);
    }];
}

-(NSInteger)dateTimeDifferenceWithStartTime:(NSString *)startTime {
    NSDate *now = [NSDate date];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];

    NSString *nowstr = [formatter stringFromDate:now];
    NSDate *nowDate = [formatter dateFromString:nowstr];
    //设置时区,这个对于时间的处理有时很重要
    NSTimeInterval start = [startTime doubleValue];
    NSTimeInterval end = [nowDate timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    int second = (int)value %60;//秒
    int minute = (int)value /60%60;
    int house = (int)value / (24 * 3600)%3600;
    int day = (int)value / (24 * 3600);

    NSString *str;
    if (day != 0) {
        str = [NSString stringWithFormat:@"耗时%d天%d小时%d分%d秒",day,house,minute,second];
    }else if (day==0 && house != 0) {
        str = [NSString stringWithFormat:@"耗时%d小时%d分%d秒",house,minute,second];
    }else if (day== 0 && house== 0 && minute!=0) {
        str = [NSString stringWithFormat:@"耗时%d分%d秒",minute,second];
    }else{
        str = [NSString stringWithFormat:@"耗时%d秒",second];
    }
    return value;
}


@end

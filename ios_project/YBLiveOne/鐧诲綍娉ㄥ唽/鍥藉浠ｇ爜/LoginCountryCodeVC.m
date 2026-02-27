//
//  LoginCountryCodeVC.m
//  YBPlaying
//
//  Created by YB007 on 2020/12/19.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "LoginCountryCodeVC.h"

#import "LoginCountryCodeCell.h"

@interface LoginCountryCodeVC ()<UITableViewDelegate,UITableViewDataSource>
{
    int _paging;
    BOOL _isSearch;
    int _allNum;
}
@property(nonatomic,strong)YBSearchBarView *searchView;
@property(nonatomic,strong)UITableView *dataTableView;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)NSMutableArray *indexArray;
@property(nonatomic,strong)UITableView *searchTableView;

@end

@implementation LoginCountryCodeVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self pullData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleL.text = YZMsg(@"手机号归属地");
    
    _isSearch = NO;
    _paging = 1;
    _allNum = 0;
    self.dataArray = [NSMutableArray array];
    self.indexArray = [NSMutableArray array];
    
    WeakSelf;
    _searchView = [[YBSearchBarView alloc]initWithFrame:CGRectMake(0,self.naviView.bottom, _window_width ,60)];
    _searchView.backgroundColor = RGB_COLOR(@"#eeeeee", 1);
    _searchView.showCancle = NO;
    _searchView.showClear = NO;
    _searchView.searchTF.backgroundColor = UIColor.whiteColor;
    _searchView.searchEvent = ^(RKSearchType searchType) {
        [weakSelf searchEevnt:searchType];
    };
    [self.view addSubview:_searchView];
    //[_searchView.searchTF becomeFirstResponder];
    _searchView.searchTF.placeCol = RGB_COLOR(@"#969696", 1);
    _searchView.searchTF.tintColor = RGB_COLOR(@"#969696", 1);
    _searchView.searchTF.textColor = RGB_COLOR(@"#323232", 1);
    _searchView.searchTF.placeholder = YZMsg(@"请输入地区名");
    
    [self.view addSubview:self.dataTableView];
    
    
}
-(void)searchEevnt:(RKSearchType)searchType {
    NSString *allText = [_searchView.searchTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (searchType == RKSearch_Search) {
        //搜索
        if (allText.length > 0) {
            [self.view endEditing:YES];
            _paging = 1;
            _isSearch = YES;
            [self pullData];
        }
    }
    if (searchType == RKSearch_Cancle) {
        //取消
        _searchView.searchTF.text = @"";
        [_searchView.searchTF resignFirstResponder];
        [self.view endEditing:YES];
       
    }
    if (searchType == RKSearch_ValueChange) {
        //输入框改变
        if (allText.length > 0) {
            _isSearch = YES;
        }else{
            _isSearch = NO;
        }
        [self pullData];
    }
    if (searchType == RKSearch_BeginEditing) {
        //开始编辑
        if (_searchView.searchTF.text.length>0) {
            _isSearch = YES;
        }else{
            _isSearch = NO;
        }
    }
}

#pragma mark -
-(void)pullData {
    
    [YBToolClass postNetworkWithUrl:@"Login.getCountrys" andParameter:@{@"field":_searchView.searchTF.text} success:^(int code, id info, NSString *msg) {
        [_dataTableView.mj_header endRefreshing];
        [_dataTableView.mj_footer endRefreshing];
        if (code == 0) {
            if (![info isKindOfClass:[NSArray class]]) {
                return;
            }
            NSArray *infoA = [NSArray arrayWithArray:info];
            if (_paging == 1) {
                [_dataArray removeAllObjects];
                [_indexArray removeAllObjects];
                _allNum = 0;
            }
            if (infoA.count<=0) {
                [_dataTableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [_dataArray addObjectsFromArray:infoA];
                if (!_isSearch) {
                    for (NSDictionary *subDic in infoA) {
                        NSString *title = minstr([subDic valueForKey:@"title"]);
                        [_indexArray addObject:title];
                        NSArray *listA = [NSArray arrayWithArray:[subDic valueForKey:@"lists"]];
                        _allNum += listA.count;
                    }
                }else{
                    _allNum += infoA.count;
                }
            }
            if (_allNum <= 0) {
                [PublicView showTextNoData:_dataTableView text1:@"" text2:YZMsg(@"暂无数据")];
            }else {
                [PublicView hiddenImgNoData:_dataTableView];
            }
            [_dataTableView reloadData];
            
        }else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [_dataTableView.mj_header endRefreshing];
        [_dataTableView.mj_footer endRefreshing];
    }];
}
#pragma mark - UITableViewDelegate、UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!_isSearch) {
        return 30;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!_isSearch) {
        UIView *headerVie = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 30)];
        NSDictionary *subDic = _dataArray[section];
        UILabel *titleL = [[UILabel alloc]init];
        titleL.font = SYS_Font(16);
        titleL.textColor = RGB_COLOR(@"#323232", 1);
        titleL.text = minstr([subDic valueForKey:@"title"]);
        [headerVie addSubview:titleL];
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerVie.mas_left).offset(15);
            make.centerY.equalTo(headerVie);
        }];
        UILabel *lineL = [[UILabel alloc]init];
        lineL.backgroundColor = RGB_COLOR(@"#eeeeee", 70);
        [headerVie addSubview:lineL];
        [lineL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(headerVie.mas_width).offset(-30);
            make.centerX.bottom.equalTo(headerVie);
        }];
        return headerVie;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_isSearch) {
        return _dataArray.count;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!_isSearch) {
        NSDictionary *subDic = _dataArray[section];
        NSArray *listA = @[];
        if ([[subDic valueForKey:@"lists"] isKindOfClass:[NSArray class]]) {
            listA = [NSArray arrayWithArray:[subDic valueForKey:@"lists"]];
        }
        return listA.count;
    }
    return _dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LoginCountryCodeCell *cell = [LoginCountryCodeCell cellWithTab:tableView index:indexPath];
    NSDictionary *subDic;
    if (!_isSearch) {
        NSDictionary *cDic = _dataArray[indexPath.section];
        NSArray *listA = @[];
        if ([[cDic valueForKey:@"lists"] isKindOfClass:[NSArray class]]) {
            listA = [NSArray arrayWithArray:[cDic valueForKey:@"lists"]];
        }
        subDic = listA[indexPath.row];
    }else {
        subDic = _dataArray[indexPath.row];
    }
    cell.nameL.text = minstr([subDic valueForKey:@"name"]);
    if ([lagType isEqual:EN]) {
        cell.nameL.text = minstr([subDic valueForKey:@"name_en"]);
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *subDic;
    if (!_isSearch) {
        NSDictionary *cDic = _dataArray[indexPath.section];
        NSArray *listA = @[];
        if ([[cDic valueForKey:@"lists"] isKindOfClass:[NSArray class]]) {
            listA = [NSArray arrayWithArray:[cDic valueForKey:@"lists"]];
        }
        subDic = listA[indexPath.row];
    }else {
        subDic = _dataArray[indexPath.row];
    }
    NSString *code = minstr([subDic valueForKey:@"tel"]);
    if (self.countryEvent) {
        self.countryEvent(code);
    }
    [self doReturn];
}
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _indexArray;
}
/*
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSDictionary *subDic = _dataArray[index];
    NSArray *listA = @[];
    if ([[subDic valueForKey:@"lists"] isKindOfClass:[NSArray class]]) {
        listA = [NSArray arrayWithArray:[subDic valueForKey:@"lists"]];
    }
    if (listA.count>0) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:index];
        [tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return -1;
    }
    return index;
}
*/
#pragma mark - set/get
-(UITableView *)dataTableView {
    if (!_dataTableView) {
        _dataTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,_searchView.bottom, _window_width, _window_height - 64-statusbarHeight-_searchView.height)style:UITableViewStyleGrouped];
        _dataTableView.delegate   = self;
        _dataTableView.dataSource = self;
        _dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _dataTableView.backgroundColor = UIColor.whiteColor;
        _dataTableView.sectionIndexColor = RGB_COLOR(@"#323232", 1);
        WeakSelf;
        _dataTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _paging = 1;
            [weakSelf pullData];
        }];
        
        _dataTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            _paging = 1;
            [weakSelf pullData];
        }];
        _dataTableView.contentInset = UIEdgeInsetsMake(0, 0, ShowDiff, 0);
    }
    return _dataTableView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


@end

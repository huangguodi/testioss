//
//  YBUserListView.m
//  YBVideo
//
//  Created by YB007 on 2019/11/30.
//  Copyright © 2019 cat. All rights reserved.
//

#import "YBUserListView.h"
#import "YBUserListModel.h"
#import "YBUserListCell.h"
#import "OnlineUserView.h"

@interface YBUserListView()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    int _userCount;
}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *listArray;
@property(nonatomic,strong)NSMutableArray *listModel;
@property(nonatomic,strong)YBButton *numsBtn;

@property(nonatomic,strong)OnlineUserView *onlineView;

@end

@implementation YBUserListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _listArray = [NSMutableArray array];
        _listModel = [NSMutableArray array];
        [self addSubview:self.collectionView];
        [self addSubview:self.numsBtn];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.height.centerY.equalTo(self);
    }];
    [_numsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_collectionView.mas_right).offset(5);
        make.height.mas_equalTo(34);
        make.width.mas_greaterThanOrEqualTo(40);
        make.right.bottom.equalTo(self);
    }];
}
- (NSMutableArray *)listModel {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in _listArray) {
        YBUserListModel *model = [YBUserListModel modelWithDic:dic];
        [array addObject:model];
    }
    _listModel = [array mutableCopy];
    return _listModel;
}
-(void)changeNumsShow {
    if(_userCount > 99){
        [_numsBtn setTitle:@"99+" forState:0];
    }else{
        [_numsBtn setTitle:[NSString stringWithFormat:@"%d",_userCount] forState:0];
    }
}
#pragma mark - 用户第一次进房间、请求僵尸粉数组赋值
-(void)updateListCount:(NSArray *)listArray {
    if(_listArray.count>0){
        [_listArray removeAllObjects];
    }
    [_listArray addObjectsFromArray:listArray];
    [_collectionView reloadData];
    _userCount = (int)_listArray.count;
    [self changeNumsShow];
}
#pragma mark - 用户进入、离开 
-(void)userEventOfType:(UserEventType)eventType andInfo:(NSDictionary *)eventDic {
    if (eventType == UserEvent_Enter) {
        //进入
        _userCount +=1;
        
        NSString *ID = [[eventDic valueForKey:@"ct"] valueForKey:@"id"];
        [_listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            for (NSDictionary *dic in _listArray) {
                int a = [[dic valueForKey:@"id"] intValue];
                int bsss = [ID intValue];
                if ([[dic valueForKey:@"id"] isEqual:ID] || a == bsss) {
                    [_listArray removeObject:dic];
                    break;
                }
            }
        }];
        NSDictionary *subdic = [eventDic valueForKey:@"ct"];
        [self.listArray addObject:subdic];
        [_collectionView reloadData];
    }else {
        //离开
        _userCount -=1;
        if (_userCount <=0) {
            _userCount = 0;
        }
        
        NSDictionary *SUBdIC =[eventDic valueForKey:@"ct"];
        NSString *ID = [SUBdIC valueForKey:@"id"];
        [_listArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            for (NSDictionary *dic in _listArray) {
                if ([[dic valueForKey:@"id"] isEqual:ID]) {
                    [_listArray removeObject:dic];
                    [_collectionView reloadData];
                    return ;
                }
            }
        }];
    }
    
    [self changeNumsShow];
}
#pragma mark - /** 计时器刷新 */
-(void)timerReloadList {
    if ([YBToolClass checkNull:_liveUid] || [YBToolClass checkNull:_liveStream]) {
        [MBProgressHUD showError:YZMsg(@"缺少信息")];
        return;
    }
    NSDictionary *postDic = @{
        @"liveuid":_liveUid,
        @"stream":_liveStream,
    };
    [YBToolClass postNetworkWithUrl:@"Zlive.getUserLists" andParameter:postDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSArray *infos = [info firstObject];
            NSArray *list = [infos valueForKey:@"userlist"];
            if ([list isEqual:[NSNull null]]) {
                return ;
            }
            [_listArray removeAllObjects];
            [_listArray addObjectsFromArray:list];
            [_collectionView reloadData];
            _userCount = (int)_listArray.count;
            [self changeNumsShow];
            /*
// rk_测试数据
            list = @[@{
                @"id": @"106495",
                @"user_nickname": @"手机用户960",
                @"avatar": @"http://shejiao.yunbaozhibo.com/default.png",
                @"avatar_thumb": @"http://shejiao.yunbaozhibo.com/default_thumb.png",
                @"sex": @1,
                @"signature": @"这家伙很懒，什么都没留下",
                @"birthday": @0,
                @"online": @0,
                @"isvideo": @0,
                @"isvoice": @0,
                @"isdisturb": @0,
                @"voice_value": @0,
                @"video_value": @0,
                @"is_firstlogin": @1,
                @"recommend_val": @0,
                @"issuper": @0,
                @"level": @"1",
                @"level_anchor": @"1",
                @"vip": @{
                    @"type": @"0",
                    @"endtime": @""
                },
                @"contribution": @"66"
            },@{
                @"id": @"106495",
                @"user_nickname": @"手机用户960",
                @"avatar": @"http://shejiao.yunbaozhibo.com/default.png",
                @"avatar_thumb": @"http://shejiao.yunbaozhibo.com/default_thumb.png",
                @"sex": @1,
                @"signature": @"这家伙很懒，什么都没留下",
                @"birthday": @0,
                @"online": @0,
                @"isvideo": @0,
                @"isvoice": @0,
                @"isdisturb": @0,
                @"voice_value": @0,
                @"video_value": @0,
                @"is_firstlogin": @1,
                @"recommend_val": @0,
                @"issuper": @0,
                @"level": @"1",
                @"level_anchor": @"1",
                @"vip": @{
                    @"type": @"0",
                    @"endtime": @""
                },
                @"contribution": @"66"
            },@{
                @"id": @"106495",
                @"user_nickname": @"手机用户960",
                @"avatar": @"http://shejiao.yunbaozhibo.com/default.png",
                @"avatar_thumb": @"http://shejiao.yunbaozhibo.com/default_thumb.png",
                @"sex": @1,
                @"signature": @"这家伙很懒，什么都没留下",
                @"birthday": @0,
                @"online": @0,
                @"isvideo": @0,
                @"isvoice": @0,
                @"isdisturb": @0,
                @"voice_value": @0,
                @"video_value": @0,
                @"is_firstlogin": @1,
                @"recommend_val": @0,
                @"issuper": @0,
                @"level": @"1",
                @"level_anchor": @"1",
                @"vip": @{
                    @"type": @"0",
                    @"endtime": @""
                },
                @"contribution": @"66"
            },@{
                @"id": @"106495",
                @"user_nickname": @"手机用户960",
                @"avatar": @"http://shejiao.yunbaozhibo.com/default.png",
                @"avatar_thumb": @"http://shejiao.yunbaozhibo.com/default_thumb.png",
                @"sex": @1,
                @"signature": @"这家伙很懒，什么都没留下",
                @"birthday": @0,
                @"online": @0,
                @"isvideo": @0,
                @"isvoice": @0,
                @"isdisturb": @0,
                @"voice_value": @0,
                @"video_value": @0,
                @"is_firstlogin": @1,
                @"recommend_val": @0,
                @"issuper": @0,
                @"level": @"1",
                @"level_anchor": @"1",
                @"vip": @{
                    @"type": @"0",
                    @"endtime": @""
                },
                @"contribution": @"66"
            }];
            
            [_listArray removeAllObjects];
            [_listArray addObjectsFromArray:list];
            [_collectionView reloadData];
            
            
             //rk_临时测试
            _userCount = (int)_listArray.count;
            [self changeNumsShow];
            */
        }
    } fail:^{
        
    }];
    
    
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.listModel.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YBUserListCell *cell = (YBUserListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"YBUserListCell" forIndexPath:indexPath];
    YBUserListModel *model = _listModel[indexPath.row];
    cell.model = model;
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row < 3 && [model.contribution intValue]>0) {
        cell.kuang.image = [UIImage imageNamed:[NSString stringWithFormat:@"userlist_no%ld",indexPath.row+1]];
    }else{
        cell.kuang.image = [UIImage new];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YBUserListModel *model = _listModel[indexPath.row];
    NSString *ID = model.userID;
    NSDictionary *subdic  = [NSDictionary dictionaryWithObjects:@[ID,model.user_nickname] forKeys:@[@"id",@"name"]];
    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Userinfo object:nil userInfo:subdic];
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(45,45);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,5,0,5);
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowlayoutt = [[UICollectionViewFlowLayout alloc]init];
        flowlayoutt.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0,self.width,self.height) collectionViewLayout:flowlayoutt];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[YBUserListCell class] forCellWithReuseIdentifier:@"YBUserListCell"];
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

-(void)destroySubs; {
    [self destroyOnlineView];
}

- (YBButton *)numsBtn{
    if(!_numsBtn){
        _numsBtn = [YBButton buttonWithType:UIButtonTypeCustom];
        _numsBtn.layer.cornerRadius = 17;
        _numsBtn.backgroundColor = RGB_COLOR(@"#000000", 0.4);
        _numsBtn.titleLabel.font = SYS_Font(13);
        [_numsBtn setTitle:@"0" forState:0];
        [_numsBtn setTitleColor:[UIColor whiteColor] forState:0];
        _numsBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [_numsBtn addTarget:self action:@selector(clickOnlineBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _numsBtn;
}

-(void)clickOnlineBtn {
    [self destroySubs];
    _onlineView = [self createOnline];
    _onlineView.liveDic = @{
        @"liveuid":_liveUid,
        @"stream":_liveStream
    };
    
}
#pragma mark - 在线观众
- (OnlineUserView *)createOnline{
    if(!_onlineView){
        _onlineView = [[OnlineUserView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        WeakSelf;
        _onlineView.onlineEvent = ^(LiveEnum event, NSDictionary *eventDic) {
            if(event == Live_Online_Close){
                [weakSelf destroyOnlineView];
            }
        };
        [[YBAppDelegate sharedAppDelegate].topViewController.view addSubview:_onlineView];
    }
    return _onlineView;
}

-(void)destroyOnlineView {
    if(_onlineView){
        [_onlineView removeFromSuperview];
        _onlineView = nil;
    }
}



@end

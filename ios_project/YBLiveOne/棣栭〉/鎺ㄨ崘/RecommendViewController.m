//
//  RecommendViewController.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "RecommendViewController.h"
#import "recommendCell.h"
#import "YBScreenView.h"
#import "PersonMessageViewController.h"
#import "rechargeScreenView.h"
#import "MatchViewController.h"
#import "roomPayView.h"
#import "personSelectActionView.h"
//#import "TIMComm.h"
//#import "TIMManager.h"
//#import "TIMMessage.h"
//#import "TIMConversation.h"
#import "InvitationViewController.h"
@interface RecommendViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    CGFloat oldOffset;
    int page;
    YBScreenView *screenView;
    rechargeScreenView *rechargeV;

    NSString *titleStr;
    NSString *type;
    NSDictionary *infoDic;
    roomPayView *payView;
    personSelectActionView *actionView;

}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *infoArray;//获取到的主播列表信息
@property (nonatomic,strong) NSString *screenSex;
@property (nonatomic,strong) NSString *screenType;
@property (nonatomic,strong) UIView *collectionHeaderView;
@property (nonatomic,strong)recommendModel *currentModel;
@end

@implementation RecommendViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    if(!showLite){
        [self requestData];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviView.hidden = YES;
    oldOffset = 0;
    page = 1;
    _screenSex = @"0";
    _screenType = @"0";
    self.infoArray    =  [NSMutableArray array];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self createCollectionView];
    [self pullInternet];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChargeSucess:) name:@"userChargeSucess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConfigData) name:@"HOMECONFIGDATA" object:nil];

    
    
}
-(void)getConfigData{
    if (_collectionView) {
        [self pullInternet];
    }
}
-(void)createCollectionView{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake((_window_width-30)/2-7.5, _window_width/1.8-7.5);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(5, 15,5, 15);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height-64-statusbarHeight-60-_window_width / 6) collectionViewLayout:flow];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"recommendCell" bundle:nil] forCellWithReuseIdentifier:@"recommendCELL"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"recommendHeader"];

    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self pullInternet];
    }];
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        page ++;
        [self pullInternet];
    }];
    
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self pullInternet];
    
}
//获取网络数据
-(void)pullInternet{
    NSDictionary *dic = @{@"sex":_screenSex,
                          @"type":_screenType,
                          @"p":@(page)
                          };
    [YBToolClass postNetworkWithUrl:@"Home.GetHot" andParameter:dic success:^(int code,id info,NSString *msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        if (code == 0) {
            NSArray *infoA = [info objectAtIndex:0];
            NSArray *list = [infoA valueForKey:@"list"];

            if (page == 1) {
                [_infoArray removeAllObjects];
            }
            for (NSDictionary *dic in list) {
                recommendModel *model = [[recommendModel alloc]initWithDic:dic];
                [_infoArray addObject:model];
            }
            [_collectionView reloadData];
            
            if (list.count == 0) {
                [_collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
    } fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        if (_infoArray.count == 0) {
        }
        
    }];
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _infoArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    // 基本模式禁止滚动
    if(showLite){
        return;
    }
    
    
    recommendModel *model = _infoArray[indexPath.row];
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
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WeakSelf;
    recommendCell *cell = (recommendCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"recommendCELL" forIndexPath:indexPath];
    cell.model = _infoArray[indexPath.row];
    cell.callEvent = ^(recommendModel *model) {
        _currentModel = model;
        [weakSelf showCallView:model];
    };
    cell.changeHelloEvent = ^(recommendModel *model) {
        NSMutableArray *dataArr = [NSMutableArray array];
        for(int i = 0; i <_infoArray.count; i ++){
            recommendModel *modelss = _infoArray[i];
            if([modelss.userID isEqual:model.userID]){
                modelss.can_sayhi= @"0";
            }
            [dataArr addObject:modelss];
        }
        _infoArray = dataArr;
    };
    return cell;
}
#pragma mark ================ collectionview头视图 ===============
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && ![YBToolClass isUp]) {

        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"recommendHeader" forIndexPath:indexPath];

        header.backgroundColor = [UIColor whiteColor];
        [header addSubview:self.collectionHeaderView];
        return header;
    }else{
        return nil;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if ([YBToolClass isUp]) {
        return CGSizeMake(_window_width, 0);;
    }
    return  CGSizeMake(_window_width, self.collectionHeaderView.height);
}
-(UIView *)collectionHeaderView{
    if (!_collectionHeaderView) {
        CGFloat wwww = (_window_width-30)/2;

        _collectionHeaderView = [[UIView alloc]init];
        _collectionHeaderView.frame = CGRectMake(0, 0, _window_width, wwww*0.5+10);
        
        NSArray *function_arr = @[@"home_yuyin",@"home_shipin"];
        for (int i = 0; i <function_arr.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:0];
            btn.frame = CGRectMake((i+1)*10 +i*wwww, 5, wwww, wwww*0.5);
            [btn setImage:[UIImage imageNamed:getImagename(function_arr[i])] forState:0];
            [btn addTarget:self action:@selector(functionBtnClilck:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 10000+i;
            [_collectionHeaderView addSubview:btn];
        }

    }
    return _collectionHeaderView;
}
#pragma mark ============筛选弹窗=============
- (void)showYBScreendView{
    if (!screenView) {
        screenView = [[YBScreenView alloc]init];
        [[UIApplication sharedApplication].keyWindow addSubview:screenView];
    }
    WeakSelf;
    screenView.block = ^(NSDictionary * _Nonnull dic) {
        weakSelf.screenSex = [dic valueForKey:@"sex"];
        weakSelf.screenType = [dic valueForKey:@"type"];
        page = 1;
        [weakSelf pullInternet];
    };
    [screenView show];
}

#pragma mark ============充值飘屏=============
- (void)userChargeSucess:(NSNotification *)not{
    NSDictionary *dic = [not object];
    [self showRechargeView:dic];
}
- (void)showRechargeView:(NSDictionary *)dic{
    if (!rechargeV) {
        rechargeV = [[rechargeScreenView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight+20, _window_width, 40)];
        [self.view addSubview:rechargeV];
    }
    [rechargeV addMove:dic];
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

-(void)functionBtnClilck:(UIButton *)sender{
    
    if ([[YBYoungManager shareInstance]isOpenYoung]) {
        [MBProgressHUD showError:YZMsg(@"青少年模式下该功能不能使用")];
        return;
    }
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    // 基本模式禁止滚动
    if(showLite){
        return;
    }
    
    NSInteger senderType = sender.tag;
    switch (senderType) {
        case 10000:
            [self checkMatchType:senderType];
            break;
        case 10001:
            [self checkMatchType:senderType];
            break;
        default:
            break;
    }
}

-(void)checkMatchType:(NSInteger)matchType{
    if (matchType == 10000) {
        type = @"2";
        // titleStr = [NSString stringWithFormat:@"%@%@%@\n%@%@%@",YZMsg(@"该匹配为付费功能,1分钟需支付"),minstr([infoDic valueForKey:@"voice"]),[common name_coin],YZMsg(@"开通VIP后1分钟仅需"),minstr([infoDic valueForKey:@"voice_vip"]),[common name_coin]];
        titleStr = [NSString stringWithFormat:YZMsg(@"该匹配为付费功能,1分钟需支付%@%@ 开通VIP后1分钟仅需%@%@"),minstr([infoDic valueForKey:@"voice"]),[common name_coin],minstr([infoDic valueForKey:@"voice_vip"]),[common name_coin]];

    }else if(matchType == 10001){
        type = @"1";
        // titleStr = [NSString stringWithFormat:@"%@%@%@\n%@%@%@",YZMsg(@"该匹配为付费功能,1分钟需支付"),minstr([infoDic valueForKey:@"video"]),[common name_coin],YZMsg(@"开通VIP后1分钟仅需"),minstr([infoDic valueForKey:@"video_vip"]),[common name_coin]];
        titleStr = [NSString stringWithFormat:YZMsg(@"该匹配为付费功能,1分钟需支付%@%@ 开通VIP后1分钟仅需%@%@"),minstr([infoDic valueForKey:@"video"]),[common name_coin],minstr([infoDic valueForKey:@"video_vip"]),[common name_coin]];

    }
    WeakSelf;
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:titleStr preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"进行匹配") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf startBtnClick];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    
    }];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [cancelAction setValue:[UIColor grayColor] forKey:@"_titleTextColor"];
    [alertControl addAction:sureAction];
    [alertControl addAction:cancelAction];
    
    [[[YBAppDelegate sharedAppDelegate]topViewController]presentViewController:alertControl animated:YES completion:nil];

}
#pragma mark ============开始匹配=============
- (void)startBtnClick{
    if ([type isEqual:@"2"]) {
        //语音
        if ([YBToolClass checkAudioAuthorization] == 2) {
            //弹出麦克风权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self callllllllllType];
                    }else{
                        [MBProgressHUD showError:YZMsg(@"未允许麦克风权限，不能语音通话")];
                    }
                });
            }];
        }else{
            if ([YBToolClass checkAudioAuthorization] == 1) {
                [self callllllllllType];
            }else{
                [MBProgressHUD showError:YZMsg(@"请前往设置中打开麦克风权限")];
                return;
            }
            
        }
    }else{
        if ([YBToolClass checkVideoAuthorization] == 2) {
            //弹出相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self checkYuyinQuanxian];
                    }else{
                        [MBProgressHUD showError:YZMsg(@"未允许摄像头权限，不能视频通话")];
                    }
                });
                
            }];
        }else{
            if ([YBToolClass checkVideoAuthorization] == 1) {
                [self checkYuyinQuanxian];
            }else{
                [MBProgressHUD showError:YZMsg(@"请前往设置中打开摄像头权限")];
            }
        }
    }
    
    //视频
    
    
}
- (void)checkYuyinQuanxian{
    if ([YBToolClass checkAudioAuthorization] == 2) {
        //弹出麦克风权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self callllllllllType];
                }else{
                    [MBProgressHUD showError:YZMsg(@"未允许麦克风权限，不能语音通话")];
                }
            });
        }];
    }else{
        if ([YBToolClass checkAudioAuthorization] == 1) {
            [self callllllllllType];
        }else{
            [MBProgressHUD showError:YZMsg(@"请前往设置中打开麦克风权限")];
            return;
        }
    }
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Matchs.GetMatch" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            infoDic = [info firstObject];
        }
    } fail:^{
        
    }];
}

- (void)callllllllllType{

    if (!infoDic) {
        return;
    }
    if (![minstr([infoDic valueForKey:@"isauth"]) isEqual:@"1"]) {
        [MBProgressHUD showMessage:@""];
        [YBToolClass postNetworkWithUrl:@"Matchs.check" andParameter:@{@"type":type} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [MBProgressHUD hideHUD];
            if (code == 0) {
                [self goMatchVC];
            }else if (code == 1008){
                [self doRechargeView];
            }else{
                [MBProgressHUD showError:msg];
            }
        } fail:^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:YZMsg(@"网络请求失败")];
        }];

    }else{
        [self goMatchVC];
    }
}
- (void)goMatchVC{
    MatchViewController *match = [[MatchViewController alloc]init];
    match.type = type;
    match.isauth = minstr([infoDic valueForKey:@"isauth"]);
    NSAttributedString *attstr ;
    if ([type isEqual:@"1"]) {
        attstr =  [self setattstrWithString:[NSString stringWithFormat:@"%@%@/%@（%@：%@%@/%@）",minstr([infoDic valueForKey:@"video"]),[common name_coin],YZMsg(@"分钟"),YZMsg(@"VIP用户"),minstr([infoDic valueForKey:@"video_vip"]),[common name_coin],YZMsg(@"分钟")]];

    }else{
        attstr =  [self setattstrWithString:[NSString stringWithFormat:@"%@%@/%@（%@：%@%@/%@）",minstr([infoDic valueForKey:@"voice"]),[common name_coin],YZMsg(@"分钟"),YZMsg(@"VIP用户"),minstr([infoDic valueForKey:@"voice_vip"]),[common name_coin],YZMsg(@"分钟")]];
    }
    

    match.attStr =attstr;
    [[YBAppDelegate sharedAppDelegate] pushViewController:match animated:YES];
}
- (void)doRechargeView{
    if (!payView) {
        [YBToolClass postNetworkWithUrl:@"Charge.GetBalance" andParameter:@{@"type":@"2"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSDictionary *infoDic = [info firstObject];
                if (!payView) {
                    payView = [[roomPayView alloc]initWithMsg:infoDic andFrome:2];
                    [self.view addSubview:payView];
                }
                [payView show];
                [[UIApplication sharedApplication].delegate.window addSubview:payView];
            }
        } fail:^{
            
        }];
    }else{
        [payView show];
        [[UIApplication sharedApplication].delegate.window bringSubviewToFront:payView];
        
    }

}
- (NSAttributedString *)setattstrWithString:(NSString *)str{
    NSRange range = NSMakeRange([str rangeOfString:@"（"].location+1, [str rangeOfString:@"）"].location-[str rangeOfString:@"（"].location);
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:str];
    [attstr addAttribute:NSForegroundColorAttributeName value:normalColors range:range];
    return attstr;
}

-(void)showCallView:(recommendModel *)model{
    if ([[YBYoungManager shareInstance]isOpenYoung]) {
        [MBProgressHUD showError:YZMsg(@"青少年模式下该功能不能使用")];
        return;
    }
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    // 基本模式禁止滚动
    if(showLite){
        return;
    }
    
    if (actionView) {
        [actionView removeFromSuperview];
        actionView = nil;
    }
    NSArray *imgArray ;
    NSArray *itemArray;
    NSString *callTypeStr;
    if (model.isvoice && model.isvideo) {
        imgArray = @[@"person_选择语音",@"person_选择视频"];
        itemArray = @[[NSString stringWithFormat:@"%@（%@%@/%@）",YZMsg(@"语音通话"),model.voice_value,[common name_coin],YZMsg(@"分钟")],[NSString stringWithFormat:@"%@（%@%@/%@）",YZMsg(@"视频通话"),model.video_value,[common name_coin],YZMsg(@"分钟")]];
        if ([YBToolClass isUp]) {
            itemArray = @[YZMsg(@"语音通话"),YZMsg(@"视频通话")];
        }
        callTypeStr = @"0";
    }else if (model.isvoice && !model.isvideo){
        imgArray = @[@"person_选择语音"];
        itemArray = @[[NSString stringWithFormat:@"%@（%@%@/%@）",YZMsg(@"语音通话"),model.voice_value,[common name_coin],YZMsg(@"分钟")]];
        if ([YBToolClass isUp]) {
            itemArray = @[YZMsg(@"语音通话")];
        }
        callTypeStr = @"2";
        [self sendCallwithType:@"2"];
        return;

    }else if (!model.isvoice && model.isvideo){
        imgArray = @[@"person_选择视频"];
        itemArray = @[[NSString stringWithFormat:@"%@（%@%@/%@）",YZMsg(@"视频通话"),model.video_value,[common name_coin],YZMsg(@"分钟")]];
        if ([YBToolClass isUp]) {
            itemArray = @[YZMsg(@"视频通话")];
        }
        callTypeStr = @"1";
        [self sendCallwithType:@"1"];
        return;
    }
    WeakSelf;
    actionView = [[personSelectActionView alloc]initWithImageArray:imgArray andItemArray:itemArray];
    actionView.block = ^(int item) {
        if ([callTypeStr isEqual:@"0"]) {
            if (item == 0) {
                [weakSelf sendCallwithType:@"2"];
            }
            if (item == 1) {
                [weakSelf sendCallwithType:@"1"];
            }
        }
    };
    [[UIApplication sharedApplication].keyWindow addSubview:actionView];
    [actionView show];

}
#pragma mark ============发起通话=============
- (void)sendCallwithType:(NSString *)type{
    if ([type isEqual:@"2"]) {
        //语音
        if ([YBToolClass checkAudioAuthorization] == 2) {
            //弹出麦克风权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self callHomeBtnType:type];
                    }else{
                        [MBProgressHUD showError:YZMsg(@"未允许麦克风权限，不能语音通话")];
                    }
                });
            }];
        }else{
            if ([YBToolClass checkAudioAuthorization] == 1) {
                [self callHomeBtnType:type];
            }else{
                [MBProgressHUD showError:YZMsg(@"请前往设置中打开麦克风权限")];
                return;
            }

        }
    }else{
        if ([YBToolClass checkVideoAuthorization] == 2) {
            //弹出相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self checkYuyinQuanxian:type];
                    }else{
                        [MBProgressHUD showError:YZMsg(@"未允许摄像头权限，不能视频通话")];
                    }
                });

            }];
        }else{
            if ([YBToolClass checkVideoAuthorization] == 1) {
                [self checkYuyinQuanxian:type];
            }else{
                [MBProgressHUD showError:YZMsg(@"请前往设置中打开摄像头权限")];
            }
        }
    }

    //视频
    

}
- (void)checkYuyinQuanxian:(NSString *)type{
    if ([YBToolClass checkAudioAuthorization] == 2) {
        //弹出麦克风权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self callHomeBtnType:type];
                }else{
                    [MBProgressHUD showError:YZMsg(@"未允许麦克风权限，不能语音通话")];
                }
            });
        }];
    }else{
        if ([YBToolClass checkAudioAuthorization] == 1) {
            [self callHomeBtnType:type];
        }else{
            [MBProgressHUD showError:YZMsg(@"请前往设置中打开麦克风权限")];
            return;
        }
    }
}
- (void)callHomeBtnType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",_currentModel.userID,[Config getOwnToken],type,[Config getOwnID]]];
    NSDictionary *dic = @{
                          @"liveuid":_currentModel.userID,
                          @"type":type,
                          @"sign":sign
                          };
    [YBToolClass postNetworkWithUrl:@"Live.Checklive" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
//            TIMConversation *conversation = [[TIMManager sharedInstance]
//                                             getConversation:TIM_C2C
//                                             receiver:_currentModel.userID];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"0",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":type,
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID],
                                  @"content":@"邀请你通话"
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            V2TIMCustomElem * custom_elem = [[V2TIMCustomElem alloc] init];
            [custom_elem setData:data];
            WeakSelf;
            [[YBImManager shareInstance]sendV2CustomMsg:custom_elem andReceiver:_currentModel.userID complete:^(BOOL isSuccess, V2TIMMessage *sendMsg, NSString *desc) {
                if(isSuccess){
                    NSLog(@"SendMsg Succ");
                    [weakSelf showWaitView:infoDic andType:type];
                }else{
                    [MBProgressHUD showError:YZMsg(@"消息发送失败")];
                    [weakSelf sendMessageFaild:infoDic andType:type];
                }
            }];

//            TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
//            [custom_elem setData:data];
//            TIMMessage * msg = [[TIMMessage alloc] init];
//            [msg addElem:custom_elem];
//            WeakSelf;
//            [conversation sendMessage:msg succ:^(){
//                NSLog(@"SendMsg Succ");
//                [weakSelf showWaitView:infoDic andType:type];
//            }fail:^(int code, NSString * err) {
//                NSLog(@"SendMsg Failed:%d->%@", code, err);
//                [MBProgressHUD showError:YZMsg(@"消息发送失败")];
//                [weakSelf sendMessageFaild:infoDic andType:type];
//            }];
            
            
        }else if(code == 800){
            [self showYuyue:type andMessage:msg];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];

}
- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:_currentModel.userID forKey:@"id"];
    [muDic setObject:_currentModel.avatar forKey:@"avatar"];
    [muDic setObject:_currentModel.user_nickname forKey:@"user_nickname"];
    [muDic setObject:_currentModel.level_anchor  forKey:@"level_anchor"];
    [muDic setObject:_currentModel.video_value forKey:@"video_value"];
    [muDic setObject:_currentModel.voice_value forKey:@"voice_value"];

    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue] andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:navi animated:YES completion:nil];

}
- (void)sendMessageFaild:(NSDictionary *)infoDic andType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",_currentModel.userID,minstr([infoDic valueForKey:@"showid"]),[Config getOwnToken],[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.UserHang" andParameter:@{@"liveuid":_currentModel.userID,@"showid":minstr([infoDic valueForKey:@"showid"]),@"sign":sign,@"hangtype":@"0"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    } fail:^{
    }];

}
- (void)showYuyue:(NSString *)type andMessage:(NSString *)msg{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"预约") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self SetSubscribe:type];
    }];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];

}
- (void)SetSubscribe:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",_currentModel.userID,[Config getOwnToken],type,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Subscribe.SetSubscribe" andParameter:@{@"liveuid":_currentModel.userID,@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    } fail:^{
    }];
    
}

@end

//
//  YBShareManager.m
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/5.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "YBShareManager.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>

@interface YBShareManager()<UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)NSArray *sharePlatA;
@property(nonatomic,assign)BOOL hasUi;
@property(nonatomic,assign)ShareEnum senum;
@property(nonatomic,copy)ShareFinish shareEvent;

@end

@implementation YBShareManager

static YBShareManager *_singleton = nil;

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[super allocWithZone:NULL] init];
    });
    return _singleton;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}
#pragma mark - 分享：有UI
-(void)shareUiWithEnum:(ShareEnum)senum finish:(ShareFinish)finish; {
    if(_singleton){
        [_singleton dissmissView];
    }
    _singleton.frame = CGRectMake(0, 0, _window_width, _window_height);
    [[YBAppDelegate sharedAppDelegate].topViewController.view addSubview:_singleton];
    [_singleton createUI];
    _singleton.senum = senum;
    _singleton.shareEvent = finish;
    _singleton.hasUi = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch; {
    if ([touch.view isDescendantOfView:self.bgView]) {
        return NO;
    }
    return YES;
}
-(void)dissmissView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
}
-(void)createUI {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dissmissView)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    self.backgroundColor = RGB_COLOR(@"#000000", 0.4);
    _bgView = [[UIView alloc]init];
    _bgView.backgroundColor = UIColor.whiteColor;
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.width.centerX.equalTo(self);
    }];
    UILabel *titleL = [[UILabel alloc]init];
    titleL.font = SYS_Font(15);
    titleL.textColor = RGB_COLOR(@"#969696", 1);
    titleL.text = YZMsg(@"分享至");
    [_bgView addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bgView);
        make.left.equalTo(_bgView.mas_left).offset(15);
        make.height.mas_equalTo(40);
    }];
    
    UIView *contentView = [[UIView alloc]init];
    [_bgView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleL.mas_bottom).offset(0);
        make.width.centerX.equalTo(_bgView);
        make.bottom.equalTo(_bgView.mas_bottom).offset(-ShowDiff-10);
    }];
    
    ///
    NSArray *shareA = [NSArray arrayWithArray:[common share_type]];
    NSMutableArray *m_arr = [NSMutableArray array];
    for (NSString *share_title in shareA) {
        NSString *show_title;
        if ([share_title isEqual:@"wx"]) {
            show_title = YZMsg(@"微信");
        }else if ([share_title isEqual:@"wchat"]){
            show_title = YZMsg(@"朋友圈");
        }else if ([share_title isEqual:@"qzone"]){
            show_title = YZMsg(@"QQ空间");
        }else if ([share_title isEqual:@"qq"]){
            show_title = @"QQ";
        }else if ([share_title isEqual:@"facebook"]){
            show_title = @"Facebook";
        }else if ([share_title isEqual:@"twitter"]){
            show_title = YZMsg(@"推特");
        }
        
        NSDictionary *platDic = @{
            @"plat":share_title,
            @"title":show_title,
        };
        [m_arr addObject:platDic];
    }
    
    /// 复制
    NSDictionary *copyDic = @{
        @"plat":@"copy",
        @"title":YZMsg(@"复制链接"),
    };
    [m_arr addObject:copyDic];
    _sharePlatA = [NSArray arrayWithArray:m_arr];
    
    MASViewAttribute *mas_top = contentView.mas_top;
    MASViewAttribute *mas_left = contentView.mas_left;
    int perRow = 4;
    for (int i = 0; i<_sharePlatA.count; i++) {
        NSDictionary *subDic = _sharePlatA[i];
        
        UIView *subView = [[UIView alloc]init];
        [contentView addSubview:subView];
        [subView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(_window_width/perRow);
            make.left.equalTo(mas_left);
            make.top.equalTo(mas_top);
            if((i+1) == _sharePlatA.count){
                make.bottom.equalTo(contentView);
            }
        }];
        
        if((i+1)%perRow == 0){
            mas_left = contentView.mas_left;
            mas_top = subView.mas_bottom;
        }else {
            mas_left = subView.mas_right;
        }
        
        UIImageView *platIV = [[UIImageView alloc]init];
        platIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"分享-%@",[subDic valueForKey:@"plat"]]];
        [subView addSubview:platIV];
        [platIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(subView.mas_top).offset(10);
            make.width.height.mas_equalTo(40);
            make.centerX.equalTo(subView);
        }];
        UILabel *nameL = [[UILabel alloc]init];
        nameL.font = SYS_Font(13);
        nameL.textColor = RGB_COLOR(@"#969696", 1);
        nameL.text = minstr([subDic valueForKey:@"title"]);
        [subView addSubview:nameL];
        [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.lessThanOrEqualTo(subView);
            make.centerX.equalTo(subView);
            make.top.equalTo(platIV.mas_bottom).offset(5);
            make.bottom.equalTo(subView.mas_bottom).offset(-10);
        }];
        
        YBButton *shadowBtn = [YBButton buttonWithType:UIButtonTypeCustom];
        shadowBtn.tag = 10000+i;
        [shadowBtn addTarget:self action:@selector(clickShadowBtn:) forControlEvents:UIControlEventTouchUpInside];
        [subView addSubview:shadowBtn];
        [shadowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.height.centerY.equalTo(subView);
        }];
    }
}
-(void)clickShadowBtn:(YBButton *)btn {
    int idx = (int)btn.tag - 10000;
    NSDictionary *subDic = _sharePlatA[idx];
    NSLog(@"rk===>%@",subDic);
    NSString *platfrom = minstr([subDic valueForKey:@"plat"]);

    [self goShare:platfrom];
}


#pragma mark - 分享：无UI
-(void)sharePlat:(NSString *)plat andEnum:(ShareEnum)senum finish:(ShareFinish)finish; {
    self.senum = senum;
    self.shareEvent = finish;
    self.hasUi = NO;
    [self goShare:plat];
}

-(void)goShare:(NSString *)eventStr {
    if ([eventStr isEqual:@"wx"] || [eventStr isEqual:@"微信"]) {
        [self simplyShare:SSDKPlatformSubTypeWechatSession];
    }else if ([eventStr isEqual:@"wchat"] || [eventStr isEqual:@"朋友圈"]){
        [self simplyShare:SSDKPlatformSubTypeWechatTimeline];
    }else if ([eventStr isEqual:@"qzone"] || [eventStr isEqual:@"QQ空间"]){
        [self simplyShare:SSDKPlatformSubTypeQZone];
    }else if ([eventStr isEqual:@"qq"] || [eventStr isEqual:@"QQ"]){
        [self simplyShare:SSDKPlatformSubTypeQQFriend];
    }else if ([eventStr isEqual:@"facebook"] || [eventStr isEqual:@"Facebook"]){
        [self simplyShare:SSDKPlatformTypeFacebook];
    }else if ([eventStr isEqual:@"twitter"] || [eventStr isEqual:@"推特"]){
        [self simplyShare:SSDKPlatformTypeTwitter];
    }else if([eventStr isEqual:@"copy"]){
        /// 复制功能
        NSString *copyStr = [common app_ios];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = copyStr;
        [MBProgressHUD showError:YZMsg(@"复制成功")];
        if(self.shareEvent){
            self.shareEvent(Finish_Default, @{});
            [self dissmissView];
        }
    }
}
- (void)simplyShare:(int)SSDKPlatformType {
    
    //默认直播分享
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    int SSDKContentType = SSDKContentTypeAuto;
    
    NSString *shareTitle = [common getShareLiveTitle];
    NSString *shareDes = [common getShareLiveDes];
    NSString *shareImage = @"";
    NSString *shareUrlStr = [common app_ios];
    
    /// 如果有其他分享方式在这里改变标题、话术、图片、地址
    if(_senum == Share_Live_Preview || Share_Live_Room){
        
        if (shareTitle.length > 0 && [shareTitle containsString:@"username"]) {
            shareTitle = [shareTitle stringByReplacingOccurrencesOfString:@"{username}" withString:minstr([_shareParam valueForKey:@"share_uname"])];
        }
        NSString *inputStr = minstr([_shareParam valueForKey:@"share_input"]);
        if(![YBToolClass checkNull:inputStr]){
            shareDes = inputStr;
        }
        shareImage = minstr([_shareParam valueForKey:@"share_thumb"]);
    }
    
    if([YBToolClass checkNull:shareTitle] ||
       [YBToolClass checkNull:shareImage] ||
       [YBToolClass checkNull:shareUrlStr] ||
       [YBToolClass checkNull:shareTitle]){
        [MBProgressHUD showError:YZMsg(@"分享参数错误")];
        return;
    }
    // 开始分享
    shareUrlStr = [shareUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [shareParams SSDKSetupShareParamsByText:shareDes
                                     images:shareImage
                                        url:[NSURL URLWithString:shareUrlStr]
                                      title:shareTitle
                                       type:SSDKContentType];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [shareParams SSDKEnableUseClientShare];
#pragma clang diagnostic pop
    
    WeakSelf;
    //进行分享
    [ShareSDK share:SSDKPlatformType
         parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess: {
                [MBProgressHUD showSuccess:YZMsg(@"分享成功")];
            }break;
            case SSDKResponseStateFail: {
                [MBProgressHUD showError:YZMsg(@"分享失败")];
            }break;
            case SSDKResponseStateCancel: {
                [MBProgressHUD showError:YZMsg(@"分享取消")];
            } break;
            default:
                break;
        }
        
        // 回调
        if(weakSelf.shareEvent){
            weakSelf.shareEvent(Finish_Default, @{});
            [weakSelf dissmissView];
        }
    }];
}

@end

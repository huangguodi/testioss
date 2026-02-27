//
//  SetMeiYanVC.m
//  YBLiveOne
//
//  Created by 阿庶 on 2019/10/22.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SetMeiYanVC.h"
#import <TXLiteAVSDK_Professional/TXLivePush.h>
#import <TXLiteAVSDK_Professional/TXLiveBase.h>
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import <TXLiteAVSDK_Professional/TXLivePlayListener.h>
#import <TXLiteAVSDK_Professional/TXLivePlayConfig.h>
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>
#import <YYWebImage/YYWebImage.h>

#import "V8HorizontalPickerView.h"

/********************  TiFaceSDK添加 结束 ********************/
//#import "TIMComm.h"
//#import "TIMManager.h"
//#import "TIMMessage.h"
//#import "TIMConversation.h"
#import <MHBeautySDK/MHBeautySDK.h>
#import "MHMeiyanMenusView.h"
#import "MHBeautyParams.h"
#import "sproutCommon.h"
#import "YBLiveRTCManager.h"

typedef NS_ENUM(NSInteger,TCLVFilterType) {
    FilterType_None         = 0,
    FilterType_white        ,   //美白滤镜
    FilterType_langman         ,   //浪漫滤镜
    FilterType_qingxin         ,   //清新滤镜
    FilterType_weimei         ,   //唯美滤镜
    FilterType_fennen         ,   //粉嫩滤镜
    FilterType_huaijiu         ,   //怀旧滤镜
    FilterType_landiao         ,   //蓝调滤镜
    FilterType_qingliang     ,   //清凉滤镜
    FilterType_rixi         ,   //日系滤镜
};
@interface SetMeiYanVC ()<TXVideoCustomProcessDelegate,V8HorizontalPickerViewDataSource,V8HorizontalPickerViewDelegate,TXVideoCustomProcessDelegate,TXLivePlayListener,TXLivePushListener,YBLiveRTCDelegate,MHMeiyanMenusViewDelegate>{
    CWStatusBarNotification *_notification;
    BOOL isTXfiter;
    
    UILabel *timeL;
    NSTimer *linkTimer;
    int linkCount;
    NSTimer *backGroundTimer;//检测后台时间（超过60秒执行断流操作）
    int backTime;//
    BOOL isLoadWebSprout;

    NSInteger yijianindex;
    NSInteger lvjingindex;
    NSInteger texiaoindex;
    NSInteger hahajingindex;
    NSString *tiezhistr;
    /***********************  腾讯SDK start **********************/
    float  _tx_beauty_level;//磨皮
    float  _tx_whitening_level;//美白
    float  _redfacDepth;//红润

    float  _tx_eye_level;//大眼
    float  _tx_face_level;//搜脸
    float _light_level;//亮度
    float _mouse_level;//嘴型
    float _nose_level;//鼻子
    float _xiaba_level;//下巴
     float _head_level;//额头
     float _meimao_level;//眉毛
     float _yanjiao_level;//眼角
     float _kaiyanjiao_level;//开眼角
     float _yanju_level;//眼距
     float _xiaolian_level;//削脸
     float _longnose_level;//长鼻
    int a;
    
    UIButton              *_beautyBtn;
    UIButton              *_filterBtn;
    UILabel               *_beautyLabel;
    UILabel               *_beautyValueLb;
    UILabel               *_whiteLabel;
    UILabel               *_whiteValueLb;

    UILabel               *_redLabel;//红润
    UILabel               *_redValueLb;//红润

    UILabel               *_bigEyeLabel;
    UILabel               *_slimFaceLabel;
    UISlider              *_sdBeauty;
    UISlider              *_sdWhitening;
     UISlider*                       _sdredFace;
    UISlider              *_sdBigEye;
    UISlider              *_sdSlimFace;
    V8HorizontalPickerView  *_filterPickerView;
    NSInteger    _filterType;
    
    /***********************  腾讯SDK end **********************/
    TXLivePlayer *       _txLivePlayer;
    TXLivePlayConfig*    _config;
    UIView *playBackView;
    
    
    
    
    UIView *playerMask;
    
    UIView *previewMask;
    
    NSDictionary *_xxMYDic;
    NSDictionary *_normalMYDic;
    NSString *MYType;
}
@property TXLivePushConfig* txLivePushonfig;
@property TXLivePush*       txLivePublisher;
@property (nonatomic,strong) UIView *previewView;


@property(nonatomic,strong)NSMutableArray *filterArray;//美颜数组
@property (nonatomic,strong)UIView     *vBeauty;

//美狐
@property (nonatomic,strong) MHMeiyanMenusView *menuView;
@property (nonatomic,strong) MHBeautyManager *beautyManager;
@property (nonatomic,strong) UIButton *zhezhaoBtn;
@property (nonatomic,strong) UIButton *meihuBtn;
@property (nonatomic,strong) UIButton *sureBtn;
@property (nonatomic,strong) UIButton *resetBtn;

@end

@implementation SetMeiYanVC

- (void)viewWillAppear:(BOOL)animated{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}
- (MHBeautyManager *)beautyManager {
    if (!_beautyManager) {
        _beautyManager = [[MHBeautyManager alloc] init];
    }
    return _beautyManager;
}
#pragma mark - MH
- (MHMeiyanMenusView *)menuView {
    if (!_menuView) {
        _menuView = [[MHMeiyanMenusView alloc] initWithFrame:CGRectMake(0, window_height - MHMeiyanMenuHeight - BottomIndicatorHeight, window_width, MHMeiyanMenuHeight) superView:self.view  beautyManager:self.beautyManager];
    }
    return _menuView;
}
-(void)requestSetBeauty{
    [YBToolClass postNetworkWithUrl:@"user.getBeauty" andParameter:@{@"uid":[Config getOwnID],@"token":[Config getOwnToken]} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        NSLog(@"info---------:%@", info);
        NSDictionary *infos = [info firstObject];
        _normalMYDic = [infos valueForKey:@"moren"];
        _xxMYDic = [infos valueForKey:@"meihu"];
        if ([YBToolClass checkNull:[common getTISDKKey]]){
            
            if ([minstr([_normalMYDic valueForKey:@"ishave"]) isEqual:@"1"]) {
                _tx_whitening_level = [[_normalMYDic valueForKey:@"preinstall"][@"skin_whiting"] floatValue];
                _redfacDepth = [[_normalMYDic valueForKey:@"preinstall"][@"skin_tenderness"] floatValue];
                _tx_beauty_level = [[_normalMYDic valueForKey:@"preinstall"][@"skin_smooth"] floatValue];

            }
        }else{
            if ([minstr([_xxMYDic valueForKey:@"ishave"]) isEqual:@"1"]) {
                [sproutCommon saveSproutMessage:[_xxMYDic valueForKey:@"preinstall"]];

                 _tx_whitening_level = [[_xxMYDic valueForKey:@"preinstall"][@"skin_whiting"] floatValue];
                 _redfacDepth = [[_xxMYDic valueForKey:@"preinstall"][@"skin_tenderness"] floatValue];
                 _tx_beauty_level = [[_xxMYDic valueForKey:@"preinstall"][@"skin_smooth"] floatValue];
                 _light_level = [[_xxMYDic valueForKey:@"preinstall"][@"brightness"] floatValue];
                 _tx_eye_level = [[_xxMYDic valueForKey:@"preinstall"][@"big_eye"] floatValue];
                 _tx_face_level = [[_xxMYDic valueForKey:@"preinstall"][@"face_lift"] floatValue];
                _mouse_level = [[_xxMYDic valueForKey:@"preinstall"][@"mouse_lift"] floatValue];
                 _nose_level = [[_xxMYDic valueForKey:@"preinstall"][@"nose_lift"] floatValue];
                 _xiaba_level = [[_xxMYDic valueForKey:@"preinstall"][@"chin_lift"] floatValue];
                 _head_level = [[_xxMYDic valueForKey:@"preinstall"][@"forehead_lift"] floatValue];
                 _meimao_level = [[_xxMYDic valueForKey:@"preinstall"][@"eye_brow"] floatValue];
                 _yanjiao_level = [[_xxMYDic valueForKey:@"preinstall"][@"eye_corner"] floatValue];
                 _yanju_level = [[_xxMYDic valueForKey:@"preinstall"][@"eye_length"] floatValue];
                 _kaiyanjiao_level = [[_xxMYDic valueForKey:@"preinstall"][@"eye_alat"] floatValue];
                 _xiaolian_level = [[_xxMYDic valueForKey:@"preinstall"][@"face_shave"] floatValue];
                 _longnose_level = [[_xxMYDic valueForKey:@"preinstall"][@"lengthen_noselift"] floatValue];

            }

        }

        [self RTMPush];

    } fail:^{
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    a = 0;
    _light_level = 50;
    isLoadWebSprout = NO;
    MYType = @"1";
    [self requestSetBeauty];
//    [self setmeiyan];
}
- (void)creatUI{
    
    playBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    playBackView.backgroundColor = [UIColor clearColor];
    playBackView.clipsToBounds = YES;
    [self.view addSubview:playBackView];
    playerMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    playerMask.hidden = YES;
    playerMask.backgroundColor = [UIColor blackColor];
    [playBackView addSubview:playerMask];
   
    _previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _previewView.backgroundColor = [UIColor clearColor];
    _previewView.clipsToBounds = YES;
    [self.view addSubview:_previewView];

    UIButton *_returnBtn = [UIButton buttonWithType:0];
    _returnBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
    [_returnBtn setImage:[UIImage imageNamed:@"white_backImg"] forState:0];
    [_returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [_previewView addSubview:_returnBtn];
   
    UIButton *saveBtn = [UIButton buttonWithType:0];
    saveBtn.frame = CGRectMake(_window_width - 55, 24+statusbarHeight, 40, 40);
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:0];
    [saveBtn setTitle:YZMsg(@"保存") forState:0];
    
    [saveBtn addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
       [_previewView addSubview:saveBtn];
    saveBtn.tag = 10087;
    
    UIButton *meiyanBtn = [UIButton buttonWithType:0];
    meiyanBtn.frame =CGRectMake(_window_width - 70, 104+statusbarHeight , 60, 60);
    meiyanBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [meiyanBtn setTitleColor:[UIColor whiteColor] forState:0];
    [meiyanBtn setImage:[UIImage imageNamed:getImagename(@"通话-美颜")] forState:0];
    [meiyanBtn addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    meiyanBtn.tag = 10086;
    [_previewView addSubview:meiyanBtn];
    self.meihuBtn = meiyanBtn;
}

#pragma mark ============设置推流参数，开始推流=============

- (void)RTMPush{
    [self.menuView showMenuView:NO];
    
    [self creatUI];
    [[YBLiveRTCManager shareInstance]initWithLiveMode:V2TXLiveMode_RTC];

    [[YBLiveRTCManager shareInstance]setPushView:_previewView];
    [YBLiveRTCManager shareInstance].delegate = self;
//    [[YBLiveRTCManager shareInstance]startPush:_hostUrl];
    if ([YBToolClass checkNull:[common getTISDKKey]]) {
        isTXfiter = YES;
        //9.19更新美颜
        [[YBLiveRTCManager shareInstance] setBeautyLevel:9 WhitenessLevel:3];

    }else{
        isTXfiter = NO;
        [self.menuView setupDefaultBeautyAndFaceValue];
    }
}
#pragma mark -美狐回调
-(void)MHBeautyBlock:(V2TXLiveVideoFrame *)srcFrame dstFrame:(V2TXLiveVideoFrame *)dstFrame
{
    dstFrame.textureId= [self.beautyManager getTextureProcessWithTexture:srcFrame.textureId width:(GLint)srcFrame.width height:(GLint)srcFrame.height mirror:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.menuView) {
            if (!isLoadWebSprout) {
                isLoadWebSprout = YES;
                [self.menuView setupDefaultBeautyAndFaceValue];

            }
        }
    });

}

#pragma mark ============底部按钮点击=============
-(void)tapsclick{
    self.meihuBtn.hidden = NO;
     self.sureBtn.hidden = NO;
     self.resetBtn.hidden = NO;
    [self.zhezhaoBtn removeFromSuperview];
    self.zhezhaoBtn = nil;
    [self.menuView showMenuView:NO];
}
- (void)bottomButtonClick:(UIButton *)sender{
    if (sender.tag == 10086) {
        //美颜
        a = 1;
        self.meihuBtn.hidden = YES;

        if (!isTXfiter) {
           [self.menuView showMenuView:YES];
        }else{
            [self userTXBase];
        }
        
    }else if(sender.tag == 10087){
         [self tishil];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];

    //腾讯基础美颜
    if (_vBeauty && _vBeauty.hidden == NO) {
        self.meihuBtn.hidden = NO;
        _vBeauty.hidden = YES;
    }
    if (self.menuView.isShow) {
        [self.menuView showMenuView:NO];
        if (![self.menuView isDescendantOfView:self.view]) {
            //self.bottomBgView.hidden = NO;
            self.meihuBtn.hidden = NO;
        }
    }
}
-(void)baocunshezhi{
    NSDictionary *dicccc;
    if ([YBToolClass checkNull:[common getTISDKKey]]){
        MYType = @"1";
           dicccc = @{
                @"skin_whiting":@(_tx_whitening_level),
                @"skin_smooth":@(_tx_beauty_level),
                @"skin_tenderness":@(_redfacDepth),
        };

    }else{
        MYType = @"2";
           dicccc = @{
                @"skin_whiting":@(_tx_whitening_level),
                @"skin_smooth":@(_tx_beauty_level),
                @"skin_tenderness":@(_redfacDepth),
                @"eye_brow":@(_meimao_level),
                @"big_eye":@(_tx_eye_level),
                @"eye_length":@(_yanju_level),
                @"eye_corner":@(_yanjiao_level),
                @"eye_alat":@(_kaiyanjiao_level),
                @"face_lift":@(_tx_face_level),
                @"face_shave":@(_xiaolian_level),
                @"mouse_lift":@(_mouse_level),
                @"nose_lift":@(_nose_level),
                @"chin_lift":@(_xiaba_level),
                @"forehead_lift":@(_head_level),
                @"lengthen_noseLift":@(_longnose_level),
                @"brightness":@(_light_level),
        };

    }

    NSString *specsStr =  [self gs_jsonStringCompactFormatForNSArray:dicccc];
     NSLog(@"设置美颜参数--------%@",specsStr);
    [YBToolClass postNetworkWithUrl:@"user.setBeauty" andParameter:@{@"uid":[Config getOwnID],@"token":[Config getOwnToken],@"type":MYType,@"preinstall":specsStr} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        NSLog(@"info---------:%@", info);
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];

}
- (NSString *)gs_jsonStringCompactFormatForNSArray:(NSDictionary *)arrJson {
    if (![arrJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:arrJson]) {
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrJson options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return strJson;
}

-(void)tishil{
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:YZMsg(@"是否保存当前美颜设置") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *defau = [UIAlertAction actionWithTitle:YZMsg(@"保存") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        [self baocunshezhi];
    }];
    [alt addAction:cancel];
    [alt addAction:defau];
    [defau setValue:normalColors forKey:@"_titleTextColor"];
    [cancel setValue:[UIColor grayColor] forKey:@"_titleTextColor"];
    [self presentViewController:alt animated:YES completion:nil];
}
#pragma mark ============腾讯美颜=============
-(void)userTXBase {
    if (!_vBeauty) {
        [self txBaseBeauty];
    }
    _vBeauty.hidden = NO;
    [self.view bringSubviewToFront:_vBeauty];
}
-(void)txBaseBeauty {
    _filterArray = [NSMutableArray new];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"原图";
        v.face = [UIImage imageNamed:getImagename(@"orginal")];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"美白";
        v.face = [UIImage imageNamed:getImagename(@"fwhite")];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"浪漫";
        v.face = [UIImage imageNamed:getImagename(@"langman")];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"清新";
        v.face = [UIImage imageNamed:getImagename(@"qingxin")];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"唯美";
        v.face = [UIImage imageNamed:getImagename(@"weimei")];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"粉嫩";
        v.face = [UIImage imageNamed:getImagename(@"fennen")];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"怀旧";
        v.face = [UIImage imageNamed:getImagename(@"huaijiu")];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"蓝调";
        v.face = [UIImage imageNamed:getImagename(@"landiao")];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"清凉";
        v.face = [UIImage imageNamed:getImagename(@"qingliang")];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"日系";
        v.face = [UIImage imageNamed:getImagename(@"rixi")];
        v;
    })];
    
    
    
    //美颜拉杆浮层
    float   beauty_btn_width  = 65;
    float   beauty_btn_height = 30;//19;
    
    float   beauty_btn_count  = 2;
    
    float   beauty_center_interval = (self.view.width - 30 - beauty_btn_width)/(beauty_btn_count - 1);
    float   first_beauty_center_x  = 15 + beauty_btn_width/2;
    int ib = 0;
    _vBeauty = [[UIView  alloc] init];
    _vBeauty.frame = CGRectMake(0, self.view.height-200-statusbarHeight, self.view.width, 200+statusbarHeight);
    [_vBeauty setBackgroundColor:[UIColor whiteColor]];
    float   beauty_center_y = _vBeauty.height - 30;//35;
    _beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _beautyBtn.center = CGPointMake(first_beauty_center_x, beauty_center_y);
    _beautyBtn.bounds = CGRectMake(0, 0, beauty_btn_width, beauty_btn_height);
    [_beautyBtn setImage:[UIImage imageNamed:@"white_beauty"] forState:UIControlStateNormal];
    [_beautyBtn setImage:[UIImage imageNamed:@"white_beauty_press"] forState:UIControlStateSelected];
    [_beautyBtn setTitle:YZMsg(@"美颜") forState:UIControlStateNormal];
    [_beautyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_beautyBtn setTitleColor:normalColors forState:UIControlStateSelected];
    _beautyBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    _beautyBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _beautyBtn.tag = 0;
    _beautyBtn.selected = YES;
    [_beautyBtn addTarget:self action:@selector(selectBeauty:) forControlEvents:UIControlEventTouchUpInside];
    ib++;
    _filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterBtn.center = CGPointMake(first_beauty_center_x + ib*beauty_center_interval, beauty_center_y);
    _filterBtn.bounds = CGRectMake(0, 0, beauty_btn_width, beauty_btn_height);
    [_filterBtn setImage:[UIImage imageNamed:@"beautiful"] forState:UIControlStateNormal];
    [_filterBtn setImage:[UIImage imageNamed:@"beautiful_press"] forState:UIControlStateSelected];
    [_filterBtn setTitle:YZMsg(@"滤镜") forState:UIControlStateNormal];
    [_filterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_filterBtn setTitleColor:normalColors forState:UIControlStateSelected];
    _filterBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    _filterBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _filterBtn.tag = 1;
    [_filterBtn addTarget:self action:@selector(selectBeauty:) forControlEvents:UIControlEventTouchUpInside];
    ib++;
    _beautyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,  _beautyBtn.top - 135, 40, 20)];
    if (![lagType isEqual:ZH_CN]) {
        _beautyLabel.frame = CGRectMake(10,  _beautyBtn.top - 135, 60, 20);
    }
    _beautyLabel.text = YZMsg(@"美白");
    _beautyLabel.font = [UIFont systemFontOfSize:12];
    _sdBeauty = [[UISlider alloc] init];
    _sdBeauty.frame = CGRectMake(_beautyLabel.right, _beautyBtn.top - 135, self.view.width - _beautyLabel.right - 50, 20);
    _sdBeauty.minimumValue = 0;
    _sdBeauty.maximumValue = 9;
//    _sdBeauty.value = [_dataarr[@"skin_whiting"] floatValue];;;
    [_sdBeauty setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sdBeauty setMinimumTrackImage:[YBToolClass getImgWithColor:normalColors] forState:UIControlStateNormal];
    [_sdBeauty setMaximumTrackImage:[UIImage imageNamed:@"gray"] forState:UIControlStateNormal];
    [_sdBeauty addTarget:self action:@selector(txsliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _sdBeauty.tag = 0;
    _beautyValueLb = [[UILabel alloc] initWithFrame:CGRectMake(_sdBeauty.right+5,  0, 40, 40)];
    _beautyValueLb.font = [UIFont systemFontOfSize:12];
    _beautyValueLb.centerY =_sdBeauty.centerY;
    _beautyValueLb.textColor = [UIColor blackColor];
    
    _whiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _beautyBtn.top - 95, _beautyLabel.width, 20)];
    _whiteLabel.text = YZMsg(@"磨皮");
    _whiteLabel.font = [UIFont systemFontOfSize:12];
    _sdWhitening = [[UISlider alloc] init];
    
    _sdWhitening.frame =  CGRectMake(_whiteLabel.right, _beautyBtn.top - 95, self.view.width - _whiteLabel.right - 50, 20);
    
    _sdWhitening.minimumValue = 0;
    _sdWhitening.maximumValue = 9;
//    _sdWhitening.value = [_dataarr[@"skin_smooth"] floatValue];
    [_sdWhitening setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sdWhitening setMinimumTrackImage:[YBToolClass getImgWithColor:normalColors] forState:UIControlStateNormal];//[UIImage imageNamed:@"green"]
    [_sdWhitening setMaximumTrackImage:[UIImage imageNamed:@"gray"] forState:UIControlStateNormal];
    [_sdWhitening addTarget:self action:@selector(txsliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _sdWhitening.tag = 1;
    _whiteValueLb = [[UILabel alloc] initWithFrame:CGRectMake(_sdWhitening.right+5,  0, 40, 40)];
    _whiteValueLb.font = [UIFont systemFontOfSize:12];
    _whiteValueLb.centerY =_sdWhitening.centerY;


    _redLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _beautyBtn.top - 55, _beautyLabel.width, 20)];
    _redLabel.text = YZMsg(@"红润");
    _redLabel.font = [UIFont systemFontOfSize:12];
    _sdredFace = [[UISlider alloc] init];
    _sdredFace.frame =  CGRectMake(_whiteLabel.right, _beautyBtn.top - 55, self.view.width - _whiteLabel.right - 50, 20);
    
    _sdredFace.minimumValue = 0;
    _sdredFace.maximumValue = 9;
//    _sdredFace.value = [_dataarr[@"skin_tenderness"] floatValue];
    [_sdredFace setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sdredFace setMinimumTrackImage:[YBToolClass getImgWithColor:normalColors] forState:UIControlStateNormal];//[UIImage imageNamed:@"green"]
    [_sdredFace setMaximumTrackImage:[UIImage imageNamed:@"gray"] forState:UIControlStateNormal];
    [_sdredFace addTarget:self action:@selector(txsliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _sdredFace.tag = 6;
    
    _redValueLb = [[UILabel alloc] initWithFrame:CGRectMake(_sdredFace.right+5,  0, 40, 40)];
    _redValueLb.font = [UIFont systemFontOfSize:12];
    _redValueLb.centerY =_sdredFace.centerY;
    
    _sdBeauty.value = 0;
    _sdWhitening.value =0;
    _sdredFace.value = 0;

    
    if ([YBToolClass checkNull:[common getTISDKKey]]){
        if ([minstr([_normalMYDic valueForKey:@"ishave"]) isEqual:@"1"]) {
            _tx_whitening_level = [[_normalMYDic valueForKey:@"preinstall"][@"skin_whiting"] floatValue];
            _redfacDepth = [[_normalMYDic valueForKey:@"preinstall"][@"skin_tenderness"] floatValue];
            _tx_beauty_level = [[_normalMYDic valueForKey:@"preinstall"][@"skin_smooth"] floatValue];
            _sdBeauty.value = _tx_whitening_level;
            _sdWhitening.value =_tx_beauty_level;
            _sdredFace.value = _redfacDepth;
        }
    }
    _beautyValueLb.text = [NSString stringWithFormat:@"%d",(int)_sdBeauty.value];
    _whiteValueLb.text = [NSString stringWithFormat:@"%d",(int)_sdWhitening.value];
    _redValueLb.text = [NSString stringWithFormat:@"%d",(int)_sdredFace.value];

    _filterPickerView = [[V8HorizontalPickerView alloc] initWithFrame:CGRectMake(0, 10, self.view.width, 115)];
    _filterPickerView.textColor = [UIColor grayColor];
    _filterPickerView.elementFont = [UIFont fontWithName:@"" size:14];
    _filterPickerView.delegate = self;
    _filterPickerView.dataSource = self;
    _filterPickerView.hidden = YES;
    
    UIImageView *sel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_selected"]];
    
    _filterPickerView.selectedMaskView = sel;
    _filterType = 0;
    
    [_vBeauty addSubview:_beautyLabel];
    [_vBeauty addSubview:_whiteLabel];
    [_vBeauty addSubview:_sdWhitening];
    [_vBeauty addSubview:_sdredFace];
    [_vBeauty addSubview:_redLabel];
    [_vBeauty addSubview:_sdBeauty];
    [_vBeauty addSubview:_beautyBtn];
    [_vBeauty addSubview:_bigEyeLabel];
    [_vBeauty addSubview:_sdBigEye];
    [_vBeauty addSubview:_slimFaceLabel];
    [_vBeauty addSubview:_sdSlimFace];
    [_vBeauty addSubview:_filterPickerView];
    [_vBeauty addSubview:_filterBtn];
    _vBeauty.hidden = YES;
    [_vBeauty addSubview:_beautyValueLb];
    [_vBeauty addSubview:_whiteValueLb];
    [_vBeauty addSubview:_redValueLb];
    [self.view addSubview: _vBeauty];
}
#pragma mark ================ 腾讯美颜start ===============


-(void)txsliderValueChange:(UISlider*) obj {
    // todo
    if (obj.tag == 1) { //美颜
        _tx_beauty_level = obj.value;
        // [_txLivePublisher setBeautyStyle:0 beautyLevel:_tx_beauty_level whitenessLevel:_tx_whitening_level ruddinessLevel:_redfacDepth];
        // [_txLivePublisher setBeautyFilterDepth:_beauty_level setWhiteningFilterDepth:_whitening_level];
        _whiteValueLb.text = [NSString stringWithFormat:@"%d",(int)obj.value];
    } else if (obj.tag == 0) { //美白
        _tx_whitening_level = obj.value;
        // [_txLivePublisher setBeautyStyle:0 beautyLevel:_tx_beauty_level whitenessLevel:_tx_whitening_level ruddinessLevel:_redfacDepth];
        _beautyValueLb.text = [NSString stringWithFormat:@"%d",(int)obj.value];
        // [_txLivePublisher setBeautyFilterDepth:_beauty_level setWhiteningFilterDepth:_whitening_level];
    } else if (obj.tag == 2) { //大眼
        _tx_eye_level = obj.value;
        // [_txLivePublisher setEyeScaleLevel:_tx_eye_level];
    } else if (obj.tag == 3) { //瘦脸
        _tx_face_level = obj.value;
        // [_txLivePublisher setFaceScaleLevel:_tx_face_level];
    } else if (obj.tag == 4) {// 背景音乐音量
        // [_txLivePublisher setBGMVolume:(obj.value/obj.maximumValue)];
    } else if (obj.tag == 5) { // 麦克风音量
        // [_txLivePublisher setMicVolume:(obj.value/obj.maximumValue)];
    }else if (obj.tag == 6){//红润
        _redfacDepth = obj.value;
        // [_txLivePublisher setBeautyStyle:0 beautyLevel:_tx_beauty_level whitenessLevel:_tx_whitening_level ruddinessLevel:_redfacDepth];
        _redValueLb.text = [NSString stringWithFormat:@"%d",(int)obj.value];
    }
    [[YBLiveRTCManager shareInstance] setYBRuddyLevel:_redfacDepth];
    [[YBLiveRTCManager shareInstance] setBeautyLevel:_tx_beauty_level WhitenessLevel:_tx_whitening_level];
}

-(void)selectBeauty:(UIButton *)button{
    switch (button.tag) {
        case 0: {
            _redLabel.hidden = NO;
            _sdredFace.hidden = NO;
            _sdWhitening.hidden = NO;
            _sdBeauty.hidden    = NO;
            _beautyLabel.hidden = NO;
            _whiteLabel.hidden  = NO;
            _bigEyeLabel.hidden = NO;
            _sdBigEye.hidden    = NO;
            _slimFaceLabel.hidden = NO;
            _sdSlimFace.hidden    = NO;
            _beautyBtn.selected  = YES;
            _filterBtn.selected = NO;
            _filterPickerView.hidden = YES;
            _beautyValueLb.hidden = NO;
            _whiteValueLb.hidden = NO;
            _redValueLb.hidden = NO;
            _vBeauty.frame = CGRectMake(0, self.view.height-185-statusbarHeight, self.view.width, 185+statusbarHeight);
        }break;
        case 1: {
             _sdredFace.hidden = YES;
            _redLabel.hidden = YES;
            _sdWhitening.hidden = YES;
            _sdBeauty.hidden    = YES;
            _beautyLabel.hidden = YES;
            _whiteLabel.hidden  = YES;
            _bigEyeLabel.hidden = YES;
            _sdBigEye.hidden    = YES;
            _slimFaceLabel.hidden = YES;
            _sdSlimFace.hidden    = YES;
            _beautyBtn.selected  = NO;
            _filterBtn.selected = YES;
            _filterPickerView.hidden = NO;
            _beautyValueLb.hidden = YES;
            _whiteValueLb.hidden = YES;
            _redValueLb.hidden = YES;

            [_filterPickerView scrollToElement:_filterType animated:NO];
        }
            _beautyBtn.center = CGPointMake(_beautyBtn.center.x, _vBeauty.frame.size.height - 35-statusbarHeight);
            _filterBtn.center = CGPointMake(_filterBtn.center.x, _vBeauty.frame.size.height - 35-statusbarHeight);
    }
}
//设置美颜滤镜
#pragma mark - HorizontalPickerView DataSource Methods/Users/annidy/Work/RTMPDemo_PituMerge/RTMPSDK/webrtc
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return [_filterArray count];
}
#pragma mark - HorizontalPickerView Delegate Methods
- (UIView *)horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index {
    V8LabelNode *v = [_filterArray objectAtIndex:index];
    return [[UIImageView alloc] initWithImage:v.face];
}
- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    return 90;
}
- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    _filterType = index;
    [self filterSelected:index];
}
- (void)filterSelected:(NSInteger)index {
    NSString* lookupFileName = @"";
    switch (index) {
        case FilterType_None:
            break;
        case FilterType_white:
            lookupFileName = @"filter_white";
            break;
        case FilterType_langman:
            lookupFileName = @"filter_langman";
            break;
        case FilterType_qingxin:
            lookupFileName = @"filter_qingxin";
            break;
        case FilterType_weimei:
            lookupFileName = @"filter_weimei";
            break;
        case FilterType_fennen:
            lookupFileName = @"filter_fennen";
            break;
        case FilterType_huaijiu:
            lookupFileName = @"filter_huaijiu";
            break;
        case FilterType_landiao:
            lookupFileName = @"filter_landiao";
            break;
        case FilterType_qingliang:
            lookupFileName = @"filter_qingliang";
            break;
        case FilterType_rixi:
            lookupFileName = @"filter_rixi";
            break;
        default:
            break;
    }
    NSString * path = [[NSBundle mainBundle] pathForResource:lookupFileName ofType:@"png"];
    if (path != nil && index != FilterType_None) {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        // [_txLivePublisher setFilter:image];
        [[YBLiveRTCManager shareInstance] setYBFilter:image];
    }
    else if(index == FilterType_None) {
        // [_txLivePublisher setFilter:nil];
        [[YBLiveRTCManager shareInstance] setYBFilter:nil];
    }
}

#pragma mark ================ 腾讯美颜end ===============
#pragma mark ================ 美狐 ===============
- (GLuint)onPreProcessTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height{
//    GLuint textId = [self.beautyManager processWithTexture:texture width:width height:height numerator:3 denominator:4];
//
//       return textId;
     [self.beautyManager processWithTexture:texture width:width height:height];
    if (self.menuView) {
         if (!isLoadWebSprout) {
             isLoadWebSprout = YES;
//             [self.menuView setupDefaultBeautyAndFaceValueWithIsTX:YES];
             [self.menuView setupDefaultBeautyAndFaceValue];

        }
        
    }
    
    //[self.menuView setBeautyManager:self.beautyManager];
    return texture;
    
}
- (void)beautyEffectWithLevel:(NSInteger)beauty whitenessLevel:(NSInteger)white ruddinessLevel:(NSInteger)ruddiness {
    //用腾讯的美颜
    _tx_beauty_level = beauty;//默认参数，可以不设置
    _tx_whitening_level = white;//默认参数，可以不设置
    _redfacDepth = ruddiness;
    
     TXBeautyManager *manager = [_txLivePublisher getBeautyManager];
       [manager setBeautyStyle:0];
       [manager setBeautyLevel:beauty];
       [manager setWhitenessLevel:white];
       [manager setRuddyLevel:ruddiness];

}
-(void)lights:(NSInteger)lightvalue{
    _light_level = lightvalue;
      NSLog(@"------===搜立案大眼 ==%ld",(long)lightvalue);
   
}
//美型
-(void)meixing:(NSInteger)type andvalue:(NSInteger)value{
 
    if (type == 0){
        NSDictionary *dics =@{
                              @"big_eye": @"30",
                              @"chin_lift" :@"50",
                              @"eye_alat" : @"0",
                              @"eye_brow" :@"0",
                              @"eye_corner" :@"0",
                              @"eye_length" :@"0",
                              @"face_lift" :@"30",
                              @"face_shave" :@"0",
                              @"forehead_lift":@"50",
                              @"lengthen_noselift":@"0",
                              @"mouse_lift" :@"50",
                              @"nose_lift":@"50",
                              @"skin_saturation":@"50",
                              @"skin_smooth" :[NSString stringWithFormat:@"%f",_tx_beauty_level],
                              @"skin_tenderness" :[NSString stringWithFormat:@"%f",_redfacDepth],
                              @"skin_whiting" :[NSString stringWithFormat:@"%f",_tx_whitening_level],
                              };
     
        _light_level = 50;
        _tx_eye_level = 30;
        _tx_face_level = 30;
        _mouse_level = 50;
        _nose_level = 50;
        _xiaba_level = 50;
        _head_level = 50;
        _meimao_level = 0;
        _yanjiao_level = 0;
        _yanju_level = 0;
        _kaiyanjiao_level = 0;
        _xiaolian_level = 0;
        _longnose_level = 0;
    }
   else if (type == 1) {
       //大眼
        _tx_eye_level = (float)value;
    }else if (type == 2) {
        //瘦脸
        _tx_face_level = (float)value;
    }
    else if (type == 3) {
        //嘴型
        _mouse_level = (float)value;
    }
    else if (type == 4) {
        //瘦鼻
        _nose_level = (float)value;
    }
    else if (type == 5) {
        //下巴
        _xiaba_level = (float)value;
    }
    else if (type == 6) {
        //额头
        _head_level = (float)value;
    }
    else if (type == 7) {
        //眉毛
        _meimao_level = (float)value;
    }
    else if (type == 8) {
        //眼角
        _yanjiao_level = (float)value;
    }
    else if (type == 9) {
        //眼距
        _yanju_level = (float)value;
    }
    else if (type == 10) {
        //开眼角
        _kaiyanjiao_level = (float)value;
    }
    else if (type == 11) {
        //削脸
        _xiaolian_level = (float)value;
    }
    else if (type == 12) {
        //长鼻
        _longnose_level = (float)value;
    }
}
//一键美颜
-(void)yijianMeiyanFace:(int)setface andeye:(int)bigeve andmounse:(int)mourese andnose:(int)setnose andChin:(int)setchin andForehead:(int)forhead andEyeBrown:(int)seteyebrown andEyeAngle:(int)eyeangle andEyeAlaeLift:(int)eyealea andShaveFace:(int)xiaolian andEyeDistanc:(int)yanju andindex:(NSInteger)index{
    NSDictionary *dics =@{
                          @"big_eye": [NSString stringWithFormat:@"%d",bigeve],
                          @"chin_lift" :[NSString stringWithFormat:@"%d",setchin],
                          @"eye_alat" : [NSString stringWithFormat:@"%d",eyealea],
                          @"eye_brow" :[NSString stringWithFormat:@"%d",seteyebrown],
                          @"eye_corner" :[NSString stringWithFormat:@"%d",eyeangle],
                          @"eye_length" :[NSString stringWithFormat:@"%d",yanju],
                          @"face_lift" :[NSString stringWithFormat:@"%d",setface],
                          @"face_shave" :[NSString stringWithFormat:@"%d",xiaolian],
                          @"forehead_lift":[NSString stringWithFormat:@"%d",forhead],
                          @"lengthen_noselift":@"0",
                          @"mouse_lift" :[NSString stringWithFormat:@"%d",mourese],
                          @"nose_lift":[NSString stringWithFormat:@"%d",setnose],
                          @"skin_saturation":@"50",
                          @"skin_smooth" :[NSString stringWithFormat:@"%f",_tx_beauty_level],
                          @"skin_tenderness" :[NSString stringWithFormat:@"%f",_redfacDepth],
                          @"skin_whiting" :[NSString stringWithFormat:@"%f",_tx_whitening_level],
                          };
    _tx_eye_level = bigeve;
    _tx_face_level = setface;
    _mouse_level = mourese;
    _nose_level = setnose;
    _xiaba_level = setchin;
    _head_level = forhead;
    _meimao_level = seteyebrown;
    _yanjiao_level = eyeangle;
    _yanju_level = yanju;
    _kaiyanjiao_level = eyealea;
    _xiaolian_level = xiaolian;
    yijianindex = index;
}
-(void)chongzhi{
 
    NSDictionary *dics =@{
        @"big_eye": @"30",
        @"chin_lift" :@"50",
        @"eye_alat" : @"0",
        @"eye_brow" :@"0",
        @"eye_corner" :@"0",
        @"eye_length" :@"0",
        @"face_lift" :@"30",
        @"face_shave" :@"0",
        @"forehead_lift":@"50",
        @"lengthen_noselift":@"0",
        @"mouse_lift" :@"50",
        @"nose_lift":@"50",
        @"skin_saturation":@"50",
        @"skin_smooth" :@"4",
        @"skin_tenderness" :@"2",
        @"skin_whiting" :@"5",
        @"filter":@"0",
        @"distorting":@"0",
        @"special":@"0",
        @"sticker":@"",
        };
//    [common savemeiyan:dics];
    _tx_whitening_level = 5;
    _redfacDepth = 2;
    _tx_beauty_level = 4;
    _light_level = 50;
    _tx_eye_level = 30;
    _tx_face_level = 30;
    _mouse_level = 50;
    _nose_level = 50;
    _xiaba_level = 50;
    _head_level = 50;
    _meimao_level = 0;
    _yanjiao_level = 0;
    _yanju_level = 0;
    _kaiyanjiao_level = 0;
    _xiaolian_level = 0;
    _longnose_level = 0;
    yijianindex = 0;
    lvjingindex = 0;
    texiaoindex = 0;
    hahajingindex = 0;
    tiezhistr = @"";
     [_txLivePublisher setBeautyStyle:0 beautyLevel:_tx_beauty_level whitenessLevel:_tx_whitening_level ruddinessLevel:_redfacDepth];
    
    //重置滤镜
     // [_beautyManager setFilterName:0];
      [_beautyManager setFilterType:0 newFilterInfo:[NSDictionary dictionary]];
   // lvjingindex = 0;

    
    //重置特效

     [self.beautyManager setJitterType:0];
    //重置哈哈镜
    
//     [self.beautyManager setDistortType:0];
    [_beautyManager setDistortType:0 withIsMenu:NO];

    //重置贴纸

//    [self.beautyManager setSticker:@""];
    [self.beautyManager setSticker:@"" withLevel:0];

    
}
//滤镜
-(void)lvjing:(NSInteger)index{
    lvjingindex = index;
}
//特效
-(void)texiao:(NSInteger)index{
    texiaoindex = index;
}
//哈哈镜
-(void)hahajing:(NSInteger)index{
    hahajingindex = index;
}
//贴纸
-(void)tiezhie:(NSString *)tiezi{
    tiezhistr = tiezi;
    
}

- (void)onTextureDestoryed{
    
}

- (void)changeFrame{
    [UIView animateWithDuration:0.2 animations:^{
        _previewView.frame = CGRectMake(_window_width*0.65, 40+statusbarHeight, _window_width*0.32, _window_width*0.32*1.33);
    }];
}

//

//直播结束时 停止所有计时器
-(void)liveOver{
  
    if(_txLivePublisher != nil)
    {
        _txLivePublisher.delegate = nil;
        [_txLivePublisher stopPreview];
        [_txLivePublisher stopPush];
        _txLivePublisher.config.pauseImg = nil;
        _txLivePublisher = nil;
    }
    
}



- (void)doReturn{
//    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"islive"];
//    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[YBLiveRTCManager shareInstance]stopPush];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc{
    if (self.beautyManager) {
        [self.beautyManager destroy];
        self.beautyManager = nil;
    }
    [self liveOver];
   
    NSLog(@"dealloc");
}
#pragma tx_play_linkmic 代理
-(void)tx_closeUserbyVideo:(NSDictionary *)subdic{
   
}
-(void) onNetStatus:(NSDictionary*) param{
    
}
-(void)onPushEvent:(int)EvtID withParam:(NSDictionary*)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID >= 0) {
            if (EvtID == PUSH_WARNING_HW_ACCELERATION_FAIL) {
                _txLivePublisher.config.enableHWAcceleration = false;
                NSLog(@"PUSH_EVT_PUSH_BEGIN硬编码启动失败，采用软编码");
            }else if (EvtID == PUSH_EVT_CONNECT_SUCC) {
                // 已经连接推流服务器
                NSLog(@" PUSH_EVT_PUSH_BEGIN已经连接推流服务器");
            }else if (EvtID == PUSH_EVT_PUSH_BEGIN) {
                // 已经与服务器握手完毕,开始推流
               // [self changePlayState];
                NSLog(@"liveshow已经与服务器握手完毕,开始推流");
            }else if (EvtID == PUSH_WARNING_RECONNECT){
                // 网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)
                NSLog(@"网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)");
            }else if (EvtID == PUSH_WARNING_NET_BUSY) {
                
            }
        }else {
            if (EvtID == PUSH_ERR_NET_DISCONNECT) {
                NSLog(@"PUSH_EVT_PUSH_BEGIN网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启推流");
                
                //[self gainRevenueFromCalls];
            }
        }
    });
}
//播放监听事件
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_CONNECT_SUCC) {
            NSLog(@"moviplay不连麦已经连接服务器");
        }
        else if (EvtID == PLAY_EVT_RTMP_STREAM_BEGIN){
            NSLog(@"moviplay不连麦已经连接服务器，开始拉流");
        }
        else if (EvtID == PLAY_EVT_PLAY_BEGIN){
            NSLog(@"moviplay不连麦视频播放开始");
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }
        else if (EvtID== PLAY_WARNING_VIDEO_PLAY_LAG){
            NSLog(@"moviplay不连麦当前视频播放出现卡顿（用户直观感受）");
        }
        else if (EvtID == PLAY_EVT_PLAY_END){
            NSLog(@"moviplay不连麦视频播放结束");
            [_txLivePlayer resume];
        }
        else if (EvtID == PLAY_ERR_NET_DISCONNECT) {
            //视频播放结束
            NSLog(@"moviplay不连麦网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放");
        }
    });
}
@end

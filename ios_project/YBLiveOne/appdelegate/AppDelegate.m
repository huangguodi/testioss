//
//  AppDelegate.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/29.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "AppDelegate.h"
#import "PreLoginVC.h"
/******shark sdk *********/
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <Bugly/Bugly.h>
#import <WXApi.h>
#import "YBTabBarController.h"
#import "TUIKit.h"
#import <QMapKit/QMapKit.h>
#import <QMapSearchKit/QMapSearchKit.h>
#import <AlipaySDK/AlipaySDK.h>
#import "TXUGCBase.h"
#import "TXLiveBase.h"
#import "GuideViewController.h"
//#import "ZXRequestBlock.h"
#import "OpenInstallSDK.h"

#import <ZFPlayer/ZFLandscapeRotationManager.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [YBToolClass networkMonitoring:^(Netability event, NSDictionary * _Nonnull eventDic) {
        [YBToolClass buildUpdate];
    }];
    
    [[SDWebImageDownloader sharedDownloader] setValue:nil forHTTPHeaderField:@"Accept"];
    [[SDWebImageDownloader sharedDownloader] setValue:h5url forHTTPHeaderField:@"referer"];

    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
     
    [self setLanguage];
    
    [OpenInstallSDK  initWithDelegate:self];

    [Bugly startWithAppId:BuglyId];
    
    [[TUIKit sharedInstance] initKit:TXIMSdkAppid accountType:TXIMSdkAccountType withConfig:[TUIKitConfig defaultConfig]];
    
    [TXUGCBase setLicenceURL:LicenceURL key:LicenceKey];
    [TXLiveBase setLicenceURL:LicencePushURL key:LicencePushKey];
//    [TXLiveBase setConsoleEnabled:NO];
//    [TXLiveBase setLogLevel:LOGLEVEL_NULL];
//Braintree
    //NSString *urlshe = [NSString stringWithFormat:@"%@.payments",[self getBundleID]];
    [BTAppSwitch setReturnURLScheme:BraintreeURL];

    //设置显示数字
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // 设置通知的类型可以为弹窗提示,声音提示,应用图标数字提示
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    // 授权通知
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"voiceSwitch"] == nil) {
        [common saveSwitch:YES];
    }
    
#pragma mark ============判断是否在直播间=============
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"islive"];
#pragma mark ============判断是否在聊天界面=============
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"ismessageing"];
#pragma mark ============记录聊天用户的ID=============
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"messageingUserID"];

    self.window = [[UIWindow alloc]initWithFrame:CGRectMake(0,0,_window_width, _window_height)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self thirdPlant];
    });
    NSString *uid = minstr([Config getOwnID]);
    if (uid && [uid integerValue] > 0) {
        [self IMLogin];
    }
    self.window.rootViewController =  [[UINavigationController alloc] initWithRootViewController:[[GuideViewController alloc] init]];
    [self.window makeKeyAndVisible];

    //生命周期监听
    [[RKKeepAlive sharedKeepInstance] startAppLifeCycleMonitor];

    return YES;
}
#pragma mark - 设置语言
-(void)setLanguage {
    //默认值【有语言开发删除此行】
    //[[NSUserDefaults standardUserDefaults] setObject:ZH_CN forKey:CurrentLanguage];
    
    // 获取历史
    if (lagType) {
        [[NSUserDefaults standardUserDefaults] setObject:lagType forKey:CurrentLanguage];
    }else{
        BOOL isCn = [[RookieTools shareInstance] isChinese];
        if (isCn) {
            [[NSUserDefaults standardUserDefaults] setObject:ZH_CN forKey:CurrentLanguage];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:EN forKey:CurrentLanguage];
        }
    }
    [[RookieTools shareInstance] resetLanguage:[[NSUserDefaults standardUserDefaults] objectForKey:CurrentLanguage] withFrom:@"appdelegate"];
}
-(NSString*)getBundleID
{
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}
-(void)thirdPlant{
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
    [platformsRegister setupQQWithAppId:QQAppId appkey:QQAppKey enableUniversalLink:YES universalLink:QQLinks];
    [platformsRegister setupWeChatWithAppId:WechatAppId appSecret:WechatAppSecret universalLink:WechatUniversalLink];
    }];
}
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    //处理通过openinstall一键唤起App时传递的数据
    [OpenInstallSDK continueUserActivity:userActivity];
    //其他第三方回调；
     return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    [OpenInstallSDK handLinkURL:url];

    NSString *urlshe = [NSString stringWithFormat:@"%@.payments",[self getBundleID]];
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            [[NSNotificationCenter defaultCenter]postNotificationName:@"aliPayNot" object:nil userInfo:resultDic];
        }];
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];

    }else if ([url.host isEqualToString:@"pay"]){
        return [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)self];
    }else if ([url.scheme localizedCaseInsensitiveCompare:BraintreeURL] == NSOrderedSame) {
        return [BTAppSwitch handleOpenURL:url options:options];
    }

    
    return YES;
}
-(void)onResp:(BaseResp *)resp{
    //支付返回结果，实际支付结果需要去微信服务器端查询
    NSString *strMsg;
    NSString *code;
    switch (resp.errCode) {
        case WXSuccess:{
            code = @"0";
            strMsg = YZMsg(@"支付成功");
        }break;
        case WXErrCodeUserCancel:{
            code = @"-1";
            strMsg = YZMsg(@"支付取消");
        }break;
        default:{
            code = @"-1";
            strMsg = YZMsg(@"支付失败");
            NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
        }break;
    }
    NSDictionary *dic = @{
                          @"msg":strMsg,
                          @"code":code
                          };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"wxPayNot" object:nil userInfo:dic];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.lifeCycleEvent) {
        self.lifeCycleEvent(APPLifeCycle_EnterBackground);
    }

    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){}];

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    if (self.lifeCycleEvent) {
        self.lifeCycleEvent(APPLifeCycle_EnterForeground);
    }

    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"rk_paying"]isEqual:@"1"]) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"rk_paying"];
        [MBProgressHUD hideHUD];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shajincheng" object:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isStartCall"];
    if (self.lifeCycleEvent) {
        self.lifeCycleEvent(APPLifeCycle_WillTerminate);
    }

}

#pragma mark ============IM=============

- (void)IMLogin{
    [[YBImManager shareInstance] imLogin];

//    [[TUIKit sharedInstance] loginKit:[Config getOwnID] userSig:[Config lgetUserSign] succ:^{
//        NSLog(@"IM登录成功");
//    } fail:^(int code, NSString *msg) {
//        [MBProgressHUD showError:@"IM登录失败，请重新登录"];
//        [[YBToolClass sharedInstance] quitLogin];
////        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"code:%d msdg:%@ ,请检查 sdkappid,identifier,userSig 是否正确配置",code,msg] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
////        [alert show];
//    }];
}
//#pragma mark 拦截全局请求
//- (void)requestBlock{
//    [ZXRequestBlock handleRequest:^NSURLRequest *(NSURLRequest *request) {
//        NSLog(@"拦截到请求-%@",request);
//        dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"拦截到请求--%@\n",request);
//        });
//        return request;
//    }];
//    //禁止抓包
////    [ZXRequestBlock disableHttpProxy];
//    //开启抓包
//  [ZXRequestBlock enableHttpProxy];
//}



/// 在这里写支持的旋转方向，为了防止横屏方向，应用启动时候界面变为横屏模式
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    ZFInterfaceOrientationMask orientationMask = [ZFLandscapeRotationManager supportedInterfaceOrientationsForWindow:window];
    if (orientationMask != ZFInterfaceOrientationMaskUnknow) {
        return (UIInterfaceOrientationMask)orientationMask;
    }
    /// 这里是非播放器VC支持的方向
    return UIInterfaceOrientationMaskPortrait;

}

@end

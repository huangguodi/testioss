//
//  YBSetInforMationVC.m
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "YBSetInforMationVC.h"
#import "YBTabBarController.h"
#import "AppDelegate.h"
#import "TUIKit.h"
@interface YBSetInforMationVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>
{
    UIButton *headerBtns;
    UIButton *womenBtns;
    UIButton *manBtn;

    NSString *sexstr;
    UIImage *selectImage;
    NSString *namestr;
}
@property (nonatomic,strong) NSMutableArray *btnArray;
@property (nonatomic,strong) NSMutableArray *ImgbtnArray;
@end

@implementation YBSetInforMationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[YBToolClass sharedInstance]lineViewWithFrame:CGRectMake(0, self.naviView.height-1, _window_width, 1) andColor:[UIColor whiteColor] andView:self.naviView];
    self.btnArray = [NSMutableArray array];
    self.ImgbtnArray = [NSMutableArray array];
    sexstr = @"2";
    namestr = minstr([_dic valueForKey:@"user_nickname"]);
    [self creatUI];
}
- (void)creatUI{

    self.titleL.text = YZMsg(@"设置个人资料");
    int spac = -40;
    int linespac = -50;
    int sexspac = 60;
    if (IS_IPHONE_5){
        spac = -15;
        linespac = -20;
        sexspac = 30;
    }
    UIView *lineview = [[UIView alloc] init];
    [self.view addSubview:lineview];
    [lineview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(62);
        make.right.equalTo(self.view).offset(-62);
        make.height.mas_equalTo(1);
        make.centerY.equalTo(self.view).offset(linespac);
    }];
    lineview.backgroundColor = RGB_COLOR(@"#BFBFBF", 1);
    
    UITextField *namefile = [[UITextField alloc] init];
    [self.view addSubview:namefile];
    [namefile mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lineview);
      
        make.height.mas_equalTo(40);
        make.bottom.equalTo(lineview.mas_top);
    }];
    namefile.text = minstr([_dic valueForKey:@"user_nickname"]);
    [namefile addTarget:self action:@selector(changevalue:) forControlEvents:UIControlEventEditingChanged];
    namefile.placeholder = YZMsg(@"请设置您的昵称");
    namefile.font = [UIFont  systemFontOfSize:15];
    namefile.textAlignment = NSTextAlignmentCenter;
    
    UILabel *tilabel = [[UILabel alloc] init];
    [self.view addSubview:tilabel];
    
    [tilabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lineview);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(namefile.mas_top).offset(spac);
    }];
    tilabel.textAlignment = NSTextAlignmentCenter;
    tilabel.font = [UIFont systemFontOfSize:12];
    tilabel.textColor = RGB_COLOR(@"#AAAAAA", 1);
    tilabel.text = YZMsg(@"点击编辑头像");
    
    UIButton *headerBtn =[UIButton buttonWithType:0];
    [self.view addSubview:headerBtn];
    [headerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(lineview);
        make.width.height.mas_equalTo(100);
        make.bottom.equalTo(tilabel.mas_top).offset(-14);
    }];
    headerBtn.layer.cornerRadius = 50;
    headerBtn.layer.masksToBounds = YES;
    [headerBtn setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:minstr([_dic valueForKey:@"avatar_thumb"])]]] forState:0];
    [headerBtn addTarget:self action:@selector(selectphotoclick) forControlEvents:UIControlEventTouchUpInside];
    headerBtns = headerBtn;
    
    UILabel *sextilabel = [[UILabel alloc] init];
    [self.view addSubview:sextilabel];
    [sextilabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lineview);
        make.height.mas_equalTo(20);
        make.top.equalTo(lineview.mas_bottom).offset(sexspac);
    }];
    sextilabel.textAlignment = NSTextAlignmentCenter;
    sextilabel.font = [UIFont systemFontOfSize:12];
    sextilabel.textColor = RGB_COLOR(@"#323232", 1);
    sextilabel.text = YZMsg(@"请选择性别");
    NSArray *sexarray = @[@"selectgirl",@"unselectboy"];
    
    for (int i = 0; i < sexarray.count; i ++) {
        int space = -70;
        if (i == 1) {
            space = 70;
        }
        UIButton *womenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:womenBtn];
        [womenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(lineview.mas_centerX).offset(space);
            make.width.mas_equalTo(75);
            make.height.mas_equalTo(108);
            make.top.equalTo(sextilabel.mas_bottom).offset(24);
        }];
        [womenBtn setImage:[UIImage imageNamed:getImagename(sexarray[i])] forState:0];
        
        womenBtn.tag = 100998 + i;
        [womenBtn addTarget:self action:@selector(selectsexclick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            womenBtns = womenBtn;
        }else{
            manBtn = womenBtn;
        }
        
    }
    
    UIButton *joinBtn = [UIButton buttonWithType:0];
    [self.view addSubview:joinBtn];
    [joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(34);
        make.right.equalTo(self.view).offset(-34);
        make.bottom.equalTo(self.view).offset(-37 - ShowDiff);
        make.height.mas_equalTo(40);
    }];
    joinBtn.layer.cornerRadius = 20;
    joinBtn.layer.masksToBounds = YES;
    joinBtn.backgroundColor = RGB_COLOR(@"#7200FF", 1);
    [joinBtn setTitle:YZMsg(@"进入APP") forState:0];
    [joinBtn setTitleColor:[UIColor whiteColor] forState:0];
    joinBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [joinBtn addTarget:self action:@selector(joinclick) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark ====选择性别========
-(void)selectsexclick:(UIButton *)sender{
    if (sender.tag == 100998) {
        //女生
        sexstr = @"2";
        [womenBtns setImage:[UIImage imageNamed:getImagename(@"selectgirl")] forState:0];
        [manBtn setImage:[UIImage imageNamed:getImagename(@"unselectboy")] forState:0];
        
    }else{
        //男生
        sexstr = @"1";
        [womenBtns setImage:[UIImage imageNamed:getImagename(@"unselectgirl")] forState:0];
        [manBtn setImage:[UIImage imageNamed:getImagename(@"selectboy")] forState:0];
        
    }
}
#pragma mark ====选择相册========
-(void)selectphotoclick{
    
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *picAction = [UIAlertAction actionWithTitle:YZMsg(@"拍照") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectThumbWithType:UIImagePickerControllerSourceTypeCamera];
    }];
    [picAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:picAction];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:YZMsg(@"从相册选取") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[self selectThumbWithType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self selLocalPic];
    }];
    [photoAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:photoAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:cancleAction];
    
    [self presentViewController:alertContro animated:YES completion:nil];

}
- (void)selectThumbWithType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = type;
    imagePickerController.allowsEditing = YES;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:imagePickerController animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        selectImage = image;
        [headerBtns setImage:image forState:UIControlStateNormal];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}

-(void)selLocalPic {
    TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    imagePC.preferredLanguage = [lagType isEqual:ZH_CN] ? @"zh-Hans":@"en";
    imagePC.showSelectBtn = NO;
    imagePC.allowCrop = NO;
    imagePC.allowPickingOriginalPhoto = NO;
    imagePC.oKButtonTitleColorNormal = normalColors;
    imagePC.allowTakePicture = NO;
    imagePC.allowTakeVideo = NO;
    imagePC.allowPickingVideo = NO;
    imagePC.allowPickingMultipleVideo = NO;
    imagePC.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:imagePC animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    NSLog(@"------多选择图片--：%@",photos);
    UIImage* image = photos[0];
    selectImage = image;
    [headerBtns setImage:image forState:UIControlStateNormal];
}



#pragma mark ====修改昵称========
-(void)changevalue:(UITextField *)file{
    namestr = [self clearspacestr:file.text];
    NSLog(@"输出昵称===%@",namestr);
}
-(NSString *)clearspacestr:(NSString *)namestr{
  

    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];

    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];

    NSArray *parts = [namestr componentsSeparatedByCharactersInSet:whitespaces];

    //在空格处将字符串分割成一个 NSArray

    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];

    //去除空串

    NSString *jointStr = @"" ;

    namestr = [filteredArray componentsJoinedByString:jointStr];
    return namestr;
}
#pragma mark ====进入App========
-(void)joinclick{
    if (namestr.length == 0) {
        [MBProgressHUD showError:YZMsg(@"请设置您的昵称")];
        return;
    }
//    if (namestr.length > 7) {
//        [MBProgressHUD showError:YZMsg(@"昵称最多7个字")];
//        return;
//    }
    if (selectImage) {
        
        WeakSelf;
        [[YBStorageManage shareManage]getCOSInfo:^(int code) {
            if (code == 0) {
                [weakSelf startUpload];
            }
        }];
    }else{
        [self uploadEditMessage:@""];
    }
    
   
}
-(void)startUpload {
    [MBProgressHUD showMessage:YZMsg(@"正在提交")];
    NSString *imageName = [self getNameBaseCurrentTime:@"userHeader.png"];
    WeakSelf;
    [[YBStorageManage shareManage]yb_storageImg:selectImage andName:imageName progress:^(CGFloat percent) {
        
    } complete:^(int code, NSString *key) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            if (code == 0) {
                [weakSelf uploadEditMessage:key];
            }else {
                [MBProgressHUD showError:YZMsg(@"提交失败")];
            }
        });
    }];
    
}
- (void)uploadEditMessage:(NSString *)headerName{
    NSLog(@"输出头像参数===%@",headerName);
    [YBToolClass postNetworkWithUrl:[NSString stringWithFormat:@"User.setUserInfo&avatar=%@&name=%@&sex=%@",headerName,namestr,sexstr] andParameter:@{
        @"uid":minstr([_dic valueForKey:@"id"]),
        @"token":minstr([_dic valueForKey:@"token"])
    } success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSString *avatar = [infoDic valueForKey:@"avatar"];
            NSString *avatar_thumb = [infoDic valueForKey:@"avatar_thumb"];
            NSString *user_nickname = [infoDic valueForKey:@"user_nickname"];
            NSString *sexstr = [infoDic valueForKey:@"sex"];
            LiveUser *userInfo = [[LiveUser alloc] initWithDic:_dic];
            userInfo.avatar = avatar;
            userInfo.avatar_thumb = avatar_thumb;
            userInfo.user_nickname = user_nickname;
            userInfo.sex = sexstr;
            [Config saveProfile:userInfo];
            [self IMLogin];
            UIApplication *app =[UIApplication sharedApplication];
            AppDelegate *app2 = (AppDelegate *)app.delegate;
            if (!app2.ybtab) {
                [YBToolClass needRegNot:YES];
                YBTabBarController *tabbarV = [[YBTabBarController alloc]init];
                app2.ybtab = tabbarV;
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"HomeCheckAgent" object:nil];
            }
            app2.ybtab.selectedIndex = 0;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:app2.ybtab];
            app2.window.rootViewController = nav;
            [[YBYoungManager shareInstance]checkYoungStatus:YoungFrom_Home];

        }else{
            [MBProgressHUD showError:msg];
        }
       
        //
    } fail:^{
        [MBProgressHUD hideHUD];

    }];
    
}
-(NSString *)getNameBaseCurrentTime:(NSString *)suf {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *nameStr = [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:suf];
    return [NSString stringWithFormat:@"%@_IOS_%@",minstr([_dic valueForKey:@"id"]),nameStr];
}
#pragma mark ============IM=============

- (void)IMLogin{
    [YBToolClass setServerPushLang];
    [[YBImManager shareInstance] imLogin];

//    [[TUIKit sharedInstance] loginKit:[Config getOwnID] userSig:[Config lgetUserSign] succ:^{
//        NSLog(@"IM登录成功");
//    } fail:^(int code, NSString *msg) {
////        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"code:%d msdg:%@ ,请检查 sdkappid,identifier,userSig 是否正确配置",code,msg] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
////        [alert show];
//    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

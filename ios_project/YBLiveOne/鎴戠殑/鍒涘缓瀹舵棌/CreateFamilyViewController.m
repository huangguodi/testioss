//
//  CreateFamilyViewController.m
//  yunbaolive
//
//  Created by ybRRR on 2021/1/6.
//  Copyright © 2021 cat. All rights reserved.
//

#import "CreateFamilyViewController.h"
#import "MyTextField.h"
#import "RKActionSheet.h"
#import "MyTextView.h"

typedef NS_ENUM(NSInteger,CerType) {
    CerTypeDefault,
    CerTypeFace,
    CerTypeBack,
    CerTypeHand,
};

@interface CreateFamilyViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>
{
    UIScrollView *backScroll;
    
    NSString *_cerFacePath;
    NSString *_cerBackPath;
    NSString *_cerHandPath;

    BOOL _selectedImg;
    
    UIImageView *img1;
    UILabel *title1;
    
    UIImageView *img2;
    UILabel *title2;

    UIImageView *img3;
    UILabel *title3;


}
@property(nonatomic,strong)MyTextField *familyTF;
@property(nonatomic,strong)MyTextField *nameTF;
@property(nonatomic,strong)MyTextField *cardTF;
@property(nonatomic,strong)MyTextField *cutTF;
@property(nonatomic,strong)MyTextView *briefTF;

@property(nonatomic,strong)UIButton *cerFaceBtn;
@property(nonatomic,strong)UIImage *cerFaceImg;
@property(nonatomic,strong)UIButton *cerBackBtn;
@property(nonatomic,strong)UIImage *cerBackImg;
@property(nonatomic,strong)UIButton *cerHandBtn;
@property(nonatomic,strong)UIImage *cerHandImg;

@property(nonatomic,assign)CerType upCerType;

@end

@implementation CreateFamilyViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text= YZMsg(@"创建公会");
    [self initUI];

}
-(void)initUI{
    backScroll = [[UIScrollView alloc]init];
    backScroll.frame =CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight);
    backScroll.scrollEnabled=YES;
    backScroll.userInteractionEnabled=YES;
    [self.view addSubview:backScroll];

    UIView *backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, 0, backView.width, backView.height);
    [backScroll addSubview:backView];
   
    UIImageView *headImg = [[UIImageView alloc]init];
    headImg.frame = CGRectMake(0, 0, _window_width, 130);
    headImg.image = [UIImage imageNamed:getImagename(@"cjjz_bg")];
    [backView addSubview:headImg];
    
    UIView *subBack = [[UIView alloc]init];
    subBack.frame = CGRectMake(0, headImg.height-10, _window_width, 20);
    subBack.backgroundColor = [UIColor whiteColor];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:subBack.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
   CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
   maskLayer.frame = subBack.bounds;
   maskLayer.path = maskPath.CGPath;
    subBack.layer.mask = maskLayer;

    [headImg addSubview:subBack];
    
    NSArray *defaultArray = @[@{@"title":YZMsg(@"公会名称"),@"placeholder":YZMsg(@"请输入您要创建的公会名称")},
                              @{@"title":YZMsg(@"个人姓名"),@"placeholder":YZMsg(@"请输入您的姓名")},
                              @{@"title":YZMsg(@"身份证号"),@"placeholder":YZMsg(@"请输入您的身份证号码")},
                              @{@"title":YZMsg(@"抽成比例"),@"placeholder":YZMsg(@"请填写0-100之间的整数")},
                              @{@"title":YZMsg(@"公会简介"),@"placeholder":YZMsg(@"请简单介绍下您的公会")},
                              ];
    MASViewAttribute *masTop = headImg.mas_bottom;
    for (int i=0; i<defaultArray.count; i++) {
        NSDictionary *subDic = defaultArray[i];
        UILabel *titleL = [[UILabel alloc]init];
        titleL.font = SYS_Font(15);
        titleL.textColor = [UIColor blackColor];//RGB_COLOR(@"#dcdcdc", 1);
        titleL.text = minstr([subDic valueForKey:@"title"]);
        [backView addSubview:titleL];
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView.mas_left).offset(15);
            make.top.equalTo(masTop).offset(18);
            if ([lagType isEqual:ZH_CN]) {
                make.width.mas_equalTo(80);
            }else{
                make.width.mas_equalTo(100);
            }
        }];
        if (i < 4) {
            MyTextField *tf = [[MyTextField alloc]init];
            tf.placeCol = RGB_COLOR(@"#dcdcdc", 1);
            tf.textColor =  [UIColor blackColor];//RGB_COLOR(@"#dcdcdc", 1);
            tf.tintColor = RGB_COLOR(@"#dcdcdc", 1);
            tf.placeholder = minstr([subDic valueForKey:@"placeholder"]);
            tf.font = SYS_Font(15);
            [backView addSubview:tf];
            switch (i) {
                case 0:{
                    _familyTF = tf;
                }break;
                case 1:{
                    _nameTF = tf;
                }break;
                case 2:{
                    _cardTF = tf;
                }break;
                case 3:{
                    _cutTF = tf;
                    _cutTF.keyboardType = UIKeyboardTypeNumberPad;
                }break;
                default:
                    break;
            }
            [tf mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(titleL.mas_right).offset(5);
                make.right.equalTo(backView.mas_right).offset(-15);
                make.height.mas_equalTo(37);
                make.centerY.equalTo(titleL);
            }];
//            UILabel *lineL = [[UILabel alloc]init];
//            lineL.backgroundColor = Line_Cor;
//            [backView addSubview:lineL];
//            [lineL mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.width.equalTo(backView.mas_width).offset(-30);
//                make.centerX.equalTo(backView);
//                make.height.mas_equalTo(1);
//                make.top.equalTo(titleL.mas_bottom).offset(18);
//            }];
            masTop = tf.mas_bottom;

        }else{
            MyTextView *tv = [[MyTextView alloc]init];
            tv.textColor =  [UIColor blackColor];//RGB_COLOR(@"#dcdcdc", 1);
            tv.tintColor = RGB_COLOR(@"#dcdcdc", 1);
            tv.placeholder =minstr([subDic valueForKey:@"placeholder"]);
            tv.placeholderColor =RGB_COLOR(@"#dcdcdc", 1);
            tv.font = SYS_Font(15);
            [backView addSubview:tv];
            _briefTF = tv;
            [tv mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(titleL.mas_right).offset(5);
                make.right.equalTo(backView.mas_right).offset(-15);
                make.height.mas_equalTo(37);
                make.top.equalTo(titleL).offset(-5);
            }];
            UILabel *lineL = [[UILabel alloc]init];
            lineL.backgroundColor = Line_Cor;
            [backView addSubview:lineL];
            [lineL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(backView.mas_width);
                make.centerX.equalTo(backView);
                make.height.mas_equalTo(3);
                make.top.equalTo(tv.mas_bottom).offset(18);
            }];
            masTop = lineL.mas_bottom;
        }
    }
   
    UILabel *tipsLb = [[UILabel alloc]init];
    tipsLb.font = [UIFont systemFontOfSize:14];
    tipsLb.text = YZMsg(@"证件图片");
    tipsLb.textColor = [UIColor blackColor];
    [backView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(masTop).offset(20);
        make.left.equalTo(backView.mas_left).offset(15);
    }];
    NSArray *certificatesA = @[YZMsg(@"手持证件正面照"),YZMsg(@"手持证件背面照")];
    NSArray *imgeArr = @[@"zj_1",@"zj_2"];
    CGFloat space = 20;
    CGFloat cerW = (_window_width - 20*4)/3;
    CGFloat cerH = cerW *75/100+10;
    MASViewAttribute *cerLeft = tipsLb.mas_right;
//    MASViewAttribute *cerTop = masTop;
    for (int i =0; i<certificatesA.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 3;
        btn.layer.masksToBounds = YES;
        [btn setBackgroundColor:RGBA(245,245,245, 1)];
        [btn addTarget:self action:@selector(clickCerBtn:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cerLeft).offset(space);
            make.top.equalTo(tipsLb.mas_top);
            make.width.mas_equalTo(cerW);
            make.height.mas_equalTo(cerH);
        }];
        
        UIImageView *img = [[UIImageView alloc]init];
        img.image =[UIImage imageNamed:imgeArr[i]];
        [btn addSubview:img];
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(btn);
            make.top.equalTo(btn).offset(5);
            make.width.equalTo(btn).multipliedBy(0.8);
            make.height.equalTo(btn).multipliedBy(0.7);
        }];

        UILabel *desL = [[UILabel alloc]init];
        desL.font = SYS_Font(12);
        desL.textColor = RGB_COLOR(@"@646464", 1);
        desL.text = certificatesA[i];
        [backView addSubview:desL];
        [desL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(btn);
            make.width.lessThanOrEqualTo(btn.mas_width).offset(20);
//            make.top.equalTo(btn.mas_bottom).offset(10);
            make.bottom.equalTo(btn.mas_bottom).offset(-2);
            make.height.mas_equalTo(18);
        }];
        switch (i) {
            case 0:{
                _cerFaceBtn = btn;
                img1 = img;
                title1 = desL;
            }break;
            case 1:{
                _cerBackBtn = btn;
                img2 =img;
                title2 = desL;
            }break;
            default:
                break;
        }

        cerLeft = btn.mas_right;
        masTop = desL.mas_bottom;
    }
    UILabel *familyLb = [[UILabel alloc]init];
    familyLb.font = [UIFont systemFontOfSize:14];
    familyLb.text = YZMsg(@"公会图片");
    familyLb.textColor = [UIColor blackColor];
    [backView addSubview:familyLb];
    [familyLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(masTop).offset(20);
        make.left.equalTo(backView.mas_left).offset(15);
    }];
    NSArray *certificatesA2 = @[YZMsg(@"公会图片")];
    MASViewAttribute *cerLeft2 = familyLb.mas_right;
//    MASViewAttribute *cerTop = masTop;
    for (int i =0; i<certificatesA2.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 3;
        btn.layer.masksToBounds = YES;
        [btn setBackgroundColor:RGBA(245,245,245, 1)];
        [btn addTarget:self action:@selector(clickCerBtn:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btn];
        _cerHandBtn = btn;
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cerLeft2).offset(space);
            make.top.equalTo(familyLb.mas_top);
            make.width.mas_equalTo(cerW);
            make.height.mas_equalTo(cerH);
        }];
        UIImageView *img = [[UIImageView alloc]init];
        img.image =[UIImage imageNamed:@"zj_3"];
        [btn addSubview:img];
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(btn);
            make.top.equalTo(btn).offset(5);
            make.width.equalTo(btn).multipliedBy(0.8);
            make.height.equalTo(btn).multipliedBy(0.7);
        }];

        UILabel *desL = [[UILabel alloc]init];
        desL.font = SYS_Font(12);
        desL.textColor = RGB_COLOR(@"@646464", 1);
        desL.text = certificatesA2[i];
        [btn addSubview:desL];
        [desL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(btn);
            make.width.lessThanOrEqualTo(btn.mas_width).offset(20);
//            make.top.equalTo(btn.mas_bottom).offset(10);
            make.bottom.equalTo(btn.mas_bottom).offset(-2);
            make.height.mas_equalTo(18);
        }];
        img3 =img;
        title3 = desL;

        cerLeft2 = btn.mas_right;
        masTop = desL.mas_bottom;
    }

    UIButton *subBtn = [UIButton buttonWithType:0];
//    [subBtn setBackgroundColor:normalColors];
    subBtn.layer.cornerRadius = 20;
    subBtn.layer.masksToBounds = YES;
    [subBtn setBackgroundImage:[UIImage imageNamed:@"btn_back_jz"] forState:0];
    [subBtn setTitle:YZMsg(@"提交申请")forState:0];
    subBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [subBtn setTitleColor:[UIColor whiteColor] forState:0];
    [subBtn addTarget:self action:@selector(subBtnClick) forControlEvents:UIControlEventTouchUpInside];

    [backView addSubview:subBtn];

    [subBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).multipliedBy(0.7);
        make.height.mas_equalTo(40);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(masTop).offset(20);
    }];
    masTop = subBtn.mas_bottom;
    backView.size = CGSizeMake(_window_width, _window_height+100);
    backScroll.contentSize = CGSizeMake(_window_width, backView.height);
}
-(void)subBtnClick{
    [self.view endEditing:YES];
    if (_familyTF.text.length <= 0) {
        [MBProgressHUD showError:YZMsg(@"请输入公会名称")];
        return;
    }
    if (_nameTF.text.length <=0 ) {
        [MBProgressHUD showError:YZMsg(@"请输入姓名")];
        return;
    }
    if (_cardTF.text.length <=0 ) {
        [MBProgressHUD showError:YZMsg(@"请输入身份证号码")];
        return;
    }
    ;
    if (_cutTF.text.length <=0 ) {
        [MBProgressHUD showError:YZMsg(@"请输入抽成比例")];
        return;
    }
    if (_briefTF.text.length <=0 ) {
        [MBProgressHUD showError:YZMsg(@"请输入公会简介")];
        return;
    }

    if (!_cerFaceImg || !_cerBackImg|| !_cerHandImg ) {
        [MBProgressHUD showError:YZMsg(@"请完善证件信息")];
        return;
    }
    WeakSelf;
    [[YBStorageManage shareManage]getCOSInfo:^(int code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == 0) {
                    [weakSelf startUploadCer];
            }
        });
    }];

}

-(void)clickCerBtn:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if (sender == _cerFaceBtn) {
        _upCerType = CerTypeFace;
    }else if (sender == _cerBackBtn){
        _upCerType = CerTypeBack;
    }else{
        _upCerType = CerTypeHand;
    }
    
    WeakSelf;
    RKActionSheet *sheet = [[RKActionSheet alloc]initWithTitle:@""];
    [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"相册") complete:^{
        //[weakSelf selectThumbWithType:UIImagePickerControllerSourceTypePhotoLibrary];
        [weakSelf selLocalPic];
    }];
    [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"拍照") complete:^{
        [weakSelf selectThumbWithType:UIImagePickerControllerSourceTypeCamera];
    }];
    [sheet addActionWithType:RKSheet_Cancle andTitle:YZMsg(@"取消") complete:^{
    }];
    [sheet showSheet];
    
}
- (void)selectThumbWithType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = type;
    imagePickerController.allowsEditing = NO;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    imagePickerController.modalPresentationStyle = 0;
    [[YBAppDelegate sharedAppDelegate].topViewController presentViewController:imagePickerController animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]){
        _selectedImg = YES;
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        switch (_upCerType) {
            case CerTypeFace:{
                img1.hidden = YES;
                title1.hidden = YES;
                _cerFaceImg = image;
                [_cerFaceBtn setImage:image forState:0];
            }break;
            case CerTypeBack:{
                img2.hidden = YES;
                title2.hidden = YES;

                _cerBackImg = image;
                [_cerBackBtn setImage:image forState:0];
            }break;
            case CerTypeHand:{
                img3.hidden = YES;
                title3.hidden = YES;

                _cerHandImg = image;
                [_cerHandBtn setImage:image forState:0];
            }break;
            default:
                break;
        }
        
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
    _selectedImg = YES;
    //先把图片转成NSData
    UIImage* image = photos[0];
    switch (_upCerType) {
        case CerTypeFace:{
            img1.hidden = YES;
            title1.hidden = YES;
            _cerFaceImg = image;
            [_cerFaceBtn setImage:image forState:0];
        }break;
        case CerTypeBack:{
            img2.hidden = YES;
            title2.hidden = YES;

            _cerBackImg = image;
            [_cerBackBtn setImage:image forState:0];
        }break;
        case CerTypeHand:{
            img3.hidden = YES;
            title3.hidden = YES;

            _cerHandImg = image;
            [_cerHandBtn setImage:image forState:0];
        }break;
        default:
            break;
    }
}

-(void)startUploadCer{
    [MBProgressHUD showMessage:@""];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    WeakSelf;
    //正面照
    if (_cerFaceImg) {
        dispatch_group_async(group, queue, ^{
            NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"_cerFace.png"];
            [[YBStorageManage shareManage]yb_storageImg:_cerFaceImg andName:imageName progress:^(CGFloat percent) {
                
            }complete:^(int code, NSString *key) {
                _cerFacePath = minstr(key);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    
    //反面照
    if (_cerBackImg) {
        dispatch_group_async(group, queue, ^{
            NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"_cerBack.png"];
            [[YBStorageManage shareManage]yb_storageImg:_cerBackImg andName:imageName progress:^(CGFloat percent) {
                
            }complete:^(int code, NSString *key) {
                _cerBackPath = minstr(key);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    
    //手持照
    if (_cerHandImg) {
        dispatch_group_async(group, queue, ^{
            NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"_cerHand.png"];
            [[YBStorageManage shareManage]yb_storageImg:_cerHandImg andName:imageName progress:^(CGFloat percent) {
                
            }complete:^(int code, NSString *key) {
                _cerHandPath = minstr(key);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf goResServer];
        });
        NSLog(@"任务完成执行");
    });

}
-(void)goResServer {

    NSDictionary *postDic = @{
        @"uid":[Config getOwnID],
        @"token":[Config getOwnToken],
        @"familyname":_familyTF.text,
        @"username":_nameTF.text,
        @"cardno":_cardTF.text,
        @"divide_family":_cutTF.text,
        @"briefing":_briefTF.text,
        @"apply_pos":_cerFacePath?_cerFacePath:@"",
        @"apply_side":_cerBackPath?_cerBackPath:@"",
        @"apply_map":_cerHandPath?_cerHandPath:@"",
    };
    
    [YBToolClass postNetworkWithUrl:@"Family.createFamily" andParameter:postDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:msg];
        if (code == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[YBAppDelegate sharedAppDelegate]popToRootViewController];
            });
        }

        } fail:^{
            [MBProgressHUD hideHUD];

        }];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end

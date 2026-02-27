//
//  recommendCell.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "recommendCell.h"
#import "TChatController.h"
#import "TConversationCell.h"
#import "TTextMessageCell.h"
#import "YBImManager.h"
@implementation recommendCell{
    UIView *priceView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(recommendModel *)model{
    _model = model;
    NSArray *arr = @[@"离线",@"勿扰",@"在聊",@"在线"];
    NSString *imgStr = [NSString stringWithFormat:@"状态-%@",arr[[_model.online intValue]]];
    _stateImgV.image = [UIImage imageNamed:getImagename(imgStr)];
    [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:_model.level_anchor]]];
    [_thumbImgV sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _nameL.text = _model.user_nickname;
    if (_model.typeArray.count > 0) {
        NSDictionary *dic =[_model.typeArray firstObject];
        _openTypeImgV.image = [UIImage imageNamed:minstr([dic valueForKey:@"icon"])];
        _openTypeL.text = minstr([dic valueForKey:@"content"]);
        if ([YBToolClass isUp]) {
            _openTypeL.text = YZMsg(@"查看更多TA的介绍");
        }
    }
    if (_model.isvideo) {
        _videoImgWidthC.constant = 12.0;
        _videoImgV.hidden = NO;
        if (_model.isvoice) {
            _audioImgV.hidden = NO;
        }else{
            _audioImgV.hidden = YES;
        }
    }else{
        _videoImgWidthC.constant = 0.0;
        _videoImgV.hidden = YES;
        if (_model.isvoice) {
            _audioImgV.hidden = NO;
        }else{
            _audioImgV.hidden = YES;
        }
    }
    if (_model.distance) {
        _distanceL.text = _model.distance;
    }else{
        _distanceL.text = @"";
    }
    if([model.can_sayhi isEqual:@"1"]){
        [_callBtn setImage:[UIImage imageNamed:getImagename(@"home_sayhi")] forState:0];
    }else{
        [_callBtn setImage:[UIImage imageNamed:@"home-通话"] forState:0];
        if (_model.isvideo || _model.isvoice) {
            _callBtn.hidden = NO;
        }else{
            _callBtn.hidden = YES;
        }
    }
}
- (IBAction)callBtnClick:(UIButton *)sender {
    if([_model.can_sayhi isEqual:@"1"]){
        [self getRandomSayhi];
    }else{
        if (self.callEvent) {
            self.callEvent(_model);
        }
    }
}
-(void)getRandomSayhi{
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"User.getRandomSayhi" andParameter:nil success:^(int code,id info,NSString *msg) {
        if (code == 0) {
            NSDictionary *infoA = [info firstObject];
            NSString *sayStr = minstr([infoA valueForKey:@"str"]);
            TTextMessageCellData *data = [[TTextMessageCellData alloc] init];
            data.head = TUIKitResource(@"default_head");
            data.content = sayStr;
            data.isSelf = YES;
            [[YBImManager shareInstance]sendV2ImMsg:data andReceiver:_model.userID complete:^(BOOL isSuccess, V2TIMMessage *sendMsg, NSString *desc) {
                if(isSuccess){
                    [weakSelf addFirstSayhiRecord];
                }else{
                    [MBProgressHUD showError:YZMsg(@"发送失败")];
                }
            }];
        }
    } fail:^{
    }];
}
-(void)addFirstSayhiRecord{
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"User.addFirstSayhiRecord" andParameter:@{@"touid":_model.userID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if(code == 0){
            [_callBtn setImage:[UIImage imageNamed:@"home-通话"] forState:0];
            if(weakSelf.changeHelloEvent){
                weakSelf.changeHelloEvent(_model);
            }
            [weakSelf getuserInfo];

        }
        } fail:^{
            
        }];
}
-(void)getuserInfo{
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":_model.userID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *_liveDic = [info firstObject];
            //消息
            TConversationCellData *data = [[TConversationCellData alloc] init];
            data.convId = minstr([_liveDic valueForKey:@"id"]);
            data.convType = TConv_Type_C2C;
            data.title = minstr([_liveDic valueForKey:@"user_nickname"]);
            data.userHeader = minstr([_liveDic valueForKey:@"avatar"]);
            data.userName = minstr([_liveDic valueForKey:@"user_nickname"]);
            data.level_anchor = minstr([_liveDic valueForKey:@"level_anchor"]);
            data.isauth = minstr([_liveDic valueForKey:@"isauth"]);
            data.isAtt = minstr([_liveDic valueForKey:@"isattent"]);
            data.isVIP = minstr([_liveDic valueForKey:@"isvip"]);
            data.isblack = minstr([_liveDic valueForKey:@"isblack"]);

            TChatController *chat = [[TChatController alloc] init];
            chat.conversation = data;
            [[YBAppDelegate sharedAppDelegate] pushViewController:chat animated:YES];
            
            
            [MBProgressHUD showError:YZMsg(@"您已喜欢Ta,可在“我的-喜欢”查看")];

        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
@end

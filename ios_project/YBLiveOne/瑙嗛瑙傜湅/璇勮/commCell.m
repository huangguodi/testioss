//
//  commCell.m
//  yunbaolive
//
//  Created by Boom on 2018/12/17.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "commCell.h"
#import "commDetailCell.h"
#import "detailmodel.h"
#import "TUIKit.h"
#import "RKActionSheet.h"

@implementation commCell{
    int page;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *iconTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userHeadTap)];
    [_iconImgView addGestureRecognizer:iconTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_replyTable addGestureRecognizer:longPress];
    
    self.authorLb.text = YZMsg(@"作者");
}
-(void)longPress:(UILongPressGestureRecognizer*)longPressGesture {
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPressGesture locationInView:_replyTable];
        NSIndexPath *currentIndexPath = [_replyTable indexPathForRowAtPoint:point];
        commDetailCell *cell;
        if (currentIndexPath) {
            cell = [_replyTable cellForRowAtIndexPath:currentIndexPath];
        }

//        cell.longPressView.backgroundColor = RGB_COLOR(@"#ffffff", 0.1);
        [self showActionSheet:currentIndexPath model:cell.model];
    }
    if (longPressGesture.state == UIGestureRecognizerStateChanged || longPressGesture.state == UIGestureRecognizerStateEnded) {
//        cell.longPressView.backgroundColor = UIColor.clearColor;
    }
    
}
-(void)showActionSheet:(NSIndexPath*)indexPath model:(detailmodel *)dModel{

    if ([self.delegate respondsToSelector:@selector(hideTextFieldRespond)]) {
        [self.delegate hideTextFieldRespond];
    }
    NSDictionary *subdic = _replyArray[indexPath.row];
    NSDictionary *userinfo = [subdic valueForKey:@"userinfo"];
    WeakSelf;
    RKActionSheet *sheet = [[RKActionSheet alloc]initWithTitle:@""];
    [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"复制") complete:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [NSString stringWithFormat:@"@%@:%@",dModel.user_nicename,dModel.content];
            [MBProgressHUD showError:YZMsg(@"复制成功")];
        });
    }];
    BOOL haveDel = NO;//[_model.ID  isEqual:[Config getOwnID]] || 
    if ([minstr([userinfo valueForKey:@"id"]) isEqual:[Config getOwnID]] ||[self.videoUserID isEqualToString:[Config getOwnID]]) {
        haveDel = YES;
        [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"删除") complete:^{
            [weakSelf delComments:subdic index:indexPath];
        }];
    }
        [sheet addActionWithType:RKSheet_Cancle andTitle:YZMsg(@"取消") complete:^{
        }];
        [sheet showSheet];
}
#pragma mark - 删除评论接口
-(void)delComments:(NSDictionary *)subdic index:(NSIndexPath *)indexPath{
    NSString *commentid = minstr([subdic valueForKey:@"id"]);
    NSDictionary *userinfo = [subdic valueForKey:@"userinfo"];
    NSString *commentUid = minstr([userinfo valueForKey:@"id"]);
    [MBProgressHUD showMessage:@""];
    
    if ([self.delegate respondsToSelector:@selector(deleteDetailCellDataCommentid:Commentuid:)]) {
        [self.delegate deleteDetailCellDataCommentid:commentid Commentuid:commentUid];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)userHeadTap{
//    otherUserMsgVC  *person = [[otherUserMsgVC alloc]init];
//    person.userID = _model.ID;
//    [[MXBADelegate sharedAppDelegate]pushViewController:person animated:YES];

}

- (void)setModel:(commentModel *)model{
    _model = model;
    NSLog(@"pinglunid-----:%@====userid:%@",_model.ID,self.videoUserID);
    NSLog(@"_replyArray=%@",_model.replyList);
    if ([_model.ID isEqual:self.videoUserID]) {
        _authorImg.hidden = NO;
        _authorLb.hidden = NO;
    }else{
        _authorImg.hidden = YES;
        _authorLb.hidden = YES;
    }
    _replyArray = [_model.replyList mutableCopy];
    [_iconImgView sd_setImageWithURL:[NSURL URLWithString:_model.avatar_thumb]];
    _nameL.text = _model.user_nicename;
//    _contentL.text = _model.content;
    _zanNumL.text = _model.likes;
    if ([_model.islike isEqual:@"1"]) {
        [_zanBtn setImage:[UIImage imageNamed:@"likecomment-click"] forState:0];
        _zanNumL.textColor =normalColors;// RGB_COLOR(@"#fa561f", 1);
    }else{
        [_zanBtn setImage:[UIImage imageNamed:@"likecomment"] forState:0];
        _zanNumL.textColor =RGBA(130, 130, 130, 1);// RGB(130, 130, 130);
    }
    //匹配表情文字
    NSArray *resultArr  = [[YBToolClass sharedInstance] machesWithPattern:emojiPattern andStr:_model.content];
    if (!resultArr) return;
    NSUInteger lengthDetail = 0;
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc]initWithString:_model.content];
    //遍历所有的result 取出range
    for (NSTextCheckingResult *result in resultArr) {
        //取出图片名
        NSString *imageName =   [_model.content substringWithRange:NSMakeRange(result.range.location, result.range.length)];
        NSLog(@"--------%@",imageName);
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        
        //取出图片
        NSString *path = [NSString stringWithFormat:@"emoji/%@", imageName];
        NSString *emojiPath = TUIKitFace(path);
        UIImage *emojiImage = [[[TUIKit sharedInstance] getConfig] getFaceFromCache:emojiPath];
        
        if ([lagType isEqual:EN]) {
            if ([imageName isEqual:@"[互粉]"] ||
                [imageName isEqual:@"[关注]"] ||
                [imageName isEqual:@"[粉]"] ||
                [imageName isEqual:@"[给力]"]) {
                imageName = [imageName stringByAppendingFormat:@"_en"];
                emojiImage = [UIImage imageNamed:imageName];
            }
        }
        
        NSAttributedString *imageString;
        if (emojiImage) {
            attach.image = emojiImage;
            attach.bounds = CGRectMake(0, -2, 15, 15);
            imageString =   [NSAttributedString attributedStringWithAttachment:attach];
        }else{
            imageString =   [[NSMutableAttributedString alloc]initWithString:imageName];
        }
        //图片附件的文本长度是1
        NSLog(@"emoj===%zd===size-w:%f==size-h:%f",imageString.length,imageString.size.width,imageString.size.height);
        NSUInteger length = attstr.length;
        NSRange newRange = NSMakeRange(result.range.location - lengthDetail, result.range.length);
        [attstr replaceCharactersInRange:newRange withAttributedString:imageString];
        
        lengthDetail += length - attstr.length;
    }
    NSAttributedString *dateStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@",_model.datetime] attributes:@{NSForegroundColorAttributeName:RGB_COLOR(@"#959697", 1),NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    [attstr appendAttributedString:dateStr];
    //更新到label上
    [_replyTable reloadData];

    _contentL.attributedText = attstr;

    if ([_model.replys intValue] > 0) {

        CGFloat HHHH = 0.0;
        for (NSDictionary *dic in _replyArray) {
            detailmodel *model = [[detailmodel alloc]initWithDic:dic];
            HHHH += model.rowH;
        }
        if ([_model.replys intValue] == 1) {
            _tableHeight.constant = HHHH;
        }else{
            if (!_replyBottomView) {
                _replyBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
                _replyBottomView.backgroundColor = [UIColor whiteColor];
                //回复
                _Reply_Button = [UIButton buttonWithType:0];
                _Reply_Button.backgroundColor = [UIColor clearColor];
                _Reply_Button.titleLabel.textAlignment = NSTextAlignmentLeft;
                _Reply_Button.titleLabel.font = [UIFont systemFontOfSize:12];
                [_Reply_Button addTarget:self action:@selector(makeReply) forControlEvents:UIControlEventTouchUpInside];
                
                NSString *moreStr = YZMsg(@"展开更多回复");
                NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc]initWithString:moreStr];
                [attstr addAttribute:NSForegroundColorAttributeName value:RGBA(200, 200, 200, 1) range:NSMakeRange(0, moreStr.length)];
                NSTextAttachment *attach = [[NSTextAttachment alloc] init];
                UIImage *image = [UIImage imageNamed:@"relpay_三角下.png"];
                NSAttributedString *imageString;
                if (image) {
                    attach.image = image;
                    attach.bounds = CGRectMake(0, -4, 15, 15);
                    imageString =   [NSAttributedString attributedStringWithAttachment:attach];
                    [attstr appendAttributedString:imageString];
                }
                [_Reply_Button setAttributedTitle:attstr forState:0];
                
                NSString *lessStr = YZMsg(@"收起");
                NSMutableAttributedString *attstr2 = [[NSMutableAttributedString alloc]initWithString:lessStr];
                [attstr2 addAttribute:NSForegroundColorAttributeName value:RGBA(200, 200, 200, 1) range:NSMakeRange(0, lessStr.length)];
                NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
                UIImage *image2 = [UIImage imageNamed:@"relpay_三角上.png"];
                NSAttributedString *imageString2;
                if (image2) {
                    attach2.image = image2;
                    attach2.bounds = CGRectMake(0, -4, 15, 15);
                    imageString2 =   [NSAttributedString attributedStringWithAttachment:attach2];
                    [attstr2 appendAttributedString:imageString2];
                }
                [_Reply_Button setAttributedTitle:attstr2 forState:UIControlStateSelected];
                [_replyBottomView addSubview:_Reply_Button];
                
                [_Reply_Button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.bottom.equalTo(_replyBottomView);
                }];
                
            }
            _replyTable.tableFooterView = _replyBottomView;
            if (_model.replyList.count % 20 != 0 && _model.replyList.count != 1) {
                _Reply_Button.selected = YES;
            }else{
                _Reply_Button.selected = NO;
            }
            _tableHeight.constant = HHHH+30;

        }

    }else{
        _tableHeight.constant = 0;
        _replyTable.tableFooterView = nil;
    }


}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _replyArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    commDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commDetailCELL"];
    if (!cell) {
        cell = [[commDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commDetailCell"];
    }
    cell.detailAuthorUid =self.videoUserID;
    detailmodel *model = [[detailmodel alloc]initWithDic:_replyArray[indexPath.row]];
    cell.model = model;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    detailmodel *model = [[detailmodel alloc]initWithDic:_replyArray[indexPath.row]];
    return model.rowH;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *subdic = _replyArray[indexPath.row];
    
    [self.delegate pushDetails:subdic];
}

- (void)makeReply{
    if (_Reply_Button.selected) {
        NSDictionary *dic = [_replyArray firstObject];
        [_replyArray removeAllObjects];
        [_replyArray addObject:dic];
        _model.replyList = _replyArray;
//        [_replyTable reloadData];
        _Reply_Button.selected = NO;
        [self.delegate reloadCurCell:_model andIndex:_curIndex andReplist:_replyArray];

    }else{
        if (_replyArray.count == 1) {
            page = 1;
        }else{
            page ++;
        }
        [self requestData];
    }
}
- (void)requestData{    
    [YBToolClass postNetworkWithUrl:@"Video.getReplys" andParameter:@{@"commentid":_model.parentid,@"p":@(page),@"uid":[Config getOwnID]} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSMutableArray *infos = [info mutableCopy];
            if (page == 1 && infos.count>0) {
                [infos removeObjectAtIndex:0];
            }
            [_replyArray addObjectsFromArray:infos];
            _model.replyList = _replyArray;
            [self.delegate reloadCurCell:_model andIndex:_curIndex andReplist:_replyArray];
            if (infos.count < 20) {
                _Reply_Button.selected = YES;
            }

        }else{
            [MBProgressHUD showError:msg];
        }
        } fail:^{
            
        }];
}
- (IBAction)zanBtnClick:(id)sender {

    if ([_model.ID isEqual:[Config getOwnID]]) {
        [MBProgressHUD showError:YZMsg(@"不能给自己的评论点赞")];
        
        return;
    }
    if ([[Config getOwnID] intValue] < 0) {
        //[self.delegate youkedianzan];
        return;
    }
    //_bigbtn.userInteractionEnabled = NO;
    
    [YBToolClass postNetworkWithUrl:@"Video.addCommentLike" andParameter:@{@"uid":[Config getOwnID],@"commentid":_model.parentid,@"token":[Config getOwnToken]} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            //动画
            dispatch_async(dispatch_get_main_queue(), ^{
                [_zanBtn.imageView.layer addAnimation:[YBToolClass bigToSmallRecovery] forKey:nil];
            });
            
            NSDictionary *infos = [info firstObject];
            NSString *islike = [NSString stringWithFormat:@"%@",[infos valueForKey:@"islike"]];
            NSString *likes = [NSString stringWithFormat:@"%@",[infos valueForKey:@"likes"]];
            
            [self.delegate makeLikeRloadList:_model.parentid andLikes:likes islike:islike];

        }else{
            [MBProgressHUD showError:msg];
        }
        } fail:^{
            
        }];
}

@end

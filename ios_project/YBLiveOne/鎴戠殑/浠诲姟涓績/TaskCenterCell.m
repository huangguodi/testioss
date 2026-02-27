//
//  TaskCenterCell.m
//  YBLiveOne
//
//  Created by yunbao01 on 2023/12/6.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "TaskCenterCell.h"


@interface TaskCenterCell ()
{
    UILabel *titleLb;
    UILabel *coinLb;
    UILabel *descLb;

}
@end

@implementation TaskCenterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        titleLb = [[UILabel alloc]init];
        titleLb.font = [UIFont boldSystemFontOfSize:14];
        titleLb.textColor = UIColor.blackColor;
        [self.contentView addSubview:titleLb];
        [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.top.equalTo(self.contentView.mas_top).offset(18);
        }];
        
        coinLb = [[UILabel alloc]init];
        coinLb.font = [UIFont systemFontOfSize:12];
        coinLb.textColor = normalColors;
        [self.contentView addSubview:coinLb];
        [coinLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(titleLb.mas_bottom);
            make.left.equalTo(titleLb.mas_right).offset(3);
        }];
        descLb = [[UILabel alloc]init];
        descLb.font = [UIFont systemFontOfSize:12];
        descLb.textColor = UIColor.grayColor;
        descLb.numberOfLines = 0;
        [self.contentView addSubview:descLb];
        [descLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLb.mas_bottom).offset(5);
            make.left.equalTo(titleLb.mas_left);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
        }];
        
        _statusBtn = [UIButton buttonWithType:0];
        [_statusBtn setBackgroundColor:normalColors];
        [_statusBtn setTitleColor:UIColor.whiteColor forState:0];
        _statusBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _statusBtn.layer.cornerRadius = 14;
        _statusBtn.layer.masksToBounds = YES;
        [_statusBtn addTarget:self action:@selector(statusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_statusBtn];
        [_statusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-16);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo(55);
            make.height.mas_equalTo(28);
            make.left.greaterThanOrEqualTo(descLb.mas_right).offset(10);
        }];

    }
    return self;
}
-(void)setDataDic:(NSDictionary *)dataDic
{
    _dataDic = dataDic;
    titleLb.text = minstr([dataDic valueForKey:@"title"]);
    coinLb.text = minstr([dataDic valueForKey:@"coin_str"]);
    descLb.text = minstr([dataDic valueForKey:@"desc_str"]);
}
-(void)statusBtnClick:(UIButton *)sender{
    if([sender.titleLabel.text isEqual:YZMsg(@"可领取")]){
        [YBToolClass postNetworkWithUrl:@"User.receiveTaskReward" andParameter:@{@"uid":[Config getOwnID],@"token":[Config getOwnToken],@"type":minstr([_dataDic valueForKey:@"sign"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                if([self.delegate respondsToSelector:@selector(reloadTaskList)]){
                    [self.delegate reloadTaskList];
                }
            }else{
                    [MBProgressHUD showError:msg];
                }
        } fail:^{
            
        }];

    }else{
        if([self.delegate respondsToSelector:@selector(taskStatusClick:)]){
            [self.delegate taskStatusClick:_dataDic];
        }
    }
}
@end

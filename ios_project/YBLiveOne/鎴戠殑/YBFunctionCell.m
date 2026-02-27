//
//  YBFunctionCell.m
//  yunbaolive
//
//  Created by ybRRR on 2021/4/2.
//  Copyright © 2021 cat. All rights reserved.
//

#import "YBFunctionCell.h"
//#import "FunctionCollectionViewCell.h"
@implementation YBFunctionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andListArr:(NSArray *)listar;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        listArr = [NSArray array];
        listar = listar;
        self.backgroundColor =RGBA(244, 245, 246,1);
        
        backView = [[UIView alloc]init];
        backView.backgroundColor = UIColor.whiteColor;
        backView.layer.cornerRadius = 10;
        backView.layer.masksToBounds = YES;
        [self.contentView addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.contentView.mas_width).offset(-30);
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
        }];
        
        
    }
    return self;
}
-(void)setDataDic:(NSArray *)dataDic
{

//    listArr = [dataDic valueForKey:@"list"];
    listArr = dataDic;

    [backView removeAllSubviews];
    
    titleLb = [[UILabel alloc]init];
    titleLb.font = [UIFont boldSystemFontOfSize:14];
    titleLb.textColor = [UIColor blackColor];
    titleLb.text = YZMsg(@"基本功能");
    [backView addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView.mas_left).offset(15);
        make.top.equalTo(backView.mas_top).offset(15);
        make.height.mas_equalTo(20);
    }];

    if (listArr == nil) {
        return;
    }
    MASViewAttribute *left_mas = backView.mas_left;
    MASViewAttribute *top_mas = titleLb.mas_bottom;

    CGFloat itemeSize = (_window_width-30)/4;

    for ( int i = 0; i < listArr.count; i ++) {
        NSString *thumbUrl = minstr([listArr[i] valueForKey:@"thumb"]);
        
        UIView *subView = [[UIView alloc]init];
        [backView addSubview:subView];
        [subView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(itemeSize);
            make.left.equalTo(left_mas);
            make.top.equalTo(top_mas);//.offset(40)
//            if (i+1 == listArr.count) {
//                make.bottom.equalTo(backView.mas_bottom);
//            }
        }];
        
        UIImageView *thumbimg = [[UIImageView alloc]init];
        thumbimg.contentMode = UIViewContentModeScaleAspectFill;
        [thumbimg sd_setImageWithURL:[NSURL URLWithString:thumbUrl]];
        [subView addSubview:thumbimg];
        [thumbimg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(36);
            make.centerX.equalTo(subView);
            make.centerY.equalTo(subView).offset(-7);
        }];

        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        [label setText:minstr([listArr[i]valueForKey:@"name"])];
        [subView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(thumbimg);
            make.width.lessThanOrEqualTo(subView.mas_width);
            make.top.equalTo(thumbimg.mas_bottom).offset(5);
            //make.height.mas_equalTo(15);
            make.bottom.equalTo(subView).offset(-15);
        }];
        
        if ((i+1)%4 == 0) {
            top_mas = subView.mas_bottom;
            left_mas = backView.mas_left;
        }else {
            left_mas = subView.mas_right;
        }
        
        UIButton *btn = [UIButton buttonWithType:0];
        btn.tag =10000+[[listArr[i] valueForKey:@"id"] intValue];
        [btn addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerX.centerY.equalTo(subView);
        }];
    }
}
-(void)functionBtnClick:(UIButton *)sender{
    NSInteger btntag = sender.tag;
    NSString * fuctionID =[NSString stringWithFormat:@"%ld", btntag-10000];
    for (NSDictionary *dic in listArr) {
        if ([minstr([dic valueForKey:@"id"]) isEqual:fuctionID]) {
            if ([self.delegate respondsToSelector:@selector(clickFunction:)]) {
                [self.delegate clickFunction:dic];
            }

        }
    }
}
- (UIColor*) randomColor{
    NSInteger r = arc4random() % 255;
    NSInteger g = arc4random() % 255;
    NSInteger b = arc4random() % 255;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}
@end

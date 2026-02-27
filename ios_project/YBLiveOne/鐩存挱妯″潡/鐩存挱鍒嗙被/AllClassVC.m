//
//  AllClassVC.m
//  YBLive
//
//  Created by ybRRR on 2022/5/31.
//  Copyright © 2022 cat. All rights reserved.
//

#import "AllClassVC.h"
#import "classVC.h"
@interface AllClassVC ()
{
    NSInteger count;
    NSArray *classArray;

}
@end

@implementation AllClassVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = YZMsg(@"全部分类");
    [self creatUI];
}

- (void)creatUI{
    NSMutableArray *allArr = [NSMutableArray array];
    [allArr addObjectsFromArray:[common getLiveClass]];

    classArray =allArr;// [common liveclass];
    if (classArray.count % 5 == 0) {
        count = classArray.count/5;
    }else{
        count = classArray.count / 5 +1;
    }
    CGFloat speace = (_window_width/6)/6;
    for (int i = 0; i < classArray.count; i++) {
        
        UIButton *button = [UIButton buttonWithType:0];
        button.frame = CGRectMake(speace + i%5*(_window_width/6+speace) , 64+statusbarHeight+2.5 + (i/5)*_window_width/5.5, _window_width/6, _window_width/5.5);
        button.tag = i + 3000;
        [button addTarget:self action:@selector(liveClassBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(button.width*0.15, button.width*0.05, button.width*0.7, button.width*0.7)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([classArray[i] valueForKey:@"thumb"])] placeholderImage:[UIImage imageNamed:@"live_all"]];
        imgView.contentMode = UIViewContentModeScaleAspectFit;

        [button addSubview:imgView];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imgView.bottom, button.width, button.height-(imgView.bottom))];
        label.textColor = RGB_COLOR(@"#636363", 1);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        [label setText:minstr([classArray[i] valueForKey:@"name"])];
        [button addSubview:label];

    }
}

- (void)liveClassBtnClick:(UIButton *)sender{
    NSDictionary *dic = classArray[sender.tag-3000];
    classVC *class = [[classVC alloc]init];
    class.titleStr = minstr([dic valueForKey:@"name"]);
    class.classID = minstr([dic valueForKey:@"id"]);
    [[YBAppDelegate sharedAppDelegate] pushViewController:class animated:YES];
}


@end

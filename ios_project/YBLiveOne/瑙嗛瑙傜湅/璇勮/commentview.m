//
//  commentview.m
//  iphoneLive
//
//  Created by 王敏欣 on 2017/8/5.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "commentview.h"
//#import "commentcell.h"
#import "commentModel.h"
//#import "SelPeopleV.h"
#import <HPGrowingTextView/HPGrowingTextView.h>
//#import "twEmojiView.h"
#import "commCell.h"
#import "RKActionSheet.h"
#import "TFaceView.h"
#import "TUIKit.h"
#import "TFaceCell.h"

@interface commentview ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,commCellDelegate,HPGrowingTextViewDelegate,TFaceViewDelegate>//twEmojiViewDelegate
{
    int count;//下拉次数
    MJRefreshBackNormalFooter *footer;
    int ispush;
    
    BOOL isReply;//判断是否是回复
    UILabel *tableviewLine;
    UIView *tableheader;
    UIButton *finish;
    CGFloat _oldOffset;
    
//    SelPeopleV * _selV;
    NSMutableArray *_atArray;                                        //@用户的uid和uname数组
//    twEmojiView *_emojiV;
    UILabel *nothingLabel;
}
@property(nonatomic,strong)UILabel *allCommentLabels;//显示全部评论
@property(nonatomic,copy)NSString *videoid;//视频id
@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)HPGrowingTextView *textField;//评论框
@property(nonatomic,strong)UIView *toolBar;//评论困底部view
@property(nonatomic,strong)NSMutableArray *itemsarray;//评论列表
//@property(nonatomic,strong)NSMutableArray *modelarray;//评论模型
@property(nonatomic,copy)NSString *parentid;//回复的评论ID
@property(nonatomic,copy)NSString *commentid;//回复的评论commentid
@property(nonatomic,copy)NSString *touid;//回复的评论UID
@property(nonatomic,copy)NSString *hostid;//发布视频的人的id

@property (nonatomic, strong) TFaceView *emojiV;

@end
@implementation commentview
-(void)dealloc{
    NSLog(@"dealloc");
}
- (void)reloadCurCell:(commentModel *)model andIndex:(NSIndexPath *)curIndex andReplist:(NSArray *)list{
    for (int i = 0; i < _itemsarray.count; i++) {
        NSMutableDictionary *muDic = _itemsarray[i];
        if ([minstr([muDic valueForKey:@"id"]) isEqual:model.parentid]) {
            [muDic setObject:list forKey:@"replylist"];
            break;
        }
    }
    [_tableview reloadRowsAtIndexPaths:@[curIndex] withRowAnimation:UITableViewRowAnimationNone];
}
//每次点击 获取最新评论列表
-(void)reloaddata:(NSString *)from{
    
    count+=1;
    _textField.text = @"";
    _textField.placeholder = YZMsg(@"说点什么...");
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Video.getComments" andParameter:@{@"videoid":_videoid,@"p":@(count),@"uid":[Config getOwnID]} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            //隐藏评论加载中
            [PublicView hideCommenting:weakSelf.tableview];
            NSDictionary *infos = [info firstObject];
            NSArray *commentlist = [infos valueForKey:@"commentlist"];
            
            int allcomments = [[NSString stringWithFormat:@"%@",[infos valueForKey:@"comments"]] intValue];
            weakSelf.allCommentLabels.text = [NSString stringWithFormat:@"%d %@",allcomments,YZMsg(@"评论")];
            self.talkCount([NSString stringWithFormat:@"%@",[infos valueForKey:@"comments"]] );
            if (count == 1) {
                [_itemsarray removeAllObjects];
            }
            for (NSDictionary *dic in commentlist) {
                [_itemsarray addObject:[dic mutableCopy]];
            }
            if (_itemsarray.count == 0) {
                nothingLabel.hidden = NO;
            }else{
                nothingLabel.hidden = YES;
            }
            if (commentlist.count == 0) {
                [weakSelf.tableview.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakSelf.tableview.mj_footer endRefreshing];
            }
            [_tableview.mj_header endRefreshing];

            [weakSelf.tableview reloadData];

        }else{
            [MBProgressHUD showError:msg];
        }
        } fail:^{
            [_tableview.mj_header endRefreshing];
            [weakSelf.tableview.mj_footer endRefreshing];

        }];
    
}
-(instancetype)initWithFrame:(CGRect)frame hide:(commectblock)hide andvideoid:(NSString *)videoid andhostid:(NSString *)hostids count:(int)allcomments talkCount:(commectblock)talk detail:(commectblock)detail youke:(commectblock)youkedenglu andFrom:(NSString *)from{
    self = [super initWithFrame:frame];
    if (self) {
        _atArray = [NSMutableArray array];

        _fromWhere = from;
        _oldOffset = 0;
         ispush = 0;//判断发消息的时候 数组滚动最上面
         count = 0;//上拉加载次数
        _parentid = @"0";
        _commentid = @"0";
        isReply = NO;//判断回复
        self.talkCount = talk;
        self.hide = hide;//点击隐藏事件
        _videoid = videoid;//获取视频id
        _hostid = hostids;
        _touid = hostids;
        _pushDetail = detail;
        _youkedenglu = youkedenglu;
        _itemsarray = [NSMutableArray array];
//        _modelarray = [NSMutableArray array];
        
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0,_window_height - 50-ShowDiff, _window_width, 50+ShowDiff)];
        _toolBar.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);//RGB(248, 248, 248);
        
        //_toolBar顶部横线 和 顶部 view分割开
        UILabel *lineso = [[UILabel alloc]initWithFrame:CGRectMake(0,0,_window_width,1)];
        lineso.backgroundColor = Line_Cor;//[UIColor groupTableViewBackgroundColor];
        [_toolBar addSubview:lineso];
        
        //设置输入框
        UIView *vc  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        vc.backgroundColor = [UIColor clearColor];
        _textField = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(10,8, _window_width - 68, 34)];
        _textField.layer.masksToBounds = YES;
        _textField.layer.cornerRadius = 17;
        _textField.font = SYS_Font(16);
        _textField.placeholder = YZMsg(@"说点什么...");
        _textField.textColor = GrayText;
        _textField.placeholderColor = GrayText;
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeySend;
        _textField.enablesReturnKeyAutomatically = YES;
        
        _textField.internalTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingHead;
        _textField.internalTextView.textContainer.maximumNumberOfLines = 1;
        
        /**
         * 由于 _textField 设置了contentInset 后有色差，在_textField后添
         * 加一个背景view并把_textField设置clearColor
         */
        _textField.contentInset = UIEdgeInsetsMake(2, 10, 2, 10);
        _textField.backgroundColor = [UIColor clearColor];
        UIView *tv_bg = [[UIView alloc]initWithFrame:_textField.frame];
        tv_bg.backgroundColor = [UIColor whiteColor];
        tv_bg.layer.masksToBounds = YES;
        tv_bg.layer.cornerRadius = _textField.layer.cornerRadius;
        [_toolBar addSubview:tv_bg];
        [_toolBar addSubview:_textField];
        
        //发送按钮
        finish = [UIButton buttonWithType:0];
        finish.frame = CGRectMake(_window_width - 44,8,34,34);
        [finish setImage:[UIImage imageNamed:@"chat_face.png"] forState:0];
        [finish setImage:[UIImage imageNamed:@"chat_keyboard"] forState:UIControlStateSelected];
        [finish addTarget:self action:@selector(atFrends) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:finish];
        
        tableheader = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height*0.3 , _window_width,50)];
        tableheader.layer.masksToBounds = YES;
        tableheader.layer.cornerRadius = 10;
        tableheader.backgroundColor = [UIColor whiteColor];
        
        //显示评论的数量
        _allCommentLabels = [[UILabel alloc]initWithFrame:CGRectMake(20,0,_window_width/2,50)];
        _allCommentLabels.textColor = RGB_COLOR(@"#333333", 1);
        _allCommentLabels.text = [NSString stringWithFormat:@"%d %@",allcomments,YZMsg(@"评论")];
        _allCommentLabels.font = [UIFont systemFontOfSize:15];
        [tableheader addSubview:_allCommentLabels];
        
        //关闭按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(_window_width - 45,5,40,40);
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btn.imageEdgeInsets = UIEdgeInsetsMake(12.5,12.5,12.5,12.5);
        [btn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(hideself) forControlEvents:UIControlEventTouchUpInside];
        [tableheader addSubview:btn];
        
        //tableview顶部横线 和 顶部 view分割开
        UILabel *liness = [[UILabel alloc]initWithFrame:CGRectMake(0,49,_window_width,1)];
        liness.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);//[UIColor groupTableViewBackgroundColor];
        [tableheader addSubview:liness];
        
        CGRect tabFrame ;
        if ([from isEqual:@"消息事件"]) {
            tabFrame = CGRectMake(0, 20+statusbarHeight, _window_width, _window_height-ShowDiff-20-statusbarHeight);
        }else {
            tabFrame = CGRectMake(0, _window_height*0.3, _window_width, _window_height*0.7 - 50-ShowDiff);
        }
        _tableview = [[UITableView alloc]initWithFrame:tabFrame];
        _tableview.delegate   = self;
        _tableview.dataSource = self;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.backgroundColor = Black_Cor;//RGB(248, 248, 248);
        _tableview.layer.masksToBounds = YES;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.estimatedRowHeight = 80.0;
        _tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            count = 0;
            [self reloaddata:from];
        }];
        UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, _tableview.bottom-12, _window_width, 15)];
        spaceView.backgroundColor = _tableview.backgroundColor;
        [self addSubview:spaceView];
        [self addSubview:_tableview];
        [self addSubview:_toolBar];
        nothingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _tableview.height/2-10, _window_width, 20)];
        nothingLabel.font = [UIFont systemFontOfSize:13];
        nothingLabel.text = YZMsg(@"暂无评论，快来抢沙发吧");
        nothingLabel.textColor = RGB_COLOR(@"#969696", 1);
        nothingLabel.textAlignment = NSTextAlignmentCenter;
        nothingLabel.hidden = YES;
        [_tableview addSubview:nothingLabel];
        //tableview顶部横线 和 顶部 view分割开
        tableviewLine = [[UILabel alloc]initWithFrame:CGRectMake(0, _window_height*0.3 + 49,_window_width,1)];
        tableviewLine.backgroundColor = Line_Cor;//[UIColor colorWithRed:198/255.0 green:198/255.0 blue:198/255.0 alpha:1];
        //[self addSubview:tableviewLine];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        //评论加载中
        [PublicView showCommenting:_tableview];
        
        [self reloaddata:from];
        footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(reloaddata:)];
        [footer setTitle:YZMsg(@"评论加载中...") forState:MJRefreshStateRefreshing];
        [footer setTitle:YZMsg(@"没有更多了哦~") forState:MJRefreshStateNoMoreData];
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        footer.stateLabel.font = [UIFont systemFontOfSize:15.0f];
        footer.automaticallyHidden = YES;
        self.tableview.mj_footer = footer;
        
        //添加表情
        if(!_emojiV){
            _emojiV = [[TFaceView alloc] initWithFrame:CGRectMake(0, _window_height, _window_width, TFaceView_Height)];
            _emojiV.delegate = self;
            [_emojiV setData:[[TUIKit sharedInstance] getConfig].faceGroups];
            [self  addSubview:_emojiV];
            
        }
        UIButton *sendBtn= [UIButton buttonWithType:0];
        sendBtn.frame = CGRectMake(_emojiV.width-80, _emojiV.height-30, 60, 30);
        [sendBtn setBackgroundColor:normalColors];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:0];
        [sendBtn setTitle:YZMsg(@"发送") forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        sendBtn.layer.cornerRadius = 15;
        sendBtn.layer.masksToBounds = YES;
        [sendBtn addTarget:self action:@selector(pushmessage) forControlEvents:UIControlEventTouchUpInside];
        [_emojiV addSubview:sendBtn];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_tableview addGestureRecognizer:longPress];

        //commectdetails 页面传过来的 点赞
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"likesnums" object:nil];
        //commectdetails 页面传过来的 回复总数
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadcomments:) name:@"commentnums" object:nil];
        
    
        
    }
    return self;
}
-(void)longPress:(UILongPressGestureRecognizer*)longPressGesture {
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPressGesture locationInView:_tableview];
        NSIndexPath *currentIndexPath = [_tableview indexPathForRowAtPoint:point];
        commCell *cell;
        if (currentIndexPath) {
            cell = [_tableview cellForRowAtIndexPath:currentIndexPath];
        }

//        cell.longPressView.backgroundColor = RGB_COLOR(@"#ffffff", 0.1);
        [self showActionSheet:currentIndexPath model:cell.model];
    }
    if (longPressGesture.state == UIGestureRecognizerStateChanged || longPressGesture.state == UIGestureRecognizerStateEnded) {
//        cell.longPressView.backgroundColor = UIColor.clearColor;
    }
    
}
-(void)showActionSheet:(NSIndexPath*)indexPath model:(commentModel *)cModel{
    [_textField resignFirstResponder];

    NSDictionary *subdic = _itemsarray[indexPath.row];
    NSDictionary *userinfo = [subdic valueForKey:@"userinfo"];
    WeakSelf;
    RKActionSheet *sheet = [[RKActionSheet alloc]initWithTitle:@""];
    [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"复制") complete:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [NSString stringWithFormat:@"@%@:%@",cModel.user_nicename,cModel.content];
            [MBProgressHUD showError:YZMsg(@"复制成功")];
        });
    }];
    if ([_hostid isEqual:[Config getOwnID]] || [minstr([userinfo valueForKey:@"id"]) isEqual:[Config getOwnID]] ||[minstr([subdic valueForKey:@"touid"]) isEqual:[Config  getOwnID]]) {
        [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"删除") complete:^{
            [weakSelf delComments:subdic index:indexPath];
        }];
    }
    [sheet addActionWithType:RKSheet_Cancle andTitle:YZMsg(@"取消") complete:^{
    }];
    [sheet showSheet];
    
}
-(void)hideTextFieldRespond
{
    [_textField resignFirstResponder];
}
#pragma mark - 删除评论接口
-(void)delComments:(NSDictionary *)subdic index:(NSIndexPath *)indexPath{
    NSString *commentid = minstr([subdic valueForKey:@"id"]);
    NSDictionary *userinfo = [subdic valueForKey:@"userinfo"];
    NSString *commentUid = minstr([userinfo valueForKey:@"id"]);
    [MBProgressHUD showMessage:@""];
    NSDictionary *dic = @{
                          @"uid":[Config getOwnID],
                          @"token":[Config getOwnToken],
                          @"videoid":_videoid,
                          @"commentid":commentid,
                          @"commentuid":commentUid
                          };
    
    [YBToolClass postNetworkWithUrl:@"Video.delComments" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:msg];
        if (code == 0) {
            count = 0;
            [self reloaddata:@""];
        }

        } fail:^{
            [MBProgressHUD hideHUD];

        }];
}
-(void)deleteDetailCellDataCommentid:(NSString *)commentid Commentuid:(NSString *)commentuid
{
    NSDictionary *dic = @{
                          @"uid":[Config getOwnID],
                          @"token":[Config getOwnToken],
                          @"videoid":_videoid,
                          @"commentid":commentid,
                          @"commentuid":commentuid
                          };
    [YBToolClass postNetworkWithUrl:@"Video.delComments" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
            if (code == 0) {
                count = 0;
                [self reloaddata:@""];
            }
        } fail:^{
            [MBProgressHUD hideHUD];

        }];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:_tableview] ||
        [touch.view isDescendantOfView:tableheader]) {
        return NO;
    }
    return YES;
}

#pragma mark - 召唤好友
-(void)atFrends {
    finish.selected = !finish.selected;
    if (!finish.selected) {
        [_textField becomeFirstResponder];
    }else{
        [_textField resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            _emojiV.frame = CGRectMake(0, _window_height - (EmojiHeight+ShowDiff), _window_width, EmojiHeight+ShowDiff);
            _toolBar.frame = CGRectMake(0, _emojiV.y - 50, _window_width, 50);
            
        }];
    }
}
#pragma mark - 输入框代理事件
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    _textField.height = height;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    [_textField resignFirstResponder];
    finish.selected = NO;
    [self pushmessage];
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    finish.selected = NO;
    if ([text isEqualToString:@""]) {
        NSRange selectRange = growingTextView.selectedRange;
        if (selectRange.length > 0) {
            //用户长按选择文本时不处理
            return YES;
        }
        
        // 判断删除的是一个@中间的字符就整体删除
        NSMutableString *string = [NSMutableString stringWithString:growingTextView.text];
        NSArray *matches = [self findAllAt];
        
        BOOL inAt = NO;
        NSInteger index = range.location;
        for (NSTextCheckingResult *match in matches) {
            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
            if (NSLocationInRange(range.location, newRange)) {
                inAt = YES;
                index = match.range.location;
                [string replaceCharactersInRange:match.range withString:@""];
                break;
            }
        }
        
        if (inAt) {
            growingTextView.text = string;
            growingTextView.selectedRange = NSMakeRange(index, 0);
            return NO;
        }
    }
    
    //判断是回车键就发送出去
    if ([text isEqualToString:@"\n"]) {
        [self pushmessage];
        return NO;
    }
    
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    UITextRange *selectedRange = growingTextView.internalTextView.markedTextRange;
    NSString *newText = [growingTextView.internalTextView textInRange:selectedRange];
    
    if (newText.length < 1) {
        // 高亮输入框中的@
        UITextView *textView = _textField.internalTextView;
        NSRange range = textView.selectedRange;
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:textView.text              attributes:@{NSForegroundColorAttributeName:GrayText,NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        
        NSArray *matches = [self findAllAt];
        
        for (NSTextCheckingResult *match in matches) {
            [string addAttribute:NSForegroundColorAttributeName value:AtCol range:NSMakeRange(match.range.location, match.range.length - 1)];
        }
        
        textView.attributedText = string;
        textView.selectedRange = range;
    }
    
    if (growingTextView.text.length >0) {
        NSString *theLast = [growingTextView.text substringFromIndex:[growingTextView.text length]-1];
        if ([theLast isEqual:@"@"]) {
            //去掉手动输入的  @
            NSString *end_str = [growingTextView.text substringToIndex:growingTextView.text.length-1];
            _textField.text = end_str;
            [self atFrends];
        }
    }
    
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView {
    // 光标不能点落在@词中间
    NSRange range = growingTextView.selectedRange;
    if (range.length > 0) {
        // 选择文本时可以
        return;
    }
    
    NSArray *matches = [self findAllAt];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
        if (NSLocationInRange(range.location, newRange)) {
            growingTextView.internalTextView.selectedRange = NSMakeRange(match.range.location + match.range.length, 0);
            break;
        }
    }
}

#pragma mark - Private
- (NSArray<NSTextCheckingResult *> *)findAllAt {
    // 找到文本中所有的@
    NSString *string = _textField.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return matches;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self hideself];
}
-(void)hideself{
    self.hide(@"1");
    [self endEditing:YES];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     [self.tableview deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *subdic = _itemsarray[indexPath.row];
    NSDictionary *userinfo = [subdic valueForKey:@"userinfo"];

    _touid = [NSString stringWithFormat:@"%@",[userinfo valueForKey:@"id"]];
    if ([_touid isEqual:[Config getOwnID]]) {
        return;
    }

    [_textField becomeFirstResponder];
    finish.selected = NO;
    NSString *path = [NSString stringWithFormat:@"%@:%@",YZMsg(@"回复给"),[userinfo valueForKey:@"user_nickname"]];
    _textField.placeholder = path;
    _parentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];
    _commentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"commentid"]];
    isReply = YES;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.itemsarray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableview deselectRowAtIndexPath:indexPath animated:NO];
    commCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"commCell" owner:nil options:nil] lastObject];
    }
    cell.videoUserID = _hostid;
    cell.model = [[commentModel alloc]initWithDic:_itemsarray[indexPath.row]];
    cell.delegate = self;
    cell.curIndex = indexPath;
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return tableheader;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
//刷新评论数量
-(void)getNewCount:(int)counts{
     _allCommentLabels.text = [NSString stringWithFormat:@"%d %@",counts,YZMsg(@"评论")];
}
-(void)reloadcomments:(NSNotification *)ns{
    NSDictionary *subdicsss = [ns userInfo];
    //904
    BOOL isLike = NO;
    int numbers = 0;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (int i=0; i<_itemsarray.count; i++) {
        NSDictionary *subdic = _itemsarray[i];
        
        NSString *parentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];
        NSString *myparentid = [NSString stringWithFormat:@"%@",[subdicsss valueForKey:@"commentid"]];
        if ([parentid isEqual:myparentid]) {
            dic = [NSMutableDictionary dictionaryWithDictionary:subdic];
            numbers = i;
            isLike = YES;
            break;
        }
    }
    if (isLike == YES) {
        [_itemsarray removeObject:dic];
        [dic setObject:[subdicsss valueForKey:@"commentnums"] forKey:@"replys"];
        [_itemsarray insertObject:dic atIndex:(NSUInteger)numbers];
        [self.tableview reloadData];
    }
    
    
}
-(void)pushmessage{
    if ([[Config getOwnID] intValue] < 0) {
        [_textField resignFirstResponder];
        self.youkedenglu(nil);
//        [[YBToolClass sharedInstance]waringLogin];
        return;
    }
    
    
    /*
     parentid  回复的评论ID
     commentid 回复的评论commentid
     touid     回复的评论UID
     如果只是评论 这三个传0
     */
    if (_textField.text.length == 0 || _textField.text == NULL || _textField.text == nil || [_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [MBProgressHUD showError:YZMsg(@"请添加内容后再尝试")];
        return;
    }
     NSString *sendtouid = [NSString stringWithFormat:@"%@",_touid];
     NSString *sendcommentid = [NSString stringWithFormat:@"%@",_commentid];
     NSString *sendparentid = [NSString stringWithFormat:@"%@",_parentid];
     NSString *path = [NSString stringWithFormat:@"%@",_textField.text];
    
    [self hideself];
    [self endEditing:YES];
    
    NSString *at_json = @"";
    //转json、去除空格、回车
    if (_atArray.count>0) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_atArray options:NSJSONWritingPrettyPrinted error:nil];
        at_json = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        at_json = [at_json stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        at_json = [at_json stringByReplacingOccurrencesOfString:@" " withString:@""];
        at_json = [at_json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    WeakSelf;
    NSDictionary *parDic = @{@"videoid":_videoid,@"content":path,@"touid":sendtouid,@"commentid":sendcommentid,@"parentid":sendparentid,@"at_info":at_json};
    [YBToolClass postNetworkWithUrl:@"Video.setComment" andParameter:parDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                _textField.text = @"";
                _textField.placeholder = YZMsg(@"说点什么...");
                //论完后 把状态清零
                _touid = _hostid;
                _parentid = @"0";
                _commentid = @"0";
                [MBProgressHUD showError:YZMsg(@"评论成功")];
                [_atArray removeAllObjects];
                NSDictionary *infos = [info firstObject];
                //刷新评论数
                int allcomments = [[NSString stringWithFormat:@"%@",[infos valueForKey:@"comments"]] intValue];
                weakSelf.allCommentLabels.text = [NSString stringWithFormat:@"%d %@",allcomments,YZMsg(@"评论")];
                self.talkCount([NSString stringWithFormat:@"%@",[infos valueForKey:@"comments"]] );

            }else{
                [MBProgressHUD showError:msg];

            }
        } fail:^{
            
        }];
}
#pragma mark -- 获取键盘高度
- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.origin.y;
    CGFloat yyyy = keyboardRect.size.height;
    _toolBar.frame = CGRectMake(0, height - 50, _window_width, 50);
    //消息事件 tableview 全屏不处理frame
    if (![_fromWhere isEqual:@"消息事件"]) {
        self.tableview.frame = CGRectMake(0, _window_height*0.3 + 50 - yyyy/2, _window_width, _window_height*0.7 - 84-statusbarHeight);
    }
    _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);

}
- (void)keyboardWillHide:(NSNotification *)aNotification {
    WeakSelf;
    [UIView animateWithDuration:0.1 animations:^{
       weakSelf.toolBar.frame = CGRectMake(0, _window_height - 50-statusbarHeight, _window_width, 50+statusbarHeight);
        _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);

    }];
    
     //消息事件 tableview 全屏不处理frame
    if (![_fromWhere isEqual:@"消息事件"]) {
        self.tableview.frame = CGRectMake(0, _window_height*0.3 + 50, _window_width, _window_height*0.7 - 84-statusbarHeight);
    }
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [_textField resignFirstResponder];
}
#pragma mark ==faceDelegate===
- (void)faceViewDidBackDelete:(TFaceView *)faceView
{
    [_textField.internalTextView deleteBackward];
}
- (void)faceView:(TFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFaceGroup *group = [[TUIKit sharedInstance] getConfig].faceGroups[indexPath.section];
    TFaceCellData *face = group.faces[indexPath.row];
    [_textField.internalTextView insertText:face.name];
}

#pragma mark cell代理方法
//这个地方找到点赞的字典，在数组中删除再重新插入 处理点赞
-(void)makeLikeRloadList:(NSString *)commectid andLikes:(NSString *)likes islike:(NSString *)islike{

    int numbers = 0;
    for (int i=0; i<_itemsarray.count; i++) {
        NSMutableDictionary *subdic = _itemsarray[i];
        NSString *parentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];
        if ([parentid isEqual:commectid]) {
            [subdic setObject:likes forKey:@"likes"];
            [subdic setObject:islike forKey:@"islike"];

            numbers = i;
            break;
        }
    }
    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numbers inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)reload:(NSNotification *)ns{
    NSDictionary *subdicsss = [ns userInfo];
    //904
    BOOL isLike = NO;
    int numbers = 0;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (int i=0; i<_itemsarray.count; i++) {
        NSDictionary *subdic = _itemsarray[i];
        NSString *parentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];
        NSString *myparentid = [NSString stringWithFormat:@"%@",[subdicsss valueForKey:@"commentid"]];
        if ([parentid isEqual:myparentid]) {
            dic = [NSMutableDictionary dictionaryWithDictionary:subdic];
            numbers = i;
            isLike = YES;
            break;
        }
    }
    if (isLike == YES) {
        [_itemsarray removeObject:dic];
        [dic setObject:[subdicsss valueForKey:@"likes"] forKey:@"likes"];
        [dic setObject:[subdicsss valueForKey:@"islike"] forKey:@"islike"];
        [_itemsarray insertObject:dic atIndex:(NSUInteger)numbers];
        [self.tableview reloadData];
    }
}
-(void)pushDetails:(NSDictionary *)commentdic{
    NSDictionary *userinfo = [commentdic valueForKey:@"userinfo"];

    _touid = [NSString stringWithFormat:@"%@",[userinfo valueForKey:@"id"]];
    if ([_touid isEqual:[Config getOwnID]]) {
        return;
    }
    [_textField becomeFirstResponder];
    NSString *path = [NSString stringWithFormat:@"%@:%@",YZMsg(@"回复给"),[userinfo valueForKey:@"user_nickname"]];
    _textField.placeholder = path;
    _parentid = [NSString stringWithFormat:@"%@",[commentdic valueForKey:@"id"]];
    _commentid = [NSString stringWithFormat:@"%@",[commentdic valueForKey:@"commentid"]];
    isReply = YES;
}

#pragma mark - Emoji 代理
-(void)sendimage:(NSString *)str {
    if ([str isEqual:@"msg_del"]) {
        [_textField.internalTextView deleteBackward];
    }else {
        [_textField.internalTextView insertText:str];
    
    }
}
-(void)clickSendEmojiBtn {
    
    //    [self prepareTextMessage:_toolBarContainer.toolbar.textView.text];
    [self pushmessage];
}


@end

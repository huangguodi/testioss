//
//  TMessageCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImSDK_Plus/ImSDK_Plus.h>
#import "YBMessageManager.h"

typedef void (^TDownloadProgress)(NSInteger curSize, NSInteger totalSize);
typedef void (^TDownloadResponse)(int code, NSString *desc, NSString *path);

typedef NS_ENUM(NSUInteger, TMsgStatus) {
    Msg_Status_Sending = 1,  ///< 消息发送中,
    Msg_Status_Succ = 2,  ///< 消息发送成功,
    Msg_Status_Fail = 3,  ///< 消息发送失败,
    Msg_Status_Delete = 4,  ///< 消息被删除
    Msg_Status_DeleteRevoked        = 6,  ///< 被撤销的消息

};
////    Msg_Status_Sending_2,

@interface TMessageCellData : NSObject
@property(nonatomic,strong)NSDate *timestamp;

@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userHeader;
@property (nonatomic, assign) BOOL showName;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) TMsgStatus status;
@property (nonatomic, strong) id custom;
@property(nonatomic,assign)MsgUiType msgUiType;
@property(nonatomic,strong)NSString *senderUid;

@end

@class TMessageCell;
@protocol TMessageCellDelegate <NSObject>
- (void)didLongPressMessage:(TMessageCellData *)data inView:(UIView *)view;
- (void)didReSendMessage:(TMessageCellData *)data;
- (void)didSelectMessage:(TMessageCellData *)data;
- (void)needReloadMessage:(TMessageCellData *)data;
- (void)didTapHeaderMessage:(TMessageCellData *)data;
@end

@interface TMessageCell : UITableViewCell
@property (nonatomic, strong) UIImageView *head;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *error;
@property (nonatomic, strong, readonly) TMessageCellData *data;
@property (nonatomic, weak) id<TMessageCellDelegate> delegate;
- (CGFloat)getHeight:(TMessageCellData *)data;
- (CGSize)getContainerSize:(TMessageCellData *)data;
- (void)setData:(TMessageCellData *)data;
- (void)setupViews;
@end

//
//  YBFunctionCell.h
//  yunbaolive
//
//  Created by ybRRR on 2021/4/2.
//  Copyright © 2021 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol functionCellDelegate <NSObject>

-(void)clickFunction:(NSDictionary *)dic;

@end
@interface YBFunctionCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource>
{
    UILabel *titleLb ;
    UIView *backView ;
    NSArray *listArr;
    UICollectionView *_collectionView;
}
@property (nonatomic, strong)NSArray *dataDic;
@property (nonatomic, assign)id<functionCellDelegate>delegate;
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andListArr:(NSArray *)listar;
@end


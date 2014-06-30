//
//  AccountTableViewCell.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-6.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (weak, nonatomic) IBOutlet UIButton *radioButton;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *radioButton_b;
@property (weak, nonatomic) IBOutlet UILabel *girlLabel;
@property (weak, nonatomic) IBOutlet UIButton *pushButton;
@property (copy, nonatomic) NSString *selectedSex ;
@property (weak, nonatomic) IBOutlet UIButton *sex_a;
@property (weak, nonatomic) IBOutlet UIButton *sex_b;

- (IBAction)selectedAction:(UIButton *)sender;
@end

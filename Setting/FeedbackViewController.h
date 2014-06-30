//
//  FeedbackViewController.h
//  iSpace
//
//  Created by 莫景涛 on 14-5-9.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

@interface FeedbackViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedbackTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *conOurCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ratingCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *feedbackCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *submitCell;
@property (nonatomic , retain)NSArray *arrCell ;

@property (weak, nonatomic) IBOutlet UIView *normalStarView;
@property(nonatomic , copy)NSString *scores ;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UIView *clearBgView;
@property (weak, nonatomic) IBOutlet UILabel *alertInfoLabel;
@property(nonatomic ,assign)CGFloat  changeheight ;
- (IBAction)submitAction:(id)sender;
@end

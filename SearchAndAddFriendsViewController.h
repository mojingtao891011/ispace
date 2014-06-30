//
//  AddFriendsViewController.h
//  iSpace
//
//  Created by 莫景涛 on 14-4-26.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import "SearchListCell.h"


@interface SearchAndAddFriendsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SearchListCellDelegate>

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, weak) IBOutlet UIView *searchView;
@property (nonatomic, weak) IBOutlet UITableView *friendsTableView;
@property (nonatomic, weak) IBOutlet UITextField *searchKeywordTextField;

@end

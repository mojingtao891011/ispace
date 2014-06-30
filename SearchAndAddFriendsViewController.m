//
//  AddFriendsViewController.m
//  iSpace
//
//  Created by xiabing on 14-4-26.
//  Copyright (c) 2014年 Water World. All rights reserved.
//

#import "SearchAndAddFriendsViewController.h"
#import "SearchListCell.h"
#import "FriendInfoModel.h"
#import "UITools.h"
#import "NSDictionary+Additions.h"
#import "NSString+Additions.h"


static NSString * const kSearchListCellNibName = @"SearchListCell";
static NSString * const kSearchListCellIdentifier = @"SearchListCell";


@interface SearchAndAddFriendsViewController ()

@property (nonatomic, copy) NSString *searchKeyword;

@end


@implementation SearchAndAddFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.titleLabel.text = NSLocalizedString(@"Search And Add Friends View Title", nil);
        [self.titleLabel sizeToFit];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 重排界面
    [self relayoutControl];
    
    // 初始化TableView相关
    UINib *nib = [UINib nibWithNibName:kSearchListCellNibName bundle:nil];
    [_friendsTableView registerNib:nib forCellReuseIdentifier:kSearchListCellIdentifier];
    [_friendsTableView setDelegate:self];
    [_friendsTableView setDataSource:self];
    [UITools turnOffTableViewSeperatorIndent:_friendsTableView];
    [UITools setExtraCellLineHidden:_friendsTableView];
    
    [_searchKeywordTextField setDelegate:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


// 重新排列控件
- (void)relayoutControl
{
    if ([UITools isiPhone5])
    {
        CGRect searchViewFrame = self.searchView.frame;
        searchViewFrame.origin.y = 66;
        self.searchView.frame = searchViewFrame;
        
        CGRect tableViewFrame = _friendsTableView.frame;
        tableViewFrame.origin.y = 116;
        tableViewFrame.size.height = ScreenHeight - 116;
        _friendsTableView.frame = tableViewFrame;
    }
}


#pragma mark - <UITableViewDataSource> Functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_friends count];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchListCellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    [cell setTag:indexPath.row];
    [cell updateCellWithData:_friends[indexPath.row]];
    
    return cell;
}


#pragma mark - <UITableViewDelegate> Functions

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


#pragma mark - <UITextFieldDelegate> Functions

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - <SearchListCellDelegate> Functions

- (void)addFriendButtonDidTouchedWithTag:(long)tag
{
    NSString *message = @"Request Add Friend";
    NSString *messageBase64 = [UITools encodeBase64:message];
    FriendInfoModel *friendInfo = [self.friends objectAtIndex:tag];
    [self sendAddFriendMessage:messageBase64 toUser:friendInfo];
}


// 向某个用户发送添加好友请求
- (void)sendAddFriendMessage:(NSString *)message toUser:(FriendInfoModel *)friendInfo
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2069"
                                              andNeedUserId:USER_ID
                                          AndNeedBobyArrKey:@[@"account" , @"explain"]
                                        andNeedBobyArrValue:@[friendInfo.name , message]];
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:NULL
                     completeBlock:^(id result)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleAddFriendResult:result];
        });
    }];
}


// 处理添加好友返回的结果(在UI线程中运行)
- (void)handleAddFriendResult:(id)result
{
    // 1:   已经是你的好友了,禁止重复添加
    // 0:   消息已发送,等待用户确认
    // -200:用户未注册
    // -213:系统禁止添加自己
    
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        [UITools showMessage:@"请求发送成功, 等待用户确认"];
    }
    else
    {
        [UITools showError:errorCode];
    }
}


#pragma mark - UI Event Helpers

- (IBAction)handleSearchFriedsAction:(id)sender
{
    [_searchKeywordTextField resignFirstResponder];
    
    NSString *searchKeyword = [_searchKeywordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([searchKeyword isEmail] ||
        [searchKeyword isNumber])
    {
        self.searchKeyword = searchKeyword;
    }
    else
    {
        self.searchKeyword = [UITools encodeBase64:searchKeyword];
    }

    NSMutableDictionary *params = [NetDataService needCommand:@"2068"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"account"]
                                          andNeedBobyArrValue:@[self.searchKeyword]];
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:NULL
                     completeBlock:^(id result)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleSearchFriendsResult:result];
                       });
    }];
}


// 处理网络返回的结果(运行于UI线程中)
- (void)handleSearchFriendsResult:(id)result
{
    NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSArray *returnArr = [msgBody getArray:@"list"];
    for (NSDictionary *dict in returnArr)
    {
        FriendInfoModel *friendsInfo = [[FriendInfoModel alloc] initWithDataDic:dict];
        [friends addObject:friendsInfo];
    }
    
    self.friends = friends;
    [self.friendsTableView reloadData];
    
    if ([self.searchKeyword length] > 0 &&
        [self.friends count] < 1)
    {
        [UITools showMessage:@"该用户不存在"];
    }
}


@end

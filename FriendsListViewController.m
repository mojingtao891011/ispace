//
//  FriendsViewController.m
//  iSpace
//
//  Created by CC on 14-5-7.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "FriendsListViewController.h"
#import "UITools.h"
#import "Constants.h"
#import "SearchAndAddFriendsViewController.h"
#import "MessageSender.h"
#import "MessageReceiver.h"
#import "NSDictionary+Additions.h"


#define kAddFriendAlertViewTag      1
#define kDeleteFriendAlertViewTag   2


static NSString * const kFriendsListCellNibName = @"FriendsListCell";
static NSString * const kFriendsListCellIdentifier = @"FriendsListCell";


@interface FriendsListViewController ()

@property (assign, nonatomic) BOOL isNeedRefreshTableView;
@property (assign, nonatomic) BOOL isViewAppeared;

@end



@implementation FriendsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.titleLabel.text = NSLocalizedString(@"Friends View Title", nil);
        [self.titleLabel sizeToFit];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // NavigationBar 右侧按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [button setImage:[UIImage imageNamed:@"friend_list_add"]
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(handleAddFriendsAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // 初始化TableView相关
    UINib *nib = [UINib nibWithNibName:kFriendsListCellNibName bundle:nil];
    [_friendsTableView registerNib:nib forCellReuseIdentifier:kFriendsListCellIdentifier];
    [_friendsTableView setDelegate:self];
    [_friendsTableView setDataSource:self];
    [UITools turnOffTableViewSeperatorIndent:_friendsTableView];
    [UITools setExtraCellLineHidden:_friendsTableView];
    
    // 监听好友关系变更通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFriendRelationshipChanged:)
                                                 name:NM_SERVER_PUSH_MSG_2073
                                               object:nil];
    
    // 监听与设备关联状态变更通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceRelationshipChanged:)
                                                 name:NM_SERVER_PUSH_MSG_2065
                                               object:nil];
    
    // 请求好友数据
    _isLoadingFrinedInfo = TRUE;
    [self fetchFriendsInfo:TRUE];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 处理好友变更通知
- (void)handleFriendRelationshipChanged:(NSNotification *)notification
{
    NSDictionary *msgDict = [notification userInfo];
    NSDictionary *msgBody = [msgDict getDictionary:@"message_body"];
    NSInteger action = [msgBody getInteger:@"action"];          // 0:被对方删除好友; 1:对方添加我为好友。
    NSInteger result = [msgBody getInteger:@"result"];          // 0:添加好友被拒绝; 1:添加好友被通过; 2:添加好友请求。
    NSDictionary *info = [msgBody getDictionary:@"info"];
    
    if (action == 1 &&          // 添加好友验证通过
        result == 1)
    {
        FriendInfoModel *friendInfo = [[FriendInfoModel alloc] initWithDataDic:info];
        [self.friends addObject:friendInfo];
        if (self.isViewAppeared)
        {
            [self.friendsTableView reloadData];
        }
        else
        {
            self.isNeedRefreshTableView = TRUE;
        }
    }
    else if (action == 0)           // 删除好友
    {
        FriendInfoModel *friendInfo = [[FriendInfoModel alloc] initWithDataDic:info];
        for (FriendInfoModel *info in self.friends)
        {
            if ([info.uid isEqualToString:friendInfo.uid])
            {
                [self.friends removeObject:info];
                if (self.isViewAppeared)
                {
                    [self.friendsTableView reloadData];
                }
                else
                {
                    self.isNeedRefreshTableView = TRUE;
                }
                break;
            }
        }
    }
}


//// 监听我与设备关联状态变更通知
//- (void)handleDeviceRelationshipChanged:(NSNotification *)notification
//{
//    NSDictionary *msgDict = [notification userInfo];
//    NSDictionary *msgBody = [msgDict getDictionary:@"message_body"];
//    NSInteger action = [msgBody getInteger:@"action"];
//    NSString *deviceSerial = [msgBody getString:@"dev_sn"];
//    
//    if ([_currentDeviceInfo.dev_sn isEqualToString:deviceSerial])
//    {
//        if (action == 1)            // 1:授权; 0:解除授权。
//        {
//            _currentDeviceInfo.friendInfo.uid = USER_ID;
//        }
//        else                        // 解除我的授权
//        {
//            _currentDeviceInfo.friendInfo.uid = @"-1";
//        }
//        [self.friendsTableView reloadData];
//    }
//}


// 监听我与设备关联状态变更通知
- (void)handleDeviceRelationshipChanged:(NSNotification *)notification
{
    NSDictionary *msgDict = [notification userInfo];
    NSDictionary *msgBody = [msgDict getDictionary:@"message_body"];
    NSInteger action = [msgBody getInteger:@"action"];
    NSString *deviceSerial = [msgBody getString:@"dev_sn"];
    
    // action: 0表示解除授权; 1表示授权;
    if (action == 0)
    {
        if ([deviceSerial isEqualToString:self.currentDeviceInfo.dev_sn])
        {
            [self.navigationController popViewControllerAnimated:TRUE];
        }
    }
}



// 视图即将显示
- (void)viewWillAppear:(BOOL)animated
{
    if (self.isNeedRefreshTableView)
    {
        self.isNeedRefreshTableView = FALSE;
        [self fetchFriendsInfo:TRUE];
    }
}


// 视图即将从NavigationController移除
- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController || self.isBeingDismissed)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


// 视图已显示
- (void)viewDidAppear:(BOOL)animated
{
    self.isViewAppeared = TRUE;
}


// 视图被隐藏
- (void)viewDidDisappear:(BOOL)animated
{
    self.isViewAppeared = FALSE;
}



#pragma mark - UI Event Handlers

- (void)handleAddFriendsAction:(UIButton*)sender
{
    SearchAndAddFriendsViewController *addFriendsViewCtl = [[SearchAndAddFriendsViewController alloc] init];
    [self.navigationController pushViewController:addFriendsViewCtl animated:YES];
}



#pragma mark - 关于设备授权用户

// 是否被允许授权方问设备
- (BOOL)isGrantFriend:(FriendInfoModel *)friendInfo
{
    if ([self.currentDeviceInfo.friendInfo.uid isEqualToString:friendInfo.uid])
    {
        return TRUE;
    }
    
    return FALSE;
}


// 设置设备为未关联好友设备
- (void)setDeviceAsUngrantDevice:(DevicesInfoModel *)device
{
    device.friendInfo.uid = @"-1";
}


// 设置用户为设备的授权好友
- (void)setUser:(FriendInfoModel *)user asGrantForDevice:(DevicesInfoModel *)device
{
    device.friendInfo.uid = user.uid;
    device.friendInfo.name = user.name;
}


// 判断设备是否为当前用户拥有的设备, 用于: 只有拥有者身份才能对一个设备进行授权和解除授权
- (BOOL)isOwnerDevice:(DevicesInfoModel *)deviceInfo
{
    if ([self.currentDeviceInfo.owerInfo.uid isEqualToString:USER_ID])
    {
        return TRUE;
    }
    
    return FALSE;
}


#pragma mark - <UITableViewDataSource> Functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_friends count];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendsListCellIdentifier];
    [cell setDelegate:self];
    [cell setTag:indexPath.row];
    
    FriendInfoModel *friendInfo = [self.friends objectAtIndex:indexPath.row];
    [cell updateCellWithData:friendInfo];
    [cell setFriendsListCellStyle:FriendsListCellStyleNormal];
    
    return cell;
}


#pragma mark - <UITableViewDelegate> Functions

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selecteIndexPath = [tableView indexPathForSelectedRow];
    if (selecteIndexPath != nil &&
        [selecteIndexPath compare:indexPath] == NSOrderedSame)
    {
        FriendsListCell *cell = (FriendsListCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setFriendsListCellStyle:FriendsListCellStyleNormal];

        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
        return nil;
    }
    
    return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsListCell *cell = (FriendsListCell *)[tableView cellForRowAtIndexPath:indexPath];
    FriendInfoModel *friendInfo = [self.friends objectAtIndex:indexPath.row];
    if ([self isGrantFriend:friendInfo])          // 已与床头宝关联
    {
        [cell setFriendsListCellStyle:FriendsListCellStyleUnlinked];
    }
    else            // 没有与床头宝关联
    {
        [cell setFriendsListCellStyle:FriendsListCellStyleLinked];
    }
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsListCell *cell = (FriendsListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setFriendsListCellStyle:FriendsListCellStyleNormal];
}


#pragma - <FriendsListCellDelegate> Functions

// delete按钮被按下
- (void)friendsListCell:(FriendsListCell *)cell deleteButtonDidTouchedWithTag:(long)tag
{
    _friendInfoOfDeleting = [self.friends objectAtIndex:tag];

    NSString *okText = NSLocalizedString(@"OK Text", nil);
    NSString *cancelText = NSLocalizedString(@"Cancel Text", nil);
    NSString *messageBodyText = @"是否删除好友?";
    
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil
                                                       message:messageBodyText
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:cancelText, okText, nil];
    alerView.tag = kDeleteFriendAlertViewTag;
    [alerView show];
}


// link按钮被按下
- (void)friendsListCell:(FriendsListCell *)cell linkButtonDidTouchedWithTag:(long)tag
{
    // 只有管理员才有授权权限
    if (![self isOwnerDevice:_currentDeviceInfo])
    {
        NSString *messageBodyText = NSLocalizedString(@"Non Owner Prompt Message Body", nil);
        [UITools showMessage:messageBodyText];
        return;
    }
    
    // 只能把设备授权给一位好友. 如果当前已经把设备授权给某个好友,则必须先解除授权才能再进行授权
    if ([_currentDeviceInfo.friendInfo.uid integerValue] > 0)
    {
        NSString *messageBodyText = NSLocalizedString(@"Already Grant Device To Friend Message Body", nil);
        [UITools showMessage:messageBodyText];
        return;
    }
    
    _friendInfoOfUpdating = [self.friends objectAtIndex:tag];
    [self requestGrantFriend:_friendInfoOfUpdating forDevice:self.currentDeviceInfo.dev_sn];
}


// delink按钮被按下
- (void)friendsListCell:(FriendsListCell *)cell delinkButtonDidTouchedWithTag:(long)tag
{
    // 只有管理员才有授权权限
    if (![self isOwnerDevice:_currentDeviceInfo])
    {
        NSString *messageBodyText = NSLocalizedString(@"Non Owner Prompt Message Body", nil);
        [UITools showMessage:messageBodyText];
        return;
    }

    _friendInfoOfUpdating = [self.friends objectAtIndex:tag];
    [self requestUngrantFriend:_friendInfoOfUpdating forDevice:self.currentDeviceInfo.dev_sn];
}



#pragma mark - Network Functions

// 请求好友信息
- (void)fetchFriendsInfo:(BOOL)isShowWaiting
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2082"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:nil
                                          andNeedBobyArrValue:nil];

    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:isShowWaiting
                       failedBlock:^()
     {
         _isLoadingFrinedInfo = FALSE;
     }
                     completeBlock:^(id result)
     {
         _isLoadingFrinedInfo = FALSE;
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            [self handleFetchFriendsInfoResult:result];
                        });
     }];
}



// 处理请求好友返回的结果
- (void)handleFetchFriendsInfoResult:(id)result
{
    NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSArray *listArray = [msgBody getArray:@"list"];
    for (NSDictionary *dict in listArray)
    {
        FriendInfoModel *friendsInfo = [[FriendInfoModel alloc] initWithDataDic:dict];
        [friends addObject:friendsInfo];
    }
    
    if ([friends count] > 0)
    {
        self.friends = friends;
        [self.friendsTableView reloadData];
    }
    else
    {
        NSString *okText = NSLocalizedString(@"OK Text", nil);
        NSString *cancelText = NSLocalizedString(@"Cancel Text", nil);
        NSString *messageBodyText = NSLocalizedString(@"Add Friend Prompt Message Body", nil);

        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil
                                                           message:messageBodyText
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:cancelText, okText, nil];
        alerView.tag = kAddFriendAlertViewTag;
        [alerView show];
    }
}


// 请求删除好友
- (void)requestDeleteFriend:(FriendInfoModel *)friendInfo
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2072"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"account"]
                                          andNeedBobyArrValue:@[friendInfo.name]];
    
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
                            [self handleDeleteFriendResult:result];
                        });
     }];
}



// 处理删除好友返回的结果
- (void)handleDeleteFriendResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        [self.friends removeObject:_friendInfoOfDeleting];
        [self.friendsTableView reloadData];
    }
    else
    {
        [UITools showError:errorCode];
    }
}



// 绑定好友
- (void)requestGrantFriend:(FriendInfoModel *)friendInfo forDevice:(NSString *)deviceSerial
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2064"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"account", @"dev_sn"]
                                          andNeedBobyArrValue:@[friendInfo.name, deviceSerial]];
    
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
                            [self handleGrantFriendResult:result];
                        });
     }];
}



// 处理绑定结果
- (void)handleGrantFriendResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        [self setUser:_friendInfoOfUpdating asGrantForDevice:_currentDeviceInfo];
        [self.friendsTableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NM_DEVICE_BANDING_CHANGED object:nil];
        
        [UITools showMessage:@"绑定好友成功"];
    }
    else
    {
        [UITools showError:errorCode];
    }
}



// 解除绑定好友
- (void)requestUngrantFriend:(FriendInfoModel *)friendInfo forDevice:(NSString *)deviceSerial
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2061"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"dev_sn", @"goal"]
                                          andNeedBobyArrValue:@[deviceSerial, @"0"]];
    
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
                            [self handleUngrantFriendResult:result];
                        });
     }];
}



// 处理解除绑定
- (void)handleUngrantFriendResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        [self setDeviceAsUngrantDevice:_currentDeviceInfo];
        [self.friendsTableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NM_DEVICE_BANDING_CHANGED object:nil];
        
        [UITools showMessage:@"解除绑定成功"];
    }
    else
    {
        [UITools showError:errorCode];
    }
}


#pragma mark - <UIAlertViewDelegate> Functions

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        return;
    }
    
    if (alertView.tag == kDeleteFriendAlertViewTag)         // 删除好友提醒框
    {
        [self requestDeleteFriend:_friendInfoOfDeleting];
    }
    else if (alertView.tag == kAddFriendAlertViewTag)       // 添加好友提醒框
    {
        SearchAndAddFriendsViewController *addFriendsViewCtl = [[SearchAndAddFriendsViewController alloc] init];
        [self.navigationController pushViewController:addFriendsViewCtl animated:YES];
    }
}


@end

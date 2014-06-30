//
//  FriendsViewController.m
//  BedsideTreasure
//
//  Created by xiabing on 14-4-1.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "DeviceHomeViewController.h"
#import "DeviceListCell.h"
#import "SearchAndAddFriendsViewController.h"
#import "ChatViewController.h"
#import "FriendsListViewController.h"
#import "UITools.h"
#import "Tools.h"
#import "UIImageView+WebCache.h"
#import "UIView+Additions.h"
#import "NSDictionary+Additions.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "NSDictionary+Additions.h"
#import "MessageManager.h"


#define kUICaseNoDevices        0           // 无设备
#define kUICaseHasDevices       1           // 有设备


static NSString * const kDeviceListCellNibName = @"DeviceListCell";
static NSString * const kDeviceListCellIdentifier = @"DeviceListCell";


@interface DeviceHomeViewController ()

@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) NSMutableArray *addFriendRequests;
@property (assign, nonatomic) NSInteger deviceIndex;
@property (strong, nonatomic) AVAudioPlayer *player;

@property (assign, nonatomic) BOOL isViewAppeared;
@property (assign, nonatomic) NSInteger isNeedReloadDataWhenAppear;
@property (assign, nonatomic) NSInteger isNeedRefreshTableViewWhenAppear;

@end


@implementation DeviceHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.titleLabel.text = NSLocalizedString(@"Device Home View Title", nil);
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
    UINib *nib = [UINib nibWithNibName:kDeviceListCellNibName bundle:nil];
    [_devicesTableView registerNib:nib forCellReuseIdentifier:kDeviceListCellIdentifier];
    [_devicesTableView setDelegate:self];
    [_devicesTableView setDataSource:self];
    [_devicesTableView setSeparatorColor:[UIColor colorWithRed:199.0f/255.0f green:222.0f/255.0f blue:217.0f/255.0f alpha:1.0f]];
    [UITools turnOffTableViewSeperatorIndent:_devicesTableView];
    [UITools setExtraCellLineHidden:_devicesTableView];
    
    // 重排控件
    [self relayoutMainViewControl];

    // 初始化值
    self.devices = [[NSMutableArray alloc] initWithCapacity:0];
    self.addFriendRequests = [[NSMutableArray alloc] initWithCapacity:0];

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
    
    // 监听设备绑定变更通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceBandingChanged:)
                                                 name:NM_DEVICE_BANDING_CHANGED
                                               object:nil];
    
    // 监听设备消息数量变更通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceMessageChanged:)
                                                 name:NM_DEVICE_MESSAGE_CHANGED
                                               object:nil];

    [self fetchDeviceInfo];             // 请求设备信息
    [self fetchAddFriendRequest];       // 请求未处理的添加好友请求
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 处理好友关系变更通知
- (void)handleFriendRelationshipChanged:(NSNotification *)notification
{
    NSDictionary *msgDict = [notification userInfo];
    NSDictionary *msgBody = [msgDict getDictionary:@"message_body"];
    NSInteger action = [msgBody getInteger:@"action"];          // 0:被对方删除好友; 1:对方添加我为好友。
    NSInteger result = [msgBody getInteger:@"result"];          // 0:添加好友被拒绝; 1:添加好友被通过; 2:添加好友请求。
    NSDictionary *info = [msgBody getDictionary:@"info"];
    
    if (action == 1 &&
        result == 2)
    {
        FriendInfoModel *friendInfo = [[FriendInfoModel alloc] initWithDataDic:info];
        AddFriendRequestInfo *requestInfo = [[AddFriendRequestInfo alloc] init];
        requestInfo.friendInfo = friendInfo;
        [self.addFriendRequests addObject:requestInfo];
        [self switchAddFriendMessageButtonVisiable];
    }
}


// 监听我与设备关联状态变更通知
- (void)handleDeviceRelationshipChanged:(NSNotification *)notification
{
    NSDictionary *msgDict = [notification userInfo];
    NSDictionary *msgBody = [msgDict getDictionary:@"message_body"];
    NSInteger action = [msgBody getInteger:@"action"];
    NSString *deviceSerial = [msgBody getString:@"dev_sn"];
    
    // action: 0表示解除授权; 1表示授权;
    if (action == 1)
    {
        if (self.isViewAppeared)
        {
            [self fetchDeviceInfo];
        }
        else
        {
            self.isNeedReloadDataWhenAppear = TRUE;
        }
    }
    else
    {
        for (DevicesInfoModel *info in self.devices)
        {
            if ([info.dev_sn isEqualToString:deviceSerial])
            {
                [self.devices removeObject:info];
                break;
            }
        }
        
        if ([self.devices count] == 0)
        {
            [self switchUICase];
        }
        else
        {
            if (self.isViewAppeared)
            {
                [self.devicesTableView reloadData];
            }
            else
            {
                self.isNeedRefreshTableViewWhenAppear = TRUE;
            }
        }
    }
}


// 监听设备绑定用户状态变更
- (void)handleDeviceBandingChanged:(NSNotification *)notification
{
    [self.devicesTableView reloadData];
}


// 监听设备消息数量变更通知
- (void)handleDeviceMessageChanged:(NSNotification *)notification
{
    if (![notification.object isEqualToString:@"ClearMessage"])
    {
        [self.devicesTableView reloadData];
        
        if ([[MessageManager defaultInstance] messageReaderState] == kMessageReaderStateClosed)
        {
            [self playSound];
        }
    }
}


// 播放提示音
- (void)playSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"pixiedust" ofType:@"wav"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];
    [self.player play];
}


// 视图即将显示
- (void)viewWillAppear:(BOOL)animated
{
    if (self.isNeedRefreshTableViewWhenAppear)
    {
        [self.devicesTableView reloadData];
    }
    if (self.isNeedReloadDataWhenAppear)
    {
        [self fetchDeviceInfo];
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



#pragma mark - UI Helpers

// 根据用户是否有设备显示不同的界面
- (void)switchUICase
{
    if ([self.devices count] > 0)
    {
        if (self.noDevicesView.superview)
        {
            [self.noDevicesView removeFromSuperview];
        }
    }
    else
    {
        if (!self.noDevicesView.superview)
        {
            [self.view addSubview:self.noDevicesView];
            [self.noDevicesView setFrame:self.view.frame];
            [self.view bringSubviewToFront:self.noDevicesView];       // 让systemMessageButton显示在最前端
            [self.view bringSubviewToFront:self.systemMessageButton];
        }
    }
}


// 显示或隐藏添加好友消息条
- (void)switchAddFriendMessageButtonVisiable
{
    if ([self.addFriendRequests count] > 0)
    {
        self.systemMessageButton.hidden = FALSE;
        
        AddFriendRequestInfo *requestInfo = [self.addFriendRequests objectAtIndex:0];
        [self.systemMessageButton setTitle:[NSString stringWithFormat:@"%@ 请求添加你为好友!", [UITools decodeBase64:requestInfo.friendInfo.name]]
                                  forState:UIControlStateNormal];
    }
    else
    {
        self.systemMessageButton.hidden = TRUE;
    }
}



// 重新排列控件
- (void)relayoutMainViewControl
{
    if ([UITools isiPhone5])
    {
        if (self.systemMessageButton.hidden)
        {
            [self.devicesTableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        }
        else
        {
            CGRect buttonFrame = self.systemMessageButton.frame;
            buttonFrame.origin.y = 64.0f;               // 导航栏高度
            self.systemMessageButton.frame = buttonFrame;
            
            CGRect tableViewFrame = self.devicesTableView.frame;
            tableViewFrame.origin.y = buttonFrame.origin.y + buttonFrame.size.height;
            tableViewFrame.size.height = ScreenHeight - 64.0f - buttonFrame.size.height - 48.0f;    // 48.0TabBar高度
            self.devicesTableView.frame = tableViewFrame;
        }
        
        [self.noDevicesView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        CGRect noDevicesSubViewFrame = self.noDevicesSubView.frame;
        noDevicesSubViewFrame.origin.y = (self.noDevicesView.bounds.size.height - noDevicesSubViewFrame.size.height) / 2;
        self.noDevicesSubView.frame = noDevicesSubViewFrame;
        
        // 添加设备提示框
        CGRect addDeviceTipSubViewFrame = self.addDeviceTipSubView.frame;
        addDeviceTipSubViewFrame.origin.y = (ScreenHeight - addDeviceTipSubViewFrame.size.height) / 2;
        self.addDeviceTipSubView.frame = addDeviceTipSubViewFrame;
        
        CGRect addDeviceTipSubBackgroundViewFrame = self.addDeviceTipSubBackgroundView.frame;
        addDeviceTipSubBackgroundViewFrame.origin.y = (ScreenHeight - addDeviceTipSubBackgroundViewFrame.size.height) / 2;
        self.addDeviceTipSubBackgroundView.frame = addDeviceTipSubBackgroundViewFrame;
        
        // 响应添加好友请求
        CGRect responseAddFriendSubViewFrame = self.responseAddFriendSubView.frame;
        responseAddFriendSubViewFrame.origin.y = (ScreenHeight - responseAddFriendSubViewFrame.size.height) / 2;
        self.responseAddFriendSubView.frame = responseAddFriendSubViewFrame;
        
        CGRect responseAddFriendSubBackgroundView = self.responseAddFriendSubBackgroundView.frame;
        responseAddFriendSubBackgroundView.origin.y = (ScreenHeight - responseAddFriendSubBackgroundView.size.height) / 2;
        self.responseAddFriendSubBackgroundView.frame = responseAddFriendSubBackgroundView;
    }
    else
    {
        if (self.systemMessageButton.hidden)
        {
            [self.devicesTableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        }
        else
        {
            [self.devicesTableView setFrame:CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height-40)];
        }
    }
}

// 显示回应添加好友请求视图
- (void)showResponseAddFriendView
{
    [self.responseAddFriendView setFrame:self.view.frame];
    [self.responseAddFriendView setAlpha:0.0f];
    [self.view addSubview:self.responseAddFriendView];
    
    [UIView beginAnimations:@"ResponseAddFriendViewAnimation_Show" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.2f];
    [self.responseAddFriendView setAlpha:1.0f];
    [UIView commitAnimations];
    
    AddFriendRequestInfo *requestInfo = [self.addFriendRequests objectAtIndex:0];
    [self updateResponseAddFriendUI:requestInfo];
}


// 隐藏回应添加好友请求视图
- (void)hideResponseAddFriendView
{
    [UIView beginAnimations:@"ResponseAddFriendViewAnimation_Hide" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.2f];
    [self.responseAddFriendView setAlpha:0.0f];
    [UIView commitAnimations];
}


// 填充响应好友界面
- (void)updateResponseAddFriendUI:(AddFriendRequestInfo *)requestInfo
{
    [self.friendAvatarImageView setImageWithURL:[NSURL URLWithString:requestInfo.friendInfo.pic_url]
                               placeholderImage:[UIImage imageNamed:@"ic_test_head"]];
    self.friendNameLabel.text = [UITools decodeBase64:requestInfo.friendInfo.name];
    self.messageLabel.text = @"请求加添你为好友!";       // requestInfo.explain;
}



#pragma mark - <UITableViewDataSource> Functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.deviceIndex = 0;
    return [self.devices count];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:kDeviceListCellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setTag:indexPath.row];
    [cell setDelegate:self];
    [self configCell:cell withData:[self.devices objectAtIndex:indexPath.row]];

    return cell;
}


#pragma mark - <UITableViewDelegate> Functions

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}


#pragma mark - 配置表格行

// 用数据填充界面
- (void)configCell:(DeviceListCell *)cell withData:(DevicesInfoModel *)deviceInfo
{
    if ([deviceInfo.dev_name length] > 0)
    {
        cell.nameLabel.text = [UITools decodeBase64:deviceInfo.dev_name];
    }
    else
    {
        cell.nameLabel.text = [NSString stringWithFormat:@"我的设备%zd", ++self.deviceIndex];
    }
    
    if ([deviceInfo.friendInfo.uid integerValue] > 0)
    {
        cell.friendNameLabel.text = [UITools decodeBase64:deviceInfo.friendInfo.name];
        cell.linkStateImageView.image = [UIImage imageNamed:@"device_linked"];
    }
    else
    {
        cell.friendNameLabel.text = @"未绑定";
        cell.linkStateImageView.image = [UIImage imageNamed:@"device_unlinked"];
    }
    
    NSInteger unreadMessageCount = [[MessageManager defaultInstance] unreadMessageForDevice:deviceInfo.dev_sn];
    if (unreadMessageCount > 0)
    {
        cell.bandNumberView.hidden = FALSE;
        if (unreadMessageCount > 99)
        {
            cell.bandNumberLabel.text = @"99+";
        }
        else
        {
            cell.bandNumberLabel.text = [NSString stringWithFormat:@"%zd", unreadMessageCount];
        }
    }
    else
    {
        cell.bandNumberView.hidden = TRUE;
    }
}


#pragma mark - <DeviceListCellDelegate> Functions

// 长按按钮
- (void)deviceNameDidLongTouchedWithTag:(long)tag
{
    NSString *cannelText = NSLocalizedString(@"Cancel Text", nil);
    NSString *editDeviceNameText = NSLocalizedString(@"Edit Device Name Text", nil);
    NSString *deleteDeviceText = NSLocalizedString(@"Delete Device Text", nil);
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:cannelText
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:editDeviceNameText, deleteDeviceText, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = tag;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}


// 进入聊天界面
- (void)enterChatButtonDidTouchedWithTag:(long)tag
{
    ChatViewController *controller = [[ChatViewController alloc] init];
    DevicesInfoModel *deviceInfo = [self.devices objectAtIndex:tag];
    controller.currentDeviceInfo = deviceInfo;
    [self.navigationController pushViewController:controller animated:YES];
    
    [[MessageManager defaultInstance] resetUnreadMessageForDevice:deviceInfo.dev_sn];
    [self.devicesTableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:NM_DEVICE_MESSAGE_CHANGED object:@"ClearMessage"];
}


// 进入好友界面
- (void)enterFriendsButtonDidTouchedWithTag:(long)tag
{
    FriendsListViewController *controller = [[FriendsListViewController alloc] init];
    controller.currentDeviceInfo = [self.devices objectAtIndex:tag];
    [self.navigationController pushViewController:controller animated:YES];
}



#pragma mark - <UIActionSheetDelegate> Functions

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)           // 修改设备名称
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改设备名称"
                                                            message:@"请输入新的设备名称"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:@"取消", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alertView setDelegate:self];
        [alertView setTag:(1 << 16) | (actionSheet.tag & 0x0000FFFF)];
        [alertView show];
    }
    else if (buttonIndex == 1)      // 删除设备
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"解绑设备"
                                                            message:@"请确认是否解除设备?"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:@"取消", nil];
        [alertView setDelegate:self];
        [alertView setTag:(2 << 16) | (actionSheet.tag & 0x0000FFFF)];
        [alertView show];
    }
}


#pragma mark - <UIAlertViewDelegate> Functions

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        return;
    }
    
    int type = ((alertView.tag & 0xFFFF0000) >> 16);
    int tag = (alertView.tag & 0x0000FFFF);
    if (type == 1)          // 修改设备名称
    {
        _newDeviceNameOfUpdating = [[alertView textFieldAtIndex:0] text];  // 获得输入
        NSString *newDeviceNameBase64 = [UITools encodeBase64:_newDeviceNameOfUpdating];
        _deviceOfUpdating = [self.devices objectAtIndex:tag];
        [self requestUpdateDevice:_deviceOfUpdating.dev_sn name:newDeviceNameBase64];
    }
    else if (type == 2)     // 删除设备
    {
        _deviceOfDeleting = [self.devices objectAtIndex:tag];
        [self requestDeleteDevice:_deviceOfDeleting.dev_sn];
    }
}


#pragma mark - UI Event Handlers

// 响应添加好友按钮事件
- (IBAction)handleAddFriendsAction:(UIButton*)sender
{
    SearchAndAddFriendsViewController *addFriendsViewCtl = [[SearchAndAddFriendsViewController alloc] init];
    [self.navigationController pushViewController:addFriendsViewCtl animated:YES];
}


// 响应添加好友请求
- (IBAction)handleResponseAddFriendAction:(UIButton*)sender
{
    [self showResponseAddFriendView];
}


// 拒绝好友请求
- (IBAction)handleRejectAddFriendAction:(UIButton*)sender
{
    [self hideResponseAddFriendView];
    
    AddFriendRequestInfo *requestInfo = [self.addFriendRequests objectAtIndex:0];
    [self responseUser:requestInfo.friendInfo addFriendRequestWithAck:FALSE];
}


// 接受好友请求
- (IBAction)handleAcceptAddFriendAction:(UIButton*)sender
{
    [self hideResponseAddFriendView];
    
    AddFriendRequestInfo *requestInfo = [self.addFriendRequests objectAtIndex:0];
    [self responseUser:requestInfo.friendInfo addFriendRequestWithAck:TRUE];
}


#pragma mark - 添加设备提示框

// 显示添加设备提示框
- (void)showAddDeviceTipView
{
    [self.addDeviceTipView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.addDeviceTipView setAlpha:0.0f];
    [self.view addSubview:self.addDeviceTipView];
    
    [UIView beginAnimations:@"AddDeviceTipViewAnimation_Show" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.2f];
    [self.addDeviceTipView setAlpha:1.0f];
    [UIView commitAnimations];
    
}


// 隐藏添加设备提示框
- (void)hideAddDeviceTipView
{
    [UIView beginAnimations:@"AddDeviceTipViewAnimation_Hide" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.2f];
    [self.addDeviceTipView setAlpha:0.0f];
    [UIView commitAnimations];
}


// UIView动画完成通知
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:@"AddDeviceTipViewAnimation_Hide"])
    {
        [self.addDeviceTipView removeFromSuperview];
    }
    else if ([animationID isEqualToString:@"ResponseAddFriendViewAnimation_Hide"])
    {
        [self.responseAddFriendView removeFromSuperview];
    }
}


// 确定按钮
- (IBAction)okButtonDidTouch:(id)sender
{
    [self hideAddDeviceTipView];
    [self fetchDeviceInfo];
}


// 显示提示框
- (IBAction)showButtonDidTouch:(id)sender
{
    [self showAddDeviceTipView];
}


#pragma mark - 获取设备列表

// 请求获取设备信息
-(void)fetchDeviceInfo
{
    //请求体
    NSMutableDictionary *params = [NetDataService needCommand:@"2051"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"dev_type"]
                                          andNeedBobyArrValue:@[@"0"]];
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:@"更新中..."
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:NULL
                     completeBlock:^(id result)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleFetchDevicesResult:result];
        });
    }];
}


// 处理获取设备信息结果
- (void)handleFetchDevicesResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)         // 如果等于0说明有绑定设备
    {
        // 清空原有设备数据
        [self.devices removeAllObjects];
        
        // 填充新数据
        NSDictionary *dev_list = [msgBody getDictionary:@"dev_list"];
        NSArray *listArr = [dev_list getArray:@"list"];
        for (NSDictionary *deviceDict in listArr)
        {
            DevicesInfoModel *deviceInfo = [[DevicesInfoModel alloc] initWithDataDic:deviceDict];
            [self.devices addObject:deviceInfo];
        }
        
        // 刷新表格
        [self.devicesTableView reloadData];
    }
    
    [self switchUICase];
}



// 请求获取添加好友信息
- (void)fetchAddFriendRequest
{
    //请求体
    NSMutableDictionary *params = [NetDataService needCommand:@"2093"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:nil
                                          andNeedBobyArrValue:nil];
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:FALSE
                       failedBlock:NULL
                     completeBlock:^(id result)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self handleFetchAddFriendRequestResult:result];
         });
     }];
}


// 处理获取添加好友请求结果
- (void)handleFetchAddFriendRequestResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger requestMsgTotal = [msgBody getInteger:@"total"];
    if (requestMsgTotal > 0)
    {
        NSArray *requestMsgList = [msgBody getArray:@"list"];
        for (NSDictionary *dict in requestMsgList)
        {
            NSDictionary *info = [dict getDictionary:@"info"];
            FriendInfoModel *friendInfo = [[FriendInfoModel alloc] initWithDataDic:info];
            NSString *explain = [dict getString:@"explain"];
            
            AddFriendRequestInfo *requestInfo = [[AddFriendRequestInfo alloc] init];
            requestInfo.friendInfo = friendInfo;
            requestInfo.explain = explain;
            
            [self.addFriendRequests addObject:requestInfo];
        }
    }
    
    [self switchAddFriendMessageButtonVisiable];
    [self relayoutMainViewControl];
}


// 响应添加好友请求
- (void)responseUser:(FriendInfoModel *)userInfo addFriendRequestWithAck:(BOOL)enable
{
    //请求体
    NSMutableDictionary *params = [NetDataService needCommand:@"2070"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"uid", @"result"]
                                          andNeedBobyArrValue:@[userInfo.uid, (enable ? @"1" : @"0")]];

    //请求网络
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:FALSE
                       failedBlock:NULL
                     completeBlock:^(id result)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self handleResponseAddFriendRequestResult:result];
         });
     }];
}



// 处理响应好友请求结果
- (void)handleResponseAddFriendRequestResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        if ([self.addFriendRequests count] > 0)
        {
            AddFriendRequestInfo *requestInfo = [self.addFriendRequests objectAtIndex:0];
            [self updateResponseAddFriendUI:requestInfo];
        }
    }
    else
    {
        [UITools showError:errorCode];
    }
    
    [self.addFriendRequests removeObjectAtIndex:0];     // 移除已处理的消息，注：第一条为当前处理消息
    [self switchAddFriendMessageButtonVisiable];
    [self relayoutMainViewControl];
}



// 请求删除设备
- (void)requestDeleteDevice:(NSString *)deviceSerial
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2061"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"dev_sn", @"goal"]
                                          andNeedBobyArrValue:@[deviceSerial, @"1"]];
    
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
                            [self handleDeleteDeviceResult:result];
                        });
     }];
}



// 处理删除设备结果
- (void)handleDeleteDeviceResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)     // 更新成功
    {
        // 通知其他模块
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:_deviceOfDeleting.dev_sn forKey:@"dev_sn"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NM_DEVICE_REMOVED object:userInfo];

        // 删除本地数据并刷新界面
        [self.devices removeObject:_deviceOfDeleting];
        _deviceOfDeleting = nil;
        [self.devicesTableView reloadData];
        
        // 切换UI
        if ([self.devices count] == 0)
        {
            [self switchUICase];
        }
    }
    else
    {
        [UITools showMessage:@"解绑设备失败"];
    }
}



// 请求更新设备名称
- (void)requestUpdateDevice:(NSString *)deviceSerial name:(NSString *)newName
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2085"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"dev_sn", @"name"]
                                          andNeedBobyArrValue:@[deviceSerial, newName]];
    
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
                            [self handleUpdateDeviceNameResult:result];
                        });
     }];
}



// 处理更新设备名称结果
- (void)handleUpdateDeviceNameResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)     // 更新成功
    {
        _deviceOfUpdating.dev_name = [UITools encodeBase64:_newDeviceNameOfUpdating];
        [self.devicesTableView reloadData];
        
        // 通知其他模块
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:_deviceOfUpdating.dev_sn forKey:@"dev_sn"];
        [userInfo setValue:_deviceOfUpdating.dev_name forKey:@"dev_name"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NM_DEVICE_INFO_CHANGED object:userInfo];
    }
}


@end




// AddFriendRequestInfo
@implementation AddFriendRequestInfo

@end



//
//  ListViewController.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-14.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "RecordViewController.h"
#import "RecordModel.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "UploadModel.h"
#import "VoiceConverter.h"

@interface RecordViewController ()

@end

@implementation RecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"语音列表" ;
        [self.titleLabel sizeToFit];
        isLocalRecord = YES ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imgName = @"bt_radio_normal" ;
    [self setExtraCellLineHidden:_listTableView];
    [self setButtonImageNamed:@"bt_radio_normal.png"];
    _selectedRow = -1 ;
    
    _listArr = [[NSMutableArray alloc]initWithCapacity:10];
    
     selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    int height ;
    if (Version < 7.0) {
        height = ScreenHeight - 50-64 ;
    }else{
        height = ScreenHeight - 50 ;
    }
    [selectedButton setFrame:CGRectMake(10,height , ScreenWidth-20, 40)];
    selectedButton.backgroundColor = buttonBackgundColor;
    [selectedButton setTitle:@"设为闹铃" forState:UIControlStateNormal];
    [selectedButton addTarget:self action:@selector(selectedMusic) forControlEvents:UIControlEventTouchUpInside];
    selectedButton.hidden = YES ;
    [self.view addSubview:selectedButton];
    
    _listTableView.dele = self ;
    _listTableView.isNeedPullRefresh = YES ;
    _listTableView.isComeInRefresh = YES ;
    [_listTableView awakeFromNib];
    
    _listTableView.tableHeaderView = _headView ;
    myUploadArr = [[NSMutableArray alloc]initWithCapacity:10];
    isLocalRecord = YES ;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_listTableView reloadData];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   //暂停播放所收藏的音乐
    isselected = NO ;
    [self playOnlineMusic:0];
    isselected = YES ;
    //暂停播放录音
    if ([_player isPlaying]) {
        [_player stop];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
#pragma mark-------------------------UITableViewDataSource-------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLocalRecord) {
        NSInteger count = _listArr.count + [[self getRecordFile] count] ;
        return count ;//本地语音（在线收藏＋我的录音）
    }
    return myUploadArr.count; //我的上传
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID" ;
    UITableViewCell *listCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (listCell == nil) {
        listCell = [[NSBundle mainBundle]loadNibNamed:@"ListCell" owner:self options:nil][0];
    }
    radioImg = (UIImageView*)[listCell.contentView viewWithTag:1];
    UILabel *nameLabel = (UILabel*)[listCell.contentView viewWithTag:2];
    UIImageView *clockImg = (UIImageView*)[listCell.contentView viewWithTag:3];
    
    if (indexPath.row == _selectedRow && isselected ) {
        [radioImg setImage:[UIImage imageNamed:_imgName]];
       
        if (isWaite) {
            [self setButtonImageNamed:@"loadingbutton.png"];
        }else{
            [self setButtonImageNamed:@"bt_radio_pressed.png"];
        }
        clockImg.hidden =  !_isHidden;
    }
    else{
         [radioImg setImage:[UIImage imageNamed:@"bt_radio_normal"]];
        clockImg.hidden = YES ;
    }
    
    if (isLocalRecord) {
    
            if (indexPath.row < _listArr.count) {
                RecordModel *model = _listArr[indexPath.row];
                nameLabel.text =[[NSString alloc]decodeBase64:model.recordName] ;
            }else {
                NSArray *recordArr = [self getRecordFile];
                NSInteger indexs = indexPath.row - _listArr.count ;
                NSString *record_name = recordArr[indexs];
                NSString *dec_recordName = [[NSString alloc]decodeBase64:[record_name stringByDeletingPathExtension]];
                nameLabel.text =[NSString stringWithFormat:@"%@.%@" , dec_recordName , [record_name pathExtension]];
            }
    }
    else{
        UploadModel *uploadModel = myUploadArr[indexPath.row];
        nameLabel.text = [[NSString alloc]decodeBase64:uploadModel.name];
    }
    
    return listCell ;
}
#pragma mark-------------------------UITableViewDelegate-------------------------
#pragma mark-----didSelectRow
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     _imgName = @"bt_radio_pressed" ;
    _isHidden = YES;
    if (_selectedRow != indexPath.row) {
        isselected= YES ;
        _selectedRow = indexPath.row ;
        
    }
    else{
        isselected = NO ;
        _selectedRow = -1 ;
        
    }
    if (isLocalRecord)
    {
        
            if (indexPath.row < _listArr.count) {
                RecordModel *model = _listArr[indexPath.row];
                musicUrl = model.recordUrl ;
                if ([_player isPlaying] && _player != nil) {
                    
                    [_player stop];
                }
                lastRecordName = nil ;
                [self playOnlineMusic:indexPath.row];
                
                //发送选中通知
                [[NSNotificationCenter defaultCenter]postNotificationName:@"postRecordModel" object:_listArr[indexPath.row]];
            }
            else{
                NSString *recordName = [self getRecordFile][indexPath.row - _listArr.count];
                [self playRecordFile:recordName];
                
                //发送选中通知
                [[NSNotificationCenter defaultCenter]postNotificationName:@"postRecordName" object:recordName];
            }
    }
    else
    {
        UploadModel *uploadModel = myUploadArr[indexPath.row];
        musicUrl = uploadModel.url ;
        NSString *type = uploadModel.ext ;
        if ([type isEqualToString:@".amr"]) {
            [self playAmrMusic:musicUrl];
        }else{
            if ([_player isPlaying] && _player != nil) {
                [_player stop];
            }
            [self playOnlineMusic:indexPath.row];
        }
            //发送选中通知
        [[NSNotificationCenter defaultCenter]postNotificationName:@"postMyUploadModel" object:uploadModel];
    }
    if (isselected) {
        selectedButton.hidden = NO ;
    }else{
        selectedButton.hidden = YES ;
    }
    
    [_listTableView reloadData];
}
#pragma mark-------------------------ProtocolDelegate-------------------------
- (void)refreshFethNetData:(MJRefreshBaseView *)refreshView
{
    self.refreshView = refreshView ;
    if (isLocalRecord) {
        [self getRecordFile];
        [self getOnlineCollectMusicInfo];
    }else{
        [self getMyloadMusic];
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark-------------------------CustomAction-------------------------
#pragma mark-----UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}
#pragma mark-----播放amr格式的上传音乐
- (void)playAmrMusic:(NSString*)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
        
        [self playRecordFile:data];
    }];
}
#pragma mark-----选中音乐
- (void)selectedMusic
{
    if (isselected) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您还未选中铃声哦" delegate:self cancelButtonTitle:@"重选" otherButtonTitles:@"不选了", nil];
        [alertView show];
    }
}

#pragma mark-----播放录音文件
- (void)playRecordFile:(id)recordName
{
    isselected = NO ;
    [self playOnlineMusic:0];
    isselected = YES ;
    static int count = 0 ;
    if (![lastRecordName isEqualToString:recordName] && isLocalRecord) {
        count = 0 ;
        NSString *playPath = [NSString stringWithFormat:@"%@/%@" , [self getRecordPath] , recordName];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:playPath];
        NSData *recordData = [fileHandle availableData];
        NSError *error ;
        _player = [[AVAudioPlayer alloc]initWithData:recordData error:&error];
        if (error) {
            UIAlertView *alertView =[ [UIAlertView alloc]initWithTitle:nil message:@"亲～无法播放该格式文件" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            return ;
        }
        [_player play];

    }
    else if(!isLocalRecord){
        //工程的document目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *document = [paths objectAtIndex:0];
        NSString *amrPath = [NSString stringWithFormat:@"%@/%@" , document , @"amrPath"];
        BOOL isok =  [recordName writeToFile:amrPath options:NSDataWritingAtomic error:nil];
        if (isok) {
            NSString *wavPath = [NSString stringWithFormat:@"%@/%@" , document , @"wavPath"];
             int i = [VoiceConverter amrToWav:amrPath wavSavePath:wavPath];
            if (i == 0) {
                NSError *error ;
                _player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:wavPath] error:&error];
                if (error) {
                    UIAlertView *alertView =[ [UIAlertView alloc]initWithTitle:nil message:@"亲～无法播放该格式文件" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alertView show];
                    return ;
                }
                [_player play];
            }
        }
    }
    else{
        
        if ((count++)%2 == 0) {
             [_player pause];
        }else{
            [_player play];
        }
       
    }
    if (isLocalRecord) {
         lastRecordName = recordName ;
    }
   
}
#pragma mark-----获取录音文件
- (NSArray*)getRecordFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *recordArr = [fileManager contentsOfDirectoryAtPath:[self getRecordPath] error:nil];
    return recordArr ;
}
#pragma mark-----录音保存的地址
- (NSString*)getRecordPath
{
    //获取Document文件路径录音文件保存在Document／@"userName"/record 下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents= [paths objectAtIndex:0];
    NSString *recordPath = [NSString stringWithFormat:@"%@/%@/%@" , documents , USERNAME , @"Record"];
    return recordPath ;
}
#pragma mark------点击获取本地录音
- (IBAction)localRecord:(UIButton *)sender {
    
    isLocalRecord = YES ;
    isselected = NO ;
    _selectedRow = -1 ;
    [_listTableView reloadData];
}
#pragma mark------点击获取我的上传
- (IBAction)myUpload:(UIButton *)sender {
    isLocalRecord = NO ;
    isselected = NO ;
    _selectedRow = -1 ;
    if (myUploadArr.count == 0 ) {
        [self getMyloadMusic];
    }else{
        [_listTableView reloadData];
    }
    
}

#pragma mark-------------------------NetRequest-------------------------
#pragma mark------获取在线收藏的音乐
- (void)getOnlineCollectMusicInfo
{
    //获取语音
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2075" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"req_id"] andNeedBobyArrValue:@[@"-1"] needCacheData:NO needFininshBlock:^(id result){
        
        [_refreshView endRefreshing];
        if ([result isKindOfClass:[NSMutableArray class]]) {
            self.listArr = [result mutableCopy];
        }
        //[self getMyloadMusic];
        int count = _listArr.count + [self getRecordFile].count ;
        if (count == 0 && isLocalRecord) {
           //提示图片
        }else{
            
             [_listTableView reloadData];
        }
        
        
    }needFailBlock:^(id fail){
        [_refreshView endRefreshing];
    }];
        
}
#pragma mark------获取我的上传
- (void)getMyloadMusic
{
   
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2096" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"req_id" , @"start" , @"num"] andNeedBobyArrValue:@[@"-1" , @"0" , @"10"] needCacheData:NO needFininshBlock:^(id result){
        [self.refreshView endRefreshing];
         myUploadArr = [result mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            
                [_listTableView reloadData];
        });
    }needFailBlock:^(id fail){
        [self.refreshView endRefreshing];
        [_listTableView reloadData];
    }];

}
#pragma mark-------------------------播放在线音乐-------------------------
- (void)playOnlineMusic:(NSInteger)row
{
    
    if (isselected) {
        if ([streamer isPlaying]) {
            [streamer stop];
        }
        [self createStreamer];
        [radioImg setImage:[UIImage imageNamed:@"loadingbutton.png"]];
		[streamer start];
    }else
    {
        [streamer stop];
    }
   

}
- (void)createStreamer
{
    NSString *lastUrl = nil ;
	if ([lastUrl isEqualToString:musicUrl])
	{
		return;
	}
    lastUrl = musicUrl ;
	[self destroyStreamer];
	
	NSString *escapedValue =
    (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(
                                                                nil,
                                                                (__bridge CFStringRef)musicUrl,
                                                                NULL,
                                                                NULL,
                                                                kCFStringEncodingUTF8)
    ;
    
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
    
    
}
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
		
		[streamer stop];
		streamer = nil;
	}
}
- (void)playbackStateChanged:(NSNotification *)aNotification
{
    //NSLog(@"%d-%d-%d" , [streamer isWaiting] , [streamer isPlaying] , [streamer isIdle]);
    isWaite = [streamer isWaiting];
	[_listTableView reloadData];
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}

- (void)setButtonImageNamed:(NSString *)imageName
{
	if (!imageName)
	{
		imageName = @"bt_radio_normal";
	}
	
	currentImageName = imageName ;
	
	UIImage *image = [UIImage imageNamed:imageName];
	
	[radioImg.layer removeAllAnimations];
	[radioImg setImage:image];
    
	if ([imageName isEqual:@"loadingbutton.png"])
	{
		[self spinButton];
        
	}
}

- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [radioImg frame];
	radioImg.layer.anchorPoint = CGPointMake(0.5, 0.5);
	radioImg.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
    
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[radioImg.layer addAnimation:animation forKey:@"rotationAnimation"];
    
	[CATransaction commit];
}

@end

//
//  AddMusicViewController.m
//  InAppWebHTTPServer
//
//  Created by 莫景涛 on 14-5-15.
//  Copyright (c) 2014年 AlimysoYang. All rights reserved.
//

#import "AddMusicViewController.h"
#import "WifiViewController.h"
#import "Reachability.h"
#import "VoiceConverter.h"


#define GBUnit 1073741824
#define MBUnit 1048576
#define KBUnit 1024

@interface AddMusicViewController ()
@end

@implementation AddMusicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"音乐列表" ;
        [self.titleLabel sizeToFit];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _importButton.layer.borderWidth = 1.0 ;
    _importButton.layer.borderColor = buttonBackgundColor.CGColor;
    [self setExtraCellLineHidden:_musicTableView];
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _selectedRow = -1 ;
    [self getFilePath];
    [_musicTableView reloadData];
    
    if (_listArr.count == 0) {
        _musicTableView.hidden = YES ;
        _enterButton.hidden = YES ;
        _alertImg.hidden = NO ;
        _alertInfo.hidden = NO ;
    }else{
        _musicTableView.hidden = NO ;
        _enterButton.hidden = NO ;
        _alertImg.hidden = YES ;
        _alertInfo.hidden = YES ;
    }
    
     NSFileManager *fileManager = [NSFileManager defaultManager];
    if (_amrCopyPath != nil) {
        [fileManager removeItemAtPath:_amrCopyPath error:nil];
        [fileManager removeItemAtPath:_wavPath error:nil];
    }

   
    
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _isPlay = NO ;
    [_player pause];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (_amrCopyPath != nil) {
        [fileManager removeItemAtPath:_amrCopyPath error:nil];
        [fileManager removeItemAtPath:_wavPath error:nil];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)getFilePath
{
    //获取Document文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _document= [paths objectAtIndex:0];
    _musicPath = [NSString stringWithFormat:@"%@/%@/%@" , _document , USERNAME , @"WIFIMusic" ];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error ;
    //读取Document/userName/WIFIMusic目录下内容列表
    if ([fileManager fileExistsAtPath:_musicPath]) {
         NSArray *arr = [fileManager contentsOfDirectoryAtPath:_musicPath error:&error];
        NSLog(@"===%@" , arr);
         if (_listArr == nil) {
             _listArr = [[NSMutableArray alloc]initWithCapacity:10];
         }
            [_listArr removeAllObjects];
        [_listArr addObjectsFromArray:arr];
        
        //
       
    }
    
}

#pragma mark--------------UITableViewDataSource----------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
        return _listArr.count ;
   
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID" ;
    UITableViewCell *itemCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (itemCell == nil) {
        itemCell = [[NSBundle mainBundle]loadNibNamed:@"AddMusicCell" owner:self options:nil][0];
    }
    UIImageView *showPlaystaut = (UIImageView*)[itemCell.contentView viewWithTag:1];
    UILabel *fileNameLable = (UILabel*)[itemCell.contentView viewWithTag:2];
    if (indexPath.row == _selectedRow) {
        showPlaystaut.highlighted = _isPlay ;
        fileNameLable.textColor = buttonBackgundColor ;
    }else{
        showPlaystaut.highlighted = NO ;
        fileNameLable.textColor = [UIColor blackColor];
    }
    
    fileNameLable.text = _listArr[indexPath.row];
    return itemCell ;
    
}
#pragma mark--------------UITableViewDelegate---------------------------
#pragma mark-------didSelectRow
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isPlay = !_isPlay ;
    _selectedRow = indexPath.row ;
    
    if (_isPlay) {
         self.fileName = _listArr[indexPath.row];
        
        NSString *path = [self amrTowav:_fileName] ;
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        static NSData *data1 = nil ;
        NSData *data = [fileHandle availableData];
        NSError *error ;
        if (![data isEqualToData:data1]) {
            _player = [[AVAudioPlayer alloc]initWithData:data error:&error];
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"亲~该文件格式无法播放" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
                return ;
            }
        }
        data1 = data ;
        _player.volume = 1.0 ;
        _player.delegate = self ;
        [_player prepareToPlay];
        [_player play];
        [fileHandle closeFile];
    }else{
         self.fileName = nil;
        [_player pause] ;
    }
     [_musicTableView reloadData];
    
}
#pragma mark-------canEditRow
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
       return YES;
}
#pragma mark-------canEditRow
- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除" ;
}
#pragma mark------commitEditingAction
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *removePath = [NSString stringWithFormat:@"%@/%@/%@/%@" , _document , USERNAME , @"WIFIMusic" , _listArr[indexPath.row] ];
        [fileManager removeItemAtPath:removePath error:nil];
        [_listArr removeObjectAtIndex:indexPath.row];
        [_musicTableView reloadData];
    }
}
#pragma mark--------------CoustomAction---------------------------
#pragma mark -------amrTowav
- (NSString*)amrTowav:(NSString*)filedName
{
    NSArray *separatedArr = [filedName componentsSeparatedByString:@"."];
    if ([separatedArr[1] isEqualToString:@"amr"]) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (_amrCopyPath != nil) {
            [fileManager removeItemAtPath:_amrCopyPath error:nil];
            [fileManager removeItemAtPath:_wavPath error:nil];
        }
        
        NSString *amrPath = [NSString stringWithFormat:@"%@/%@" , _musicPath , filedName];
        _amrCopyPath = [NSString stringWithFormat:@"%@/%@" , _musicPath , @"amr.amr" ];
        _wavPath = [NSString stringWithFormat:@"%@/%@" , _musicPath , @"amrTowav.wav" ];
        BOOL isCopy =  [fileManager copyItemAtPath:amrPath toPath:_amrCopyPath error:nil];
        if (isCopy) {
            
            BOOL isWav = [VoiceConverter amrToWav:_amrCopyPath wavSavePath:_wavPath];
            if (!isWav) {
                return _wavPath ;
            }else{
                NSString *path = [NSString stringWithFormat:@"%@/%@" , _musicPath ,filedName] ;
                return path ;
            }

        }
    }else
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@" , _musicPath ,filedName] ;
        return path ;
    }
    return nil ;
}
#pragma mark------UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}
- (IBAction)selectMusicAction:(UIButton *)sender {
    if (self.fileName == nil) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"亲!您还未选中音乐哦~" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else{
        NSString *type = [self.fileName pathExtension];
        if ([type isEqualToString:@"mp3"] || [type isEqualToString:@"amr"] ||[type isEqualToString:@"wav"] ) {
            //postMusicModel(文件名)
            [[NSNotificationCenter defaultCenter]postNotificationName:@"postMusicModel" object:_fileName];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"亲!目前设备只支持mp3 wav amr格式的音频铃声~" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        
    }
}

- (IBAction)importMusic:(UIButton *)sender {
   
        WifiViewController *wifiViewCtl = [[WifiViewController alloc]init];
        [self.navigationController pushViewController:wifiViewCtl animated:YES];
    
}

#pragma mark-----AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.isPlay = NO ;
}
@end

//
//  AddMusicViewController.h
//  InAppWebHTTPServer
//
//  Created by 莫景涛 on 14-5-15.
//  Copyright (c) 2014年 AlimysoYang. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AddMusicViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , AVAudioPlayerDelegate>
{
    AVAudioPlayer *_player ;
    NSMutableArray *_listArr  ;
    NSString *_document ;
    NSString *_musicPath ;
    NSString *_amrCopyPath ;
    NSString *_wavPath ;
}

@property (weak, nonatomic) IBOutlet UITableView *musicTableView;
@property (nonatomic , assign)BOOL isPlay ;
@property (nonatomic , copy)NSString *fileName ;
@property (nonatomic , assign)NSInteger selectedRow ;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (weak, nonatomic) IBOutlet UIImageView *alertImg;
@property (weak, nonatomic) IBOutlet UILabel *alertInfo;

- (IBAction)selectMusicAction:(UIButton *)sender;

- (IBAction)importMusic:(UIButton *)sender;


@end

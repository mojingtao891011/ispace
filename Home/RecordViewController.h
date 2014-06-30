//
//  ListViewController.h
//  iSpace
//
//  Created by 莫景涛 on 14-4-14.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MJRefreshBaseView.h"

@class AudioStreamer ;
@interface RecordViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , RefreshProptor , UIAlertViewDelegate>
{
    NSInteger  _selectedRow ;
    BOOL _isHidden ;
    BOOL isselected ;
    BOOL isWaite ;
    BOOL isplay ;
    NSString *_imgName ;
    UIImageView *radioImg ;
    AudioStreamer *streamer;
    NSString *currentImageName;
    NSString *musicUrl ;
    NSString *lastRecordName ;
    UIButton *selectedButton ;
    NSMutableArray *myUploadArr ;
    BOOL isLocalRecord ;
    
}
@property(nonatomic , retain)NSMutableArray *listArr ;
@property(nonatomic , retain)AVAudioPlayer *player ;
@property (weak, nonatomic) IBOutlet BaseTableView *listTableView;
@property(nonatomic , retain)MJRefreshBaseView *refreshView ;
@property (strong, nonatomic) IBOutlet UIView *headView;
- (IBAction)localRecord:(UIButton *)sender;
- (IBAction)myUpload:(UIButton *)sender;


@end

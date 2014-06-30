//
//  WifiViewController.m
//  InAppWebHTTPServer
//
//  Created by bear on 14-5-15.
//  Copyright (c) 2014年 AlimysoYang. All rights reserved.
//

#import "WifiViewController.h"
#import "MyHTTPConnection.h"
#import "DDTTYLogger.h"
#import "HTTPServer.h"
#import "Reachability.h"

@interface WifiViewController ()

@end

@implementation WifiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text  = @"浏览器导歌" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAddressIP:) name:ADDRESS_IP object:nil];
    if ([self netStaut]) {
        currentDataLength = 0 ;
        self.wifiName.text = [[NSString alloc]getCurrentWifiName];
        [self startIphoneServer];
    }else{
        _promptInfo.text = @"当前网络不在WIFI网络下" ;
       
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
     [[NSNotificationCenter defaultCenter]removeObserver:self];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1 ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cell ;
}
#pragma mark------判断网络状态
- (BOOL)netStaut
{
    static BOOL netStaut ;
    
    Reachability *r =[Reachability reachabilityWithHostname:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            // NSLog(@" 没有网络连接");
            netStaut = NO ;
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            // NSLog(@" 使用3G网络");
            netStaut = NO ;
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            // NSLog(@" 使用WiFi网络");
            netStaut = YES ;
            break;
    }
    return netStaut ;
}
- (void)startIphoneServer{
    
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Initalize our http server
	self.httpServer = [[HTTPServer alloc] init];
	[self.httpServer setType:@"_http._tcp."];
	
    NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
	//DDLogInfo(@"Setting document root: %@", docRoot);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *uploadRoot = [[paths objectAtIndex:0] stringByAppendingPathComponent:USERNAME];
    NSString *uploadRoot = [NSString stringWithFormat:@"%@/%@/%@" ,[paths objectAtIndex:0] , USERNAME , @"WIFIMusic"];
    //DDLogInfo(@"Setting upload root: %@", uploadRoot);
    
	[self.httpServer setDocumentRoot:docRoot];
    [self.httpServer setUpLoadRoot:uploadRoot];
	
	[self.httpServer setConnectionClass:[MyHTTPConnection class]];
	
	NSError *error = nil;
	if(![self.httpServer start:&error])
	{
		//DDLogError(@"Error starting HTTP Server: %@", error);
	}
    
}
- (void)getAddressIP:(NSNotification*)note
{
    _lbHTTPServer.text = [note object] ;
    
}

@end

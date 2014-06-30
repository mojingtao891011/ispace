//
//  WifiViewController.h
//  InAppWebHTTPServer
//
//  Created by bear on 14-5-15.
//  Copyright (c) 2014年 AlimysoYang. All rights reserved.
//
#define HTTP_SERVER_PORT (8080)
#import "BaseViewController.h"

@class HTTPServer ;
@interface WifiViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate>
{
     UInt64 currentDataLength;
    HTTPServer      *webServer;
}
@property (strong, nonatomic) HTTPServer *httpserver;

@property (weak, nonatomic) IBOutlet UILabel *lbHTTPServer;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell;
@property (weak, nonatomic) IBOutlet UILabel *lbFileSize;
@property (weak, nonatomic) IBOutlet UILabel *lbCurrentFileSize;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *promptInfo;
@property (weak, nonatomic) IBOutlet UILabel *wifiName;
@property (weak, nonatomic) IBOutlet UILabel *stautInfo;
@property (nonatomic , retain)HTTPServer *httpServer ;
@end

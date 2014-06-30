//
//  NoDeviceViewController.m
//  iSpace
//
//  Created by bear on 14-6-13.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "NoDeviceViewController.h"

@interface NoDeviceViewController ()

@end

@implementation NoDeviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"设备设置" ;
        [self.titleLabel sizeToFit];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

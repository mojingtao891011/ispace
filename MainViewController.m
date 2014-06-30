//
//  MainViewController.m
//  iSpace
//
//  Created by bear on 14-6-19.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "TabBarViewController.h"
#import "BaseNavViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog(@"%@ , %@ , %@" , USERNAME , USERPASSWORD ,QUITLAND);
    if (USERNAME == NULL || USERPASSWORD == NULL || QUITLAND) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.view.alpha = 0.0 ;
        }completion:^(BOOL isCompletion){
            if (isCompletion) {
                LoginViewController *loginViewCtl = [[LoginViewController alloc]init];
                [self presentViewController:loginViewCtl animated:YES completion:nil];

            }
        }];
        
        
    }else{
        [self RememberUserNameAndPassWord];
        
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)RememberUserNameAndPassWord
{
    
    [[MKNetWork shareMannger] startNetworkWithNeedCommand:@"2049" andNeedUserId:@"0" AndNeedBobyArrKey:@[@"account" , @"password"] andNeedBobyArrValue:@[USERNAME,  USERPASSWORD] needCacheData:NO needFininshBlock:^(id result){
       
        int stautInt = [result intValue];
        [UIView animateWithDuration:0.5 animations:^{
            self.view.alpha = 0.0 ;
        }completion:^(BOOL isCompletion){
            
            if (stautInt == 0 || stautInt == -202) {
                TabBarViewController *tabBarViewCtl = [[TabBarViewController  alloc]init];
                [self presentViewController:tabBarViewCtl animated:YES completion:nil];
            }else{
                LoginViewController *loginViewCtl = [[LoginViewController alloc]init];
                [self presentViewController:loginViewCtl animated:YES completion:nil];
                
            }
            
        }];
        
    }needFailBlock:^(id fail){
       
        LoginViewController *loginViewCtl = [[LoginViewController alloc]init];
        [self presentViewController:loginViewCtl animated:YES completion:nil];
        
        
    }];
    
}

@end

//
//  GuidePageViewController.m
//  iSpace
//
//  Created by CC on 14-6-26.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "GuidePageViewController.h"
#import "iSpaceApp.h"
#import "Constants.h"


@interface GuidePageViewController ()
{
    UIImage *_image;
    BOOL _isLastPage;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *startButton;

@end


@implementation GuidePageViewController


- (id)initWithImage:(UIImage *)image andLastPageIndicate:(BOOL)isLastPage
{
    if (self = [super initWithNibName:@"GuidePageViewController" bundle:nil])
    {
        _image = image;
        _isLastPage = isLastPage;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = _image;
    self.startButton.hidden = _isLastPage ? FALSE : TRUE;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startButtonDidTouch:(id)sender
{
    if (_isLastPage)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NM_START_USE object:nil];
    }
}

@end

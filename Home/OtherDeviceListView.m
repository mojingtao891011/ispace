//
//  OtherDeviceListView.m
//  iSpace
//
//  Created by bear on 14-5-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "OtherDeviceListView.h"
#import "DevicesInfoModel.h"

@implementation OtherDeviceListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _subViewFrame = frame ;
        [self _inittableView];
//        self.layer.backgroundColor = [UIColor redColor].CGColor ;
//        self.layer.borderWidth = 2.0 ;
          self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}
- (void)_inittableView
{
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _subViewFrame.size.width, _subViewFrame.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self ;
    _tableView.delegate = self ;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    _tableView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_tableView];
    
}
#pragma mark-------UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _devicesTotalArr.count - 1 ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 20, 20)];
        imgView.tag = 1 ;
        [cell.contentView addSubview:imgView];
        
        UILabel *nameLabel =[[UILabel alloc]initWithFrame:CGRectMake(40, 10, 200, 20)];
        nameLabel.tag = 2 ;
        [cell.contentView addSubview:nameLabel];
    }
    
     UIImageView*imageView = (UIImageView*)[cell.contentView viewWithTag:1];
    imageView.image = [UIImage imageNamed:@"switchDevice.png"] ;
    UILabel *name_label = (UILabel*)[cell.contentView viewWithTag:2 ];
    name_label.backgroundColor = [UIColor clearColor];
    DevicesInfoModel *model = _devicesTotalArr[indexPath.row+1] ;
    if (model.dev_name.length == 0) {
        name_label.text = model.dev_sn ;
    }else{
        name_label.text = [[NSString alloc]decodeBase64:model.dev_name] ;
        //name_label.textColor = buttonBackgundColor;
    }
    name_label.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.selectionStyle =  UITableViewCellSelectionStyleNone ;
    return cell ;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isHomeSwitch) {
         [[NSNotificationCenter defaultCenter]postNotificationName:SWITCHDEVICENOTE object:[NSNumber numberWithInteger:indexPath.row+1]];
    }else
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:SWITCHDEVICENOTE_SETTING object:[NSNumber numberWithInteger:indexPath.row+1]];
    }
   
}
@end

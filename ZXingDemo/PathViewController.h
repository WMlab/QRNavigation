//
//  PathViewController.h
//  ZXingDemo
//
//  Created by tj  on 13-6-4.
//  Copyright (c) 2013年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingWidgetController.h>
#import <AVFoundation/AVFoundation.h>
#import "NavAlgorithm.h"
@interface PathViewController : UIViewController<ZXingDelegate>
{
    int start,end,pos,i;
    int index;
    CGFloat x,y;
    NSArray *coodinateData;
    NSArray *positionData;
    NSDictionary *placeDictionary;
}

@property (strong, nonatomic) IBOutlet UIButton *reScanBtn;
- (IBAction)reScanQRcode:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *mapView;
@property NSString *locationId;
@property NSString *destination;
@end

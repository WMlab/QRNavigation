//
//  NavigationViewController.h
//  ZXingDemo
//
//  Created by tj  on 13-6-3.
//  Copyright (c) 2013年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingWidgetController.h>
#import <AVFoundation/AVFoundation.h>

@interface NavigationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ZXingDelegate, UITextFieldDelegate>{
    NSArray *positionData;
}

@property (strong, nonatomic) IBOutlet UITextField *roomNumTextField;
@property (strong, nonatomic) IBOutlet UIButton *topScanBtn;
- (IBAction)scanFromNum:(id)sender;

- (IBAction)checkRoomNum:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *navTableView;

@property BOOL profCellisOpen;
@property (strong, nonatomic) NSArray *profArray;
@property (strong, nonatomic) NSArray *roomNumArray;
@property NSString *qrResult;
@property NSString *destination;
@end

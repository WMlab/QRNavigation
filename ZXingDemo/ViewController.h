//
//  ViewController.h
//  ZXingDemo
//
//  Created by Wei on 13-3-27.
//  Copyright (c) 2013年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingWidgetController.h>
#import "CustomViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <ZXingDelegate, CustomViewControllerDelegate, DecoderDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>
{
    int pos,i;
    int index;
    CGFloat x,y;
    NSArray *coodinateData;
    NSArray *positionData;
}

@property (nonatomic, strong) UITextView *textView;
@property (strong, nonatomic) IBOutlet UIImageView *mapView;

@property (strong, nonatomic) IBOutlet UIButton *scanQRcodeBtn;
- (IBAction)scanQRcode:(id)sender;
- (IBAction)goToNav:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *navBtn;

@property NSString *locationId;
@property NSString *destination;
@end

//
//  ViewController.m
//  ZXingDemo
//
//  Created by Wei on 13-3-27.
//  Copyright (c) 2013年 Wei. All rights reserved.
//

#import "ViewController.h"

#import <QRCodeReader.h>
//自定义需要用到
#import <Decoder.h>
#import <TwoDDecoderResult.h>

#import "AVCamViewController.h"

//生成二维码
#import "QREncoder.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize destination, locationId, mapView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    //载入坐标plist
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"coordinate" withExtension:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    NSMutableArray *tmpDataArray = [[NSMutableArray alloc] init];
    for (int j=1; j<=[dictionary count]; j++) {
        NSString *key = [[NSString alloc] initWithFormat:@"%i", j];
        NSDictionary *tmpDic = [dictionary objectForKey:key];
        [tmpDataArray addObject:tmpDic];
    }
    coodinateData = [tmpDataArray copy];
    //载入位置plist
    plistURL = [bundle URLForResource:@"position" withExtension:@"plist"];
    dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    tmpDataArray = [[NSMutableArray alloc] init];
    for (int j=1; j<=[dictionary count]; j++) {
        NSString *key = [[NSString alloc] initWithFormat:@"%i", j];
        NSDictionary *tmpDic = [dictionary objectForKey:key];
        [tmpDataArray addObject:tmpDic];
    }
    positionData = [tmpDataArray copy];
}

- (void)pressButton1:(UIButton *)button
{
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    NSMutableSet *readers = [[NSMutableSet alloc] init];
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    [readers addObject:qrcodeReader];
    widController.readers = readers;
    [self presentViewController:widController animated:YES completion:^{}];
}

- (IBAction)scanQRcode:(id)sender {
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    NSMutableSet *readers = [[NSMutableSet alloc] init];
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    [readers addObject:qrcodeReader];
    widController.readers = readers;
    [self presentViewController:widController animated:YES completion:^{}];

//    CustomViewController *vc = [[CustomViewController alloc] init];
//    vc.delegate = self;
//    [self presentViewController:vc animated:YES completion:^{}];
}

- (IBAction)goToNav:(id)sender {
    [self performSegueWithIdentifier:@"navigation" sender:self];
}

- (void)decodeImage:(UIImage *)image
{
    NSMutableSet *qrReader = [[NSMutableSet alloc] init];
    QRCodeReader *qrcoderReader = [[QRCodeReader alloc] init];
    [qrReader addObject:qrcoderReader];
    
    Decoder *decoder = [[Decoder alloc] init];
    decoder.delegate = self;
    decoder.readers = qrReader;
    [decoder decodeImage:image];
}

- (void)outPutResult:(NSString *)result
{
    NSLog(@"result:%@", result);
    pos = [[result substringFromIndex:3] intValue];
    
    UIGraphicsBeginImageContextWithOptions(mapView.image.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, mapView.image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    UIImage* mapImage = [UIImage imageNamed:@"ceieF7.jpg"];
    CGRect pictureRect = CGRectMake(0, 0, mapView.image.size.width, mapView.image.size.height);
    CGImageRef cgimage = mapImage.CGImage;
    CGContextDrawImage(context, pictureRect, cgimage);
    
    //position
    index = [[positionData objectAtIndex:(pos-1)] intValue]-1;
    x = [[[coodinateData objectAtIndex:index] objectForKey:@"x"] floatValue];
    y = [[[coodinateData objectAtIndex:index] objectForKey:@"y"] floatValue];
    UIImage* startImage = [UIImage imageNamed:@"start.jpg"];
    pictureRect =  CGRectMake(x-30, y-30, 60, 60);
    cgimage = startImage.CGImage;
    CGContextDrawImage(context, pictureRect, cgimage);
    
    mapImage = UIGraphicsGetImageFromCurrentImageContext();
    mapView.image = mapImage;
}

//#pragma mark - DecoderDelegate
//
//- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result
//{
//    //扫描成功后的代码
//    NSLog(@"result:%@", result);
//}
//
//- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason
//{
//    [self outPutResult:[NSString stringWithFormat:@"解码失败！"]];
//}
//
//#pragma mark - CustomViewControllerDelegate
//
//- (void)customViewController:(CustomViewController *)controller didScanResult:(NSString *)result
//{
//    [self dismissViewControllerAnimated:YES completion:^{[self outPutResult:result];}];
//    
//}
//
//- (void)customViewControllerDidCancel:(CustomViewController *)controller
//{
//    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"取消扫描！退出扫描器！");}];    
//}

#pragma mark - ZXingDelegate

- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:NO completion:^{[self outPutResult:result];}];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller
{
    [self dismissViewControllerAnimated:NO completion:^{NSLog(@"cancel!");}];
}

//#pragma mark - UIImagePickerControllerDelegate
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
//    [self dismissViewControllerAnimated:YES completion:^{[self decodeImage:image];}];    
//}
//
//#pragma mark - UITextViewDelegate
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScanQRcodeBtn:nil];
    [self setNavBtn:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}
@end

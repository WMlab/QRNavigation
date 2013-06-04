//
//  PathViewController.m
//  ZXingDemo
//
//  Created by tj  on 13-6-4.
//  Copyright (c) 2013年 Wei. All rights reserved.
//

#import "PathViewController.h"
#import <QRCodeReader.h>

@interface PathViewController ()

@end

@implementation PathViewController
@synthesize locationId, destination, mapView;
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
	// Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"路线-->%@", destination];
    NSLog(@"%@,%@",locationId, destination);
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
    
    plistURL = [bundle URLForResource:@"place" withExtension:@"plist"];
    placeDictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self getPathWithPosition:locationId];
}

-(void) getPathWithPosition:(NSString *) startPosition
{
    NSArray* path;
    pos = [[startPosition substringFromIndex:3] intValue];
    start = [[positionData objectAtIndex:(pos-1)] intValue];
    end = [[placeDictionary objectForKey:destination] intValue];
    
    UIGraphicsBeginImageContextWithOptions(mapView.image.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, mapView.image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    UIImage* mapImage = [UIImage imageNamed:@"ceieF7.jpg"];
    CGRect pictureRect = CGRectMake(0, 0, mapView.image.size.width, mapView.image.size.height);
    CGImageRef cgimage = mapImage.CGImage;
    CGContextDrawImage(context, pictureRect, cgimage);
    
    //path
    CGContextSetRGBStrokeColor(context, 0, 0.5, 1, 1);
    CGContextSetLineWidth(context, 20);
    path = [NavAlgorithm dijkstraWithStart:start End:end];
    for (i=0; i<[path count]-1; i++) {
        NSLog(@"%@\n",[path objectAtIndex:i]);
        index = [[path objectAtIndex:i] intValue]-1;
        NSLog(@"%@\n",[coodinateData objectAtIndex:index]);
        x = [[[coodinateData objectAtIndex:index] objectForKey:@"x"] floatValue];
        y = [[[coodinateData objectAtIndex:index] objectForKey:@"y"] floatValue];
        CGContextMoveToPoint(context, x, y);
        index = [[path objectAtIndex:i+1] intValue]-1;
        x = [[[coodinateData objectAtIndex:index] objectForKey:@"x"] floatValue];
        y = [[[coodinateData objectAtIndex:index] objectForKey:@"y"] floatValue];
        CGContextAddLineToPoint(context, x, y);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    //position
    x = [[[coodinateData objectAtIndex:start-1] objectForKey:@"x"] floatValue];
    y = [[[coodinateData objectAtIndex:start-1] objectForKey:@"y"] floatValue];
    UIImage* startImage = [UIImage imageNamed:@"start.jpg"];
    pictureRect =  CGRectMake(x-30, y-30, 60, 60);
    cgimage = startImage.CGImage;
    CGContextDrawImage(context, pictureRect, cgimage);
    
    //end
    x = [[[coodinateData objectAtIndex:end-1] objectForKey:@"x"] floatValue];
    y = [[[coodinateData objectAtIndex:end-1] objectForKey:@"y"] floatValue];
    UIImage* endImage = [UIImage imageNamed:@"end.jpg"];
    pictureRect =  CGRectMake(x-30, y-30, 60, 60);
    cgimage = endImage.CGImage;
    CGContextDrawImage(context, pictureRect, cgimage);
    
    mapImage = UIGraphicsGetImageFromCurrentImageContext();
    mapView.image = mapImage;

}
- (IBAction)reScanQRcode:(id)sender {
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    NSMutableSet *readers = [[NSMutableSet alloc] init];
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    [readers addObject:qrcodeReader];
    widController.readers = readers;
    
    [self presentViewController:widController animated:YES completion:^{}];

}
-(void) getReScanResult:(NSString *) result
{
    [self getPathWithPosition:result];
}
#pragma mark - ZXingDelegate

- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:NO completion:^{[self getReScanResult:result];}];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller
{
    [self dismissViewControllerAnimated:NO completion:^{NSLog(@"cancel!");}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self setReScanBtn:nil];
    [super viewDidUnload];
}
@end

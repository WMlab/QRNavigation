//
//  NavigationViewController.m
//  ZXingDemo
//
//  Created by tj  on 13-6-3.
//  Copyright (c) 2013年 Wei. All rights reserved.
//

#import "NavigationViewController.h"
#import "NavCell.h"
#import <QRCodeReader.h>
#import "NavAlgorithm.h"

#define ProfStartRow 5
@interface NavigationViewController ()

@end

@implementation NavigationViewController
@synthesize roomNumTextField, topScanBtn;
@synthesize navTableView;
@synthesize profCellisOpen, profArray,roomNumArray, destination, qrResult;
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
    // Do any additional setup after loading the view from its nib.
    profCellisOpen = NO;
    roomNumTextField.delegate = self;
    
    NSURL *profList = [[NSBundle mainBundle] URLForResource:@"professor" withExtension:@"plist"];
    profArray = [NSArray arrayWithContentsOfURL:profList];
    [topScanBtn setHidden:YES];
    
    NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"place" withExtension:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    NSEnumerator *keyEnum = [dictionary keyEnumerator];
    NSMutableArray *tempArr = [NSMutableArray array];
    NSString *key;
    while ((key = [keyEnum nextObject])) {
        [tempArr addObject:key];
    }
    roomNumArray = [tempArr copy];
    
    //载入位置plist
    plistURL = [[NSBundle mainBundle] URLForResource:@"position" withExtension:@"plist"];
    dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    NSMutableArray *tmpDataArray = [[NSMutableArray alloc] init];
    for (int j=1; j<=[dictionary count]; j++) {
        NSString *key = [[NSString alloc] initWithFormat:@"%i", j];
        NSDictionary *tmpDic = [dictionary objectForKey:key];
        [tmpDataArray addObject:tmpDic];
    }
    positionData = [tmpDataArray copy];
}

- (void) startScanQRcode:(UIButton *) sender {
    UIButton *theButton = (UIButton *) sender;
    
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    NSMutableSet *readers = [[NSMutableSet alloc] init];
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    [readers addObject:qrcodeReader];
    widController.readers = readers;
    widController.view.tag = theButton.tag;
    
    [self presentViewController:widController animated:YES completion:^{}];

}

- (void)getScanResult:(NSString *)result withTag:(NSInteger) tag
{
    NSLog(@"result:%@", result);
    NSLog(@"tag:%d", tag);
    int pos,start;
    NSArray *pathToWC1,*pathToWC2,*pathToLift1,*pathToLift2;
    qrResult = result;
    if (tag == 9999) {
        destination = roomNumTextField.text;
    }
    else
    {
        switch (tag) {
            case 0:
                pos = [[qrResult substringFromIndex:3] intValue];
                start = [[positionData objectAtIndex:(pos-1)] intValue];
                pathToWC1 = [NavAlgorithm dijkstraWithStart:start End:22];
                pathToWC2 = [NavAlgorithm dijkstraWithStart:start End:9];
                if ([pathToWC1 count]<[pathToWC2 count]) {
                    destination = @"wc1";
                } else {
                    destination = @"wc2";
                }
                break;
            case 1:
                destination = @"706";break;
            case 2:
                destination = @"702";break;
            case 3:
                pos = [[qrResult substringFromIndex:3] intValue];
                start = [[positionData objectAtIndex:(pos-1)] intValue];
                pathToLift1 = [NavAlgorithm dijkstraWithStart:start End:18];
                pathToLift2 = [NavAlgorithm dijkstraWithStart:start End:38];
                if ([pathToLift1 count]<[pathToLift2 count]) {
                    destination = @"lift1";
                } else {
                    destination = @"lift2";
                }
                break;
            case 4:
                break;
            default:
                destination = [[profArray objectAtIndex:tag - ProfStartRow] objectForKey:@"room"];break;

        }
    }
    
    [self performSegueWithIdentifier:@"path" sender:self];
}

- (IBAction)scanFromNum:(id)sender {
    [roomNumTextField resignFirstResponder];
    
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    NSMutableSet *readers = [[NSMutableSet alloc] init];
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    [readers addObject:qrcodeReader];
    widController.readers = readers;
    widController.view.tag = 9999;
    
    [self presentViewController:widController animated:YES completion:^{}];
}

- (IBAction)checkRoomNum:(id)sender {
    NSLog(@"value changed");
    if ([roomNumArray containsObject:roomNumTextField.text]) {
        [topScanBtn setHidden:NO];
    }
    else {
        [topScanBtn setHidden:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *destController = segue.destinationViewController;
    if ([destController respondsToSelector:@selector(setDestination:)]) {
        [destController setValue:destination forKey:@"destination"];
    }
    if ([destController respondsToSelector:@selector(setLocationId:)]) {
        [destController setValue:qrResult forKey:@"locationId"];
    }
}
#pragma tableview datasource delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    if (profCellisOpen) {
        number = ProfStartRow + [profArray count];
    }
    else {
        number = ProfStartRow;
    }
    return number;
}

#pragma mark - ZXingDelegate

- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:NO completion:^{[self getScanResult:result withTag:controller.view.tag];}];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller
{
    [self dismissViewControllerAnimated:NO completion:^{NSLog(@"cancel!");}];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *navCellIdentifier = @"navCell";
    NavCell *navCell = (NavCell *) [tableView dequeueReusableCellWithIdentifier:navCellIdentifier];
    if (navCell == nil) {
        navCell = [[[NSBundle mainBundle] loadNibNamed:@"NavCell" owner:self options:nil] objectAtIndex:0];
    }
    switch ([indexPath row]) {
        case 0:
            navCell.destinationLabel.text = @"找厕所";break;
        case 1:
            navCell.destinationLabel.text = @"到信通系主任办公室";break;
        case 2:
            navCell.destinationLabel.text = @"到行政老师办公室";break;
        case 3:
            navCell.destinationLabel.text = @"到电梯";break;
        case 4:
            navCell.destinationLabel.text = @"找教授";break;
            navCell.scanBtn.enabled = NO;
        default:
            NSDictionary *tempDic = (NSDictionary *)[profArray objectAtIndex:[indexPath row] - ProfStartRow];
            navCell.destinationLabel.textColor = [UIColor blueColor];
            navCell.destinationLabel.textAlignment = UITextAlignmentCenter;
            navCell.destinationLabel.text = [tempDic objectForKey:@"name"];
            break;
    }
    [navCell.scanBtn addTarget:self action:@selector(startScanQRcode:) forControlEvents:UIControlEventTouchUpInside];
    navCell.scanBtn.tag = [indexPath row];
    return navCell;
}

#pragma tableview delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NavCell *cell = (NavCell *) [tableView cellForRowAtIndexPath:indexPath];
    switch ([indexPath row]) {
        case ProfStartRow - 1:
        {
            NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [profArray count]; i++) {
                [indexPathArray addObject:[NSIndexPath indexPathForRow:[indexPath row] + i +1 inSection:[indexPath section]]];
            }
            if (profCellisOpen) {
                profCellisOpen = NO;
                [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
            }
            else
            {
                profCellisOpen = YES;
                [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
            }
            break;
        }
        default:
            if ([cell.scanBtn isHidden]) {
                for (int i = 0; i < [tableView numberOfRowsInSection:[indexPath section]]; i++) {
                    NavCell *tmpCell = (NavCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:[indexPath section]]];
                    [tmpCell.scanBtn setHidden:YES];
                }
                [cell.scanBtn setHidden:NO];
            } else {
                [cell.scanBtn setHidden:YES];
            }
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [roomNumTextField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setRoomNumTextField:nil];
    [self setNavTableView:nil];
    [self setTopScanBtn:nil];
    [super viewDidUnload];
}
@end

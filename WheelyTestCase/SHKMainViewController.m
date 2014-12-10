//
//  SHKMainViewController.m
//  WheelyTestCase
//
//  Created by Налия on 10.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKMainViewController.h"
#import "SHKWheelyAPIManager.h"
#import "SHKWheelyStory.h"
#import "SHKStoryTableViewCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "SHKStoryDetailViewController.h"

@interface SHKMainViewController () <UITableViewDataSource, UITableViewDelegate, SHKWheelyAPIManager>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;
@property (strong, nonatomic) SHKWheelyAPIManager *apiManager;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;
@property (strong, nonatomic) NSMutableDictionary *cachedHeights;
@property (assign, nonatomic) UIDeviceOrientation currentOrientation;
@end

NSString * const kStoryTableViewCellIdentifier = @"storyTableViewCellIdentifier";
NSString * const kStoryDetailSegueIdentifier = @"storyDetailSegueIdentifier";

@implementation SHKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.apiManager = [[SHKWheelyAPIManager alloc] init];
    self.apiManager.delegate = self;
    [self.apiManager refresh];
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    self.cachedHeights = [NSMutableDictionary dictionary];
    
    [self deviceOrientationDidChange];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [self addPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apiManager.stories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self configureCellForIndexPath:indexPath forHeightCalculation:NO];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (UITableViewCell *)configureCellForIndexPath:(NSIndexPath *)indexPath
                          forHeightCalculation:(BOOL)heightCalculation {
    SHKWheelyStory *story = [self.apiManager.stories objectAtIndex:indexPath.row];
    SHKStoryTableViewCell *cell;
    if (heightCalculation) {
        cell = [self.offscreenCells objectForKey:kStoryTableViewCellIdentifier];
        if (!cell) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:kStoryTableViewCellIdentifier];
            [self.offscreenCells setObject:cell forKey:kStoryDetailSegueIdentifier];
        }
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kStoryTableViewCellIdentifier forIndexPath:indexPath];
    }
    cell.title = story.title;
    cell.text = story.text;
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SHKWheelyStory *story = [self.apiManager.stories objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:kStoryDetailSegueIdentifier sender:story];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cachedHeightIdentifier = [NSString stringWithFormat:@"%d @ %d",indexPath.row, self.currentOrientation];
    CGFloat height = [[self.cachedHeights objectForKey: cachedHeightIdentifier] floatValue];
        if (height == 0) {
            SHKStoryTableViewCell *cell = (SHKStoryTableViewCell *)[self configureCellForIndexPath:indexPath
                                                                              forHeightCalculation:YES];
            [cell setNeedsUpdateConstraints];
            [cell updateConstraintsIfNeeded];
            cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds) - 10, CGRectGetHeight(cell.bounds));
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            [cell layoutSubviews];
            height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            height += 1.0f;
            [self.cachedHeights setObject:[NSNumber numberWithFloat:height] forKey:cachedHeightIdentifier];
        }
        return height;
}

#pragma mark - SHKWheelyAPIManager

- (void)storiesDidUpdate {
    [self.tableView.pullToRefreshView stopAnimating];
    self.refreshBarButton.enabled = YES;
    [self.cachedHeights removeAllObjects];
    [self.tableView reloadData];
}

- (void)willStartRefresh {
    [self.tableView.pullToRefreshView startAnimating];
    self.refreshBarButton.enabled = NO;
}

- (void)refreshDidFailWithError:(NSError *)error {
    [self.tableView.pullToRefreshView stopAnimating];
    self.refreshBarButton.enabled = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                     message:error.localizedRecoverySuggestion
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                           otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kStoryDetailSegueIdentifier]) {
        SHKStoryDetailViewController *destinationVC = segue.destinationViewController;
        destinationVC.story = sender;
    }
}

#pragma mark - Actions 

- (IBAction)refreshBarButtonTapped:(id)sender {
    [self.apiManager refresh];
}

#pragma mark - Subviews

- (void)addPullToRefresh {
    __weak SHKMainViewController *weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf.apiManager refresh];
    }];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"Pull to refresh", nil)
                                      forState:SVPullToRefreshStateStopped];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"Loading", nil)
                                      forState:SVPullToRefreshStateLoading];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"Release to refresh", nil)
                                      forState:SVPullToRefreshStateTriggered];
    
}

#pragma mark - Notifications

- (void)deviceOrientationDidChange {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSInteger orientationForCache;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationForCache = 0;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientationForCache = 0;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientationForCache = 1;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientationForCache = 1;
            break;
        default:
            break;
    }
    self.currentOrientation = orientationForCache;
    [self.tableView reloadData];
}


@end

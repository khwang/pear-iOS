//
//  KHFeatureIntroViewController.m
//  Pear
//
//  Created by Kevin Hwang on 2/9/15.
//  Copyright (c) 2015 Kevin Hwang. All rights reserved.
//

// VCs
#import "KHFeatureIntroViewController.h"
#import "KHFeatureIntroContentViewController.h"
#import "KHSignUpViewController.h"
#import "KHLoginViewController.h"

// Data Source
#import "KHFeatureIntroductionDataSource.h"

// Helper
#import "UIColor+KHHexString.h"

// View Helpers
#import <Masonry/Masonry.h>
#import "UIFont+KHAdditions.h"

@interface KHFeatureIntroViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) KHFeatureIntroductionDataSource *dataSource;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) UIButton *signupButton;
@property (nonatomic, strong) UIView *divider;
@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation KHFeatureIntroViewController

- (instancetype)init {
    if (self = [super init]) {
        _dataSource = [[KHFeatureIntroductionDataSource alloc] init];
        _scrollView = [[UIScrollView alloc] init];
        _pageControl = [[UIPageControl alloc] init];
        _footer = [[UIView alloc] init];
        _divider = [[UIView alloc] init];
        _signupButton = [[UIButton alloc] init];
        _loginButton = [[UIButton alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupScrollView];
    [self _setupPageControl];
    [self _setupIntroScreens];
    [self _setupFooter];
    [self _setupAutolayout];
}

- (void)_setupScrollView {
    [self.view addSubview:self.scrollView];
    self.scrollView.frame = self.view.bounds;
    CGSize pageScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pageScrollViewSize.width * ([self.dataSource count] + 2), pageScrollViewSize.height); // To enable infinite scrolling, we pad the actual VCs with additional first page/last page VCs
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
}

- (void)_setupPageControl {
    [self.view addSubview:self.pageControl];
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = [self.dataSource count];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
}

- (void)_setupIntroScreens {
    // Add the last intro screen behind the first one.
    UIViewController *firstVC = ({
        UIViewController *vc = [self _viewControllerAtIndex:[self.dataSource count] - 1];
        [self addChildViewController:vc];
        CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
        CGFloat pageHeight = CGRectGetHeight(self.scrollView.frame);
        CGFloat xOffset = 0;
        CGRect frame = CGRectMake(xOffset, 0, pageWidth, pageHeight);
        vc.view.frame = frame;
        [self.scrollView addSubview:vc.view];
        vc;
    });
    [firstVC didMoveToParentViewController:self];
    
    for (int i = 0; i < [self.dataSource count]; i++) {
        UIViewController *vc = [self _viewControllerAtIndex:i];
        [self addChildViewController:vc];
        CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
        CGFloat pageHeight = CGRectGetHeight(self.scrollView.frame);
        CGFloat xOffset = pageWidth * (i + 1);
        CGRect frame = CGRectMake(xOffset, 0, pageWidth, pageHeight);
        vc.view.frame = frame;
        [self.scrollView addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }
    
    // Add the first VC after the last one.
    UIViewController *lastVC = ({
        UIViewController *vc = [self _viewControllerAtIndex:0];
        [self addChildViewController:vc];
        CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
        CGFloat pageHeight = CGRectGetHeight(self.scrollView.frame);
        CGFloat xOffset = pageWidth * ([self.dataSource count] + 1);
        CGRect frame = CGRectMake(xOffset, 0, pageWidth, pageHeight);
        vc.view.frame = frame;
        [self.scrollView addSubview:vc.view];
        vc;
    });
    [lastVC didMoveToParentViewController:self];
    
    CGFloat startingXOffset = CGRectGetWidth(self.scrollView.frame); // The first page has been offset.
    self.scrollView.contentOffset = CGPointMake(startingXOffset, 0);
}

- (void)_setupFooter {
    [self.view addSubview:self.footer];
    self.footer.backgroundColor = [UIColor colorWithHexString:@"fed136"];
    
    [self.footer addSubview:self.signupButton];
    self.signupButton.backgroundColor = [UIColor colorWithHexString:@"fed136"];
    [self.signupButton setTitle:[NSLocalizedString(@"Sign up", nil) uppercaseStringWithLocale:[NSLocale currentLocale]] forState:UIControlStateNormal];
    self.signupButton.titleLabel.font = [UIFont boldWithSize:14];
    [self.signupButton addTarget:self action:@selector(_signupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.footer addSubview:self.divider];
    self.divider.backgroundColor = [UIColor darkGrayColor];
    
    [self.footer addSubview:self.loginButton];
    self.loginButton.backgroundColor = self.signupButton.backgroundColor;
    [self.loginButton setTitle:[NSLocalizedString(@"Log in", nil) uppercaseStringWithLocale:[NSLocale currentLocale]] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = self.signupButton.titleLabel.font;
    [self.loginButton addTarget:self action:@selector(_loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_setupAutolayout {
    CGFloat padding = 20.0f;
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.signupButton.mas_top).with.offset(-padding);
    }];
    
    CGFloat buttonHeight = 44.0f;
    [self.footer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    [self.signupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self.footer);
        make.left.equalTo(self.footer);
        make.right.equalTo(self.divider.mas_left);
    }];
    
    CGFloat dividerPadding = 10.0f;
    [self.divider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(buttonHeight - dividerPadding);
        make.width.mas_equalTo(1);
        make.center.equalTo(self.footer);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self.footer);
        make.right.equalTo(self.footer);
        make.left.equalTo(self.divider.mas_right);
    }];
}

#pragma mark - Appearance

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Helpers

- (UIViewController *)_viewControllerAtIndex:(NSUInteger)index {
    if (index < [self.dataSource count]) {
        KHFeatureIntroContentViewController *vc = [[KHFeatureIntroContentViewController alloc] init];
        vc.pageIndex = index;
        [vc setHeaderText:[self.dataSource headerTextForIndex:index]];
        [vc setDescriptionText:[self.dataSource descriptionTextForIndex:index]];
        [vc setBackgroundImage:[self.dataSource imageNameForIndex:index]];
        return vc;
    }
    return nil;
}

#pragma mark - Button Actions


- (void)_signupButtonTapped:(id)sender {
    KHSignUpViewController *vc = [[KHSignUpViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)_loginButtonTapped:(id)sender {
    KHLoginViewController *vc = [[KHLoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

/**
 When we wrap around, we jump to a content offset so it looks like we have infinite scrolling.
 Ex: Our VCs are set up: C [A] B C A
 When the user swipes left, we detect that we're at the beginning and then jump the offset.
 The result is: C A B [C] A
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    float fractionalPage = (self.scrollView.contentOffset.x - pageWidth) / pageWidth; // Take into account fake page 0, which is really the last page placed at the beginning
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
    
    CGFloat offsetWhenScrolledRight = pageWidth * ([self.dataSource count] + 1);
    if (scrollView.contentOffset.x == offsetWhenScrolledRight) {
        scrollView.contentOffset = CGPointMake(pageWidth, 0);
    } else if (scrollView.contentOffset.x == 0) {
        scrollView.contentOffset = CGPointMake(pageWidth * [self.dataSource count], 0);
    }
}

@end

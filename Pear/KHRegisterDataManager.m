//
//  KHRegisterDataManager.m
//  Pear
//
//  Created by Kevin Hwang on 2/8/15.
//  Copyright (c) 2015 Kevin Hwang. All rights reserved.
//

#import "KHRegisterDataManager.h"
#import "KHAPIManager.h"

@interface KHRegisterDataManager()

@property (nonatomic, weak) id<KHRegisterDataManagerDelegate>delegate;
@property (nonatomic, strong) KHAPIManager *manager;

@end

static NSString *const KHkUsernameKey = @"username";
static NSString *const KHkPasswordKey = @"password";

@implementation KHRegisterDataManager

- (instancetype)initWithDelegate:(id<KHRegisterDataManagerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _manager = [[KHAPIManager alloc] init];
    }
    return self;
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:username forKey:KHkUsernameKey];
    [params setValue:password forKey:KHkPasswordKey];
    
    [self.manager post:@"register" parameters:params success:^(id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSDictionary *errorDictionary, NSError *error) {
        NSLog(@"%@", errorDictionary);
    }];
}

@end

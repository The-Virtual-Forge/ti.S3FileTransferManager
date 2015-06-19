//
//  DeveloperAuthenticationProvider.m
//  S3FileTransferManager
//
//  Created by Terry Morgan on 16/06/2015.
//
//

#import "DeveloperAuthenticationProvider.h"

@interface DeveloperAuthenticationProvider()
@property (strong, atomic) NSString *providerName;
@end

@implementation DeveloperAuthenticationProvider

@synthesize providerName=_providerName;
@synthesize token=_token;

- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
                            logins:(NSDictionary *)logins
                      providerName:(NSString *)providerName
{
    if (self = [super initWithRegionType:regionType identityId:identityId accountId:nil identityPoolId:identityPoolId logins:logins]) {
        self.providerName = providerName;
    }
    return self;
}

- (BFTask *)getIdentityId {
    return [BFTask taskWithResult:self.identityId];
}

- (BFTask *)refresh {
    return [BFTask taskWithResult:self.identityId];
}

@end

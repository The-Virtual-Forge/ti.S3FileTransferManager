//
//  DeveloperAuthenticationProvider.h
//  S3FileTransferManager
//
//  Created by Terry Morgan on 16/06/2015.
//
//

#import <UIKit/UIKit.h>
#import <AWSCore/AWSCore.h>

@interface DeveloperAuthenticationProvider : AWSAbstractCognitoIdentityProvider

- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
                            logins:(NSDictionary *)logins
                      providerName:(NSString *)providerName;

@property (strong, nonatomic) NSString *token;

@end

//
//  ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerProxy.m
//  S3FileTransferManager
//
//  Created by Terry Morgan on 26/05/2015.
//
//

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerProxy.h"
#import "ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerUploadRequestProxy.h"
#import "DeveloperAuthenticationProvider.h"
#import "TiUtils.h"

@implementation ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerProxy

-(void)_initWithProperties:(NSDictionary *)properties
{
    self.identityPoolId = [properties objectForKey:@"identityPoolId"];
    self.regionType = [self getRegionTypeWithString:[properties objectForKey:@"region"]];
    
    self.username = [properties objectForKey:@"username"];
    self.token = [properties objectForKey:@"token"];
    self.identityId = [properties objectForKey:@"identityId"];
    self.developerAuthProviderName = [properties objectForKey:@"developerAuthProviderName"];
    
    [super _initWithProperties:properties];
}

-(void)_destroy
{
    [super _destroy];
}

-(AWSRegionType *)getRegionTypeWithString:(NSString *)regionProp {
    AWSRegionType *regionType;
    
    if ([regionProp isEqualToString:@"eu-west-1"]) {
        regionType = AWSRegionEUWest1;
    } else if ([regionProp isEqualToString:@"us-east-1"]) {
        regionType = AWSRegionUSEast1;
    } else if ([regionProp isEqualToString:@"us-west-1"]) {
        regionType = AWSRegionUSWest1;
    } else if ([regionProp isEqualToString:@"us-west-2"]) {
        regionType = AWSRegionUSWest2;
    } else if ([regionProp isEqualToString:@"eu-central-1"]) {
        regionType = AWSRegionEUCentral1;
    } else if ([regionProp isEqualToString:@"ap-southeast-1"]) {
        regionType = AWSRegionAPSoutheast1;
    } else if ([regionProp isEqualToString:@"ap-northeast-1"]) {
        regionType = AWSRegionAPNortheast1;
    } else if ([regionProp isEqualToString:@"ap-southeast-2"]) {
        regionType = AWSRegionAPSoutheast2;
    } else if ([regionProp isEqualToString:@"sa-east-1"]) {
        regionType = AWSRegionSAEast1;
    } else if ([regionProp isEqualToString:@"cn-north-1"]) {
        regionType = AWSRegionCNNorth1;
    } else {
        [NSException raise:@"Invalid region param" format:@"Region param of %@ is invalid", regionProp];
    }
    
    return regionType;
}

#pragma mark Cleanup

-(void)dealloc
{
    // release any resources that have been retained by the module
    [super dealloc];
}

#pragma Public APIs

-(void)initialise:(id)args
{
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider alloc];
    
    if (self.identityId && self.token && self.developerAuthProviderName) {
        // Authenticated credentials provider
        
        NSDictionary *logins = @{ self.developerAuthProviderName: self.username };
        
        DeveloperAuthenticationProvider *identityProvider = [[DeveloperAuthenticationProvider alloc]
                                                            initWithRegionType:self.regionType
                                                            identityId:self.identityId
                                                            identityPoolId:self.identityPoolId
                                                            logins:logins
                                                            providerName:self.developerAuthProviderName];
        
        [identityProvider setToken:self.token];
        
        [credentialsProvider initWithRegionType:self.regionType
                             identityProvider:identityProvider
                             unauthRoleArn:nil
                             authRoleArn:nil];
    } else {
        // UNauthenticated credentials provider
        [credentialsProvider initWithRegionType:self.regionType identityPoolId:self.identityPoolId];
    }

    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:self.regionType credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    self.currentUploads = [NSMutableArray new];
}

-(void)upload:(NSArray *)ur
{
    [self.currentUploads insertObject:ur atIndex:0];
    ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerUploadRequestProxy *urProxy = [ur objectAtIndex:0];
    AWSS3TransferManagerUploadRequest *uploadRequest = [urProxy valueForKey:@"uploadRequest"];
    
    [[self.transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [urProxy onCancelled];
                        });
                        break;
                        
                    case AWSS3TransferManagerErrorPaused:
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [urProxy onPaused];
                        });
                        break;
                        
                    default:
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [urProxy onError:task.error];
                        });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [urProxy onError:task.error];
                });
            }
        }
        
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [urProxy onSuccess:task.result];
            });
        }
        
        return nil;
    }];
}

-(void)pauseAll:(id)args
{
    //    [currentUploads enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        if ([obj isKindOfClass:[AWSS3TransferManagerUploadRequest class]]) {
    //            AWSS3TransferManagerUploadRequest *uploadRequest = obj;
    //            [[uploadRequest pause] continueWithBlock:^id(AWSTask *task) {
    //                if (task.error) {
    //                    NSLog(@"The pause request failed: [%@]", task.error);
    //                }
    //                return nil;
    //            }];
    //        }
    //    }];
}

-(void)resumeAll:(id)args
{
    //    [currentUploads enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        if ([obj isKindOfClass:[AWSS3TransferManagerUploadRequest class]]) {
    //            AWSS3TransferManagerUploadRequest *uploadRequest = obj;
    //            [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
    //                if (task.error) {
    //                    NSLog(@"The resume request failed: [%@]", task.error);
    //                }
    //                return nil;
    //            }];
    //        }
    //    }];
}

@end
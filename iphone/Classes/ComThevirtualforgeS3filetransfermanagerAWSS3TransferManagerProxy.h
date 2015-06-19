//
//  ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerProxy.h
//  S3FileTransferManager
//
//  Created by Terry Morgan on 26/05/2015.
//
//

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "TiProxy.h"

@interface ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerProxy : TiProxy

@property (strong, nonatomic) NSMutableArray *currentUploads;
@property (strong, nonatomic) AWSS3TransferManager *transferManager;

@property (strong, nonatomic) NSString *identityPoolId;
@property AWSRegionType *regionType;

@property (strong, nonatomic) NSString *identityId;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *developerAuthProviderName;

@end
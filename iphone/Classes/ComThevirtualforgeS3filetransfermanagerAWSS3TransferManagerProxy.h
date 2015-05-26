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
{
    NSMutableArray *currentUploads;
    AWSS3TransferManager *transferManager;
}

@end
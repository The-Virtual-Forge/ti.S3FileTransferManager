/**
 * S3FileTransferManager
 *
 * Created by Terry Morgan
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "TiModule.h"

@interface ComThevirtualforgeS3filetransfermanagerModule : TiModule
{
    NSString* identityPoolId;
    NSString* region;
    
    NSMutableArray *currentUploads;
    
    AWSS3TransferManager *transferManager;
}
@end

/**
 * S3FileTransferManagerAWSS3TransferManagerUploadRequestProxy
 *
 * Created by Terry Morgan
 * Copyright (c) 2015 The Virtual Forge. All rights reserved.
 */

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "TiProxy.h"

@interface ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerUploadRequestProxy : TiProxy
{
    AWSS3TransferManagerUploadRequest *uploadRequest;

    NSString *bucket;
    NSString *key;
    NSURL *body;

}

-(NSString *)state;

-(void)pauseUpload:(id)args;
-(void)cancel:(id)args;

-(void)onCancelled;
-(void)onPaused;
-(void)onSuccess:(id)result;
-(void)onError:(id)error;

- uploadRequest;
- body;
- key;
- bucket;

@end
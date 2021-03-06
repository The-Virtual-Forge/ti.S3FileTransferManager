# ti.S3FileTransferManager documentation

This Titanium module is an attempt to wrap the S3 file transfer portion of the AWS Mobile SDK. This has been
built primarily for an in-house project and as such is designed to meet our specific requirements.

Currently, it has the following limitations:

* iOS only (Android planned... maybe)
* Upload only
* Only unauthenticated and developer provider authentication are currently supported.

## Setup

Setup is fairly standard: download the zip file and install the module as per the [Installing modules](http://docs.appcelerator.com/platform/latest/#!/guide/Using_a_Module-section-30082372_UsingaModule-Installingmodules) page of the Appcelerator docs.

### Copy AWS JSON definitions files
The underlying AWS SDK needs a pair of JSON-formatted service definition files to operate. These can be found in the "platform" folder of the module and should be copied to the /platform/xxxx folder of your project.

From the command line, if you are in your Titanium project root:

```
cp modules/iphone/com.thevirtualforge.s3filetransfermanager/1.0.1/platform/iphone/*.json platform/iphone
```

## Import the module
To initialise the module, require it where needed:

```
var S3TransferManagerModule = require("com.thevirtualforge.s3filetransfermanager");
```

## AWSS3TransferManager
Use the `createAWSS3TransferManager` method of S3TransferManager to create a new AWSS3TransferManager object.

Pass the following params to `createAWSS3TransferManager` when creating the AWSS3TransferManager object:

* __region__ _{String}_ One of the preset AWS regions (Required).

Example:

```
eu-west-1
```

* __identityPoolId__ _{String}_ This can be found in the id param of the URL for your Cognito Identity Pool in AWS (Required).

Example URL:

```
https://eu-west-1.console.aws.amazon.com/cognito/pool/?region=eu-west-1&id=eu-west-1:vvvvv-wwwww-xxxxxx-yyyyyy-zzzzzzz
```

Use only the portion after "id=".

### Example of creating an AWSS3TransferManager
```
var S3TransferManager = S3TransferManagerModule.createAWSS3TransferManager({
    identityPoolId: "eu-west-1:xxxx-xxxx-xxxx-xxxx-xxxx",
    region: "eu-west-1"
});
```

### Configure & initialise the AWSS3TransferManager
If authentication is required, configure the AWSS3TransferManager by directly assigning properties to it then call it's `initialise` method. For unauthenticated uploads, simply call `initialise`.

#### Authenticated S3 bucket access
If the cognito identity pool attached to your S3 bucket requires authentication, the transferManager needs to be configured with a number of params, all required.

Only developer authenticated identity providers are currently supported and you'll need whatever backend solution you implement to forward an identityId & token, as returned by AWS, to your app.

##### Params

* __identityId__ _{String}_ The identityId as returned from your developr authenticated identity provider (Required).

* __token__ _{String}_ The token as returned  from your developr authenticated identity provider (Required).

* __username__ _{String}_ The username of the autheticated username (Required).

* __developerAuthProviderName__ _{String}_ The name of your develeloper authenticated identity provider (Required).

##### Example
```
// identityId returned from call to getOpenIdTokenForDeveloperIdentity
S3TransferManager.identityId = "xxxxxx";

// token returned from call to getOpenIdTokenForDeveloperIdentity
S3TransferManager.token = "xxxxx";

// the name of the developer authenticated identity provider
S3TransferManager.developerAuthProviderName = "my.authentication.provider";

// username used in call to getOpenIdTokenForDeveloperIdentity
S3TransferManager.username = "myUsername";

S3TransferManager.initialise();
```

#### Unauthenticated S3 bucket access
If the Cognito Identity pool used by your S3 bucket allows unauthenticated access, simply call the `initialise` method with no params:

##### Example
```
S3TransferManager.initialise();
```

## AWSS3TransferManagerUploadRequest
To upload a file, you must first create an AWSS3TransferManagerUploadRequest object using createAWSS3TransferManagerUploadRequest method of the S3TransferManagerModule and pass it a number of params:

### Properties
* __bucket__ _{String}_ The name of the S3 bucket to upload to

* __key__ _{String}_ The key to be used for the name of the file in the S3 bucket

* __body__ _{String}_ A path to the file to be uploaded

* __progressCallback__ _{Function} Callback function to be called upon upload progress. As this gets called many times in quick succession, you may want to consider throttling it.

### Events
The uploadRequest object fires a number of events to indicate upload status

* __success__
Fired when the upload completes successfully

* __error__
Fired when an upload error occurs

* __cancelled__
Fired when an upload is cancelled

* __paused__
Fired when an uploaded is paused

### Methods

* __pauseUpload__Pauses the upload.

### Example
```
var uploadRequest = S3TransferManagerModule.createAWSS3TransferManagerUploadRequest({
	bucket: "my-bucket-name",
	key: file.name,
	body: file.nativePath,
	progressCallback: function(e) {
		console.log("[app.js] Upload progress");
		console.log(e);
	}
});

uploadRequest.addEventListener("success", function(e) {
	console.log("[app.js] Upload complete");
	console.log(e);
});

uploadRequest.addEventListener("error", function(e) {
	console.log("[app.js] Upload error");
	console.log(e);
});

uploadRequest.addEventListener("cancelled", function(e) {
	console.log("[app.js] Upload cancelled");
	console.log(e);
});

uploadRequest.addEventListener("paused", function(e) {
	console.log("[app.js] Upload paused");
	console.log(e);
});

// Start the upload
S3TransferManager.upload(currentUploadRequest);

// Pause the upload
currentUploadRequest.pauseUpload();

// Resume the upload (note it's the same as starting the upload)
S3TransferManager.upload(currentUploadRequest);
```

## Complete example

A complete example can be found in `iphone/example/app.js`.

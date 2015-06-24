function doUpload() {
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

    S3TransferManager.upload(uploadRequest);
}

Titanium.UI.setBackgroundColor('#000');

var S3TransferManagerModule = require("com.thevirtualforge.s3filetransfermanager");

var S3TransferManager = S3TransferManagerModule.createAWSS3TransferManager({
    identityPoolId: "eu-west-1:xxxx-xxxx-xxxx-xxxx-xxxx",
    region: "eu-west-1"
});

/**
 * To use a developer authenticated identity provider, pass in teh following params.
 * This assumes that you have made to AWS.CognitoIdentity.getOpenIdTokenForDeveloperIdentity
 * either via a API or directly elsewhere in your code
 */
S3TransferManager.initialise({
    // identityId returned from call to getOpenIdTokenForDeveloperIdentity
    identityId: "xxxxxx",
    // token returned from call to getOpenIdTokenForDeveloperIdentity
    token: "xxxxx",
    // the name of the developer authenticated identity provider
    developerAuthProviderName: "my.authentication.provider",
    // username used in call to getOpenIdTokenForDeveloperIdentity
    username: "myUsername"
});

/**
 * ... or to use unauthenticated
 */
// S3TransferManager.initialise();

var win1 = Titanium.UI.createWindow({
    title:"S3 Transfer Manager test",
    backgroundColor:"#fff"
});

var selectImageButton = Ti.UI.createButton({
    borderWidth: 1,
    title: "Select media from gallery",
    width: Ti.UI.SIZE
});

selectImageButton.addEventListener("click",function() {
    Titanium.Media.openPhotoGallery({
        success: function(event) {
            var blob = event.media;

            if (blob.apiName === "Ti.Blob") {
                file = blob.getFile();
                if ( ! file) {
                    console.log("[app.js] No file attached to blob. Fetching file now");
                    file = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory,Date.now()+".jpg");
                    file.write(blob);
                }

                if (file.apiName === "Ti.Filesystem.File") {
                    doUpload(file);
                }
            }
        },
        error: function captureError(error) {
            var a = Titanium.UI.createAlertDialog({title:'Camera'});

            if (error.code == Titanium.Media.NO_CAMERA) {
                a.setMessage('Please run this test on device');
            } else {
                a.setMessage('Unexpected error: ' + error.code);
            }
            a.show();
        },
        allowEditing:true,
        mediaTypes:[Ti.Media.MEDIA_TYPE_VIDEO,Ti.Media.MEDIA_TYPE_PHOTO]
    });
});

win1.add(selectImageButton);
win1.open();

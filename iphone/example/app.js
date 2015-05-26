Titanium.UI.setBackgroundColor('#000');

var S3TransferManager = require("com.thevirtualforge.s3filetransfermanager");

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

rm -rf build/*
python build.py
rm -rf /Users/terrymorgan/Documents/Titanium_Studio_Workspace/s3UploadTest/modules/iphone/com.thevirtualforge.s3filetransfermanager
rm -rf /Users/terrymorgan/Documents/Titanium_Studio_Workspace/s3UploadTest/com.thevirtualforge.s3filetransfermanager-iphone-*.zip
cp ./com.thevirtualforge.s3filetransfermanager-iphone-*.zip /Users/terrymorgan/Documents/Titanium_Studio_Workspace/s3UploadTest
unzip /Users/terrymorgan/Documents/Titanium_Studio_Workspace/s3UploadTest/com.thevirtualforge.s3filetransfermanager-iphone-*.zip -d /Users/terrymorgan/Documents/Titanium_Studio_Workspace/s3UploadTest
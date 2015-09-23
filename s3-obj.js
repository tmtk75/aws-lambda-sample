console.log('Loading function');

var aws = require('aws-sdk');
var s3 = new aws.S3({ apiVersion: '2006-03-01' });
var path = require('path');

exports.handler = function(event, context) {
    //console.log('Received event:', JSON.stringify(event, null, 2));
    // Get the object from the event and show its content type
    var bucket = event.Records[0].s3.bucket.name;
    var key = event.Records[0].s3.object.key;
    var params = {
        Bucket: bucket,
        Key: key
    };
    console.log("-------- test lambda for S3", bucket, key);
    s3.getObject(params, function(err, data) {
        if (err) {
            console.log(err);
            var message = "Error getting object " + key + " from bucket " + bucket +
                ". Make sure they exist and your bucket is in the same region as this function.";
            console.log(message);
            context.fail(message);
        } else {
            console.log('CONTENT TYPE:', data.ContentType);
            console.log('body:', data);
            var params1 = {Bucket: bucket, Key: "by-lambda/" + path.basename(key), Body: data.Body};
            s3.putObject(params1, function(err, data) {
                if (err) {
                    console.log(err);
                } else {
                    console.log("Successfully uploaded data to", data);
                }
                context.succeed(data.ContentType);
            });
        }
    });
};

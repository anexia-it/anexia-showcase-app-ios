# ANX Face App

<img src="https://raw.githubusercontent.com/anexia-it/anexia-showcase-app-ios/master/1.png" >

Table of Contents
=================

* [Philips HUE](#philips-hue)
* [Alexa](#alexa)
* [PubNub](#pubnub)
* [AWS Lambda](#aws-lambda)
* [Configuration](#configuration)

This app uses multiple external API's for the following use cases:

- the user opens the App and sees a camera viewfinder
- the user shoots a picture of his face
- the App uploads the Picture to an S3 bucket
- the App then calls the Microsoft Face API and send the URL of the former uploaded image on the S3 bucket
- Microsoft Face API responds on success with a JSON with Face recognition values like emotion, gender, age, etc..
- the App renders the result on the image and the user is able to share the image with the in place rendered values for emotion, gender and age


# Philips HUE

The App is able to connect to a Philips HUE bridge on the same network. Just press the lightbulb icon and follow the setup guide in the App. If the App is able to recognize the emotion then it will set lights on the connected Philips HUE to corresponding colors. (e.g. bright yellow for happiness, red for anger, etc...)


# Alexa

The App connects to PubNub for enabling notifications from Alexa. An Alexa skill has to be configured which listens to invocations like "face recognition" or similar. Then phrases to the skill can be added like: "shoot a picture".

The resulting flow would be:

* User: "Alexa, start the face recognition"
* Alexa: "Ready"
* User: "Shoot a picture"
* Alexa: "Done"

Afte that the configured Alexa skill would call an AWS Lambda function which published to a PubSub channel. The App itself listens on the same channel. When the message arrives the App shoots a picture.


# PubNub 

PubNub is used for listening to the "shootpicture" event from the Alexa skill on AWS Lambda. (https://www.pubnub.com) Create a free account and copy the API-keys into Config.plist and into the AWS Lambda Python code in main.py.


# AWS Lambda

The Alexa skill is running on an AWS Lambda function. The Python code for the Lambda function used by Alexa is also stored in this repository in the zip file "anx-showcase-alexa". Just unzip and follow the instructions in the contained README.md.

# Configuration

In order to activate all features some API keys need to be addd in the Config.plist file:

* pubNubPublishKey: Create a free account on PubNub and add the publish key here
* pubNubSubscribeKey: Create a free account on PubNub and add the subscribe key here
* faceApiKey: Create a free account for the Microsoft Face API and add the API key here
* accessKeyS3: Create an S3 account and add the accessKey here
* secretKeyS3: Create an S3 account and add the secretKey here
* bucketNameS3: Create an S3 bucket and add its name here

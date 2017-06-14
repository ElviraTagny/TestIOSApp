DoYouDreamUp - Virtual assistant iOS SDK
============ 

DoYouDreamUp SDK is a simple implementation of the virtual assistant provided by DoYouDreamUp to communicate and echange in real time through a websocket server.

---
## Features
[![Available in CocoaPods](https://img.shields.io/cocoapods/v/DoYouDreamUp.svg)](https://cocoapods.org/pods/DoYouDreamUp) [![CocoaDocs](https://img.shields.io/badge/docs-%E2%9C%93-blue.svg)](http://cocoadocs.org/docsets/DoYouDreamUp/) 

- [x] Easy integration with cocoapods
- [x] Easy access to Talk, History, Survey, TopQuestions features
- [x] Realtime communication using Websocket
- [x] Written in Objc and Swift complient
- [x] Compatible iOS8 & iOS9 & iOS10
- [x] [Complete documentation](http://cocoadocs.org/docsets/DoYouDreamUp/)

---
## Usage in Objective-C
### a - Header

- Import the header in your .h:
``` objective-c
 #import <DoYouDreamUp/DoYouDreamUp.h>
```

### b - Setup
- Setup your token & server information in the application:didFinishLaunchingWithOptions:
``` objective-c

[[DoYouDreamUpManager sharedInstance] configureWithDelegate:self
                     botId:@"972f1264-6d85-4a58-b5ac-da31481dda63"
         			 space:nil
                  language:@"FR"
                  testMode:false
              solutionUsed:Assistant
              pureLivechat:false
                 serverUrl:@"wss://jp.createmyassistant.com/servlet/chat"
           backupServerUrl:nil];					   
```

### c - Methods and delegates
- Implement the `DoYouDreamUpDelegate` protocol and its mandatory methods:
``` objective-c
///Callback to notify that the connection failed with the given error
///@param error the given error
-(void) dydu_connexionDidFailWithError:(nonnull NSError *)error {}

///Callback to notify that the connection closed correctly
-(void) dydu_connexionDidClosed {}

///Callback to notify that the connection opened
///@param contextId the contextId used in the current connexion
-(void) dydu_connexionDidOpenWithContextId:(nullable NSString*)contextId {}
```

- Connect to the server when you need it:
``` objective-c
[[DoYouDreamUpManager sharedInstance] connect];
```

- Implement the solution you need (example a talk):
``` objective-c
[[DoYouDreamUpManager sharedInstance] talk:@"Hi, can you help me?"];
```

- Implement the callback delegate:

``` objective-c
-(void) dydu_receivedTalkResponseWithMsg:(nonnull NSString*)message withExtraParameters:(nullable NSDictionary*)extraParameters {}
```

You are all set to test and use the solution! Build any UI you want around the chat service.

---


## Usage in Swift
### a - Briding (skip if already done)
- Create a new bridge file header
``` swift
  Go to File>New>File.. and add a new header file called `[AppNameHere]-Bridging-Header.h.
```

- Go go "Build Settings" and search for "Objective-c Bridging Header". Enter your bridging header path here if not already definied.

### b - Import header

- Add the following line to the bridge header file:
``` objective-c
  #import <DoYouDreamUp/DoYouDreamUp.h>
```

### c - Setup
- Setup your token & server information in the application:didFinishLaunchingWithOptions: (swift 2.3 style)

``` swift
import DoYouDreamUp
```

``` swift
 DoYouDreamUpManager.sharedInstance().configureWithDelegate(self,
                                                            botId: "972f1264-6d85-4a58-b5ac-da31481dda63",
                                                            consultationSpace: nil,
                                                            language: "FR",
                                                            testMode:true,
                                                            solutionUsed: Assistant,
                                                            pureLivechat: false,
                                                            serverUrl:"wss://jp.createmyassistant.com/servlet/chat",
                                                            backupServerUrl:nil)
```

### d - Methods and delegates
- Implement the `DoYouDreamUpDelegate` protocol and its mandatory methods:
``` swift
///Callback to notify that the connection failed with the given error
///@param error the given error
func dydu_connexionDidFailWithError(error: NSError) {}

///Callback to notify that the connection closed correctly
func dydu_connexionDidClosed() {}

///Callback to notify that the connection opened
///@param contextId the contextId used in the current connexion
func dydu_connexionDidOpenWithContextId(contextId:String?) {}
```

- Connect to the server when you need it:
``` swift
DoYouDreamUpManager.sharedInstance().connect()
```

- Implement the solution you need (example a talk):
``` swift
DoYouDreamUpManager.sharedInstance().talk("Hi, can you help me?"])
```
Implement the callback delegate:

``` swift
func dydu_receivedTalkResponseWithMsg(message: String, withExtraParameters extraParameters: [NSObject : AnyObject]?) {}
```

You are all set to test and use the solution! Build any UI you want around the chat service.

---

## Demo projects
Three demo projects are available in swift & objc. Including:
- cocoapods integration in swift
- cocoapods integration in objc
- one manual framework integration in objc

---
## Installation

The recommended way of installation is via [CocoaPods](http://cocoapods.org) a dependency manager for Cocoa projects. 
Pods lets you download and integrate DoYouDreamUp sdk in your Xcode project in less than 1 minute.  

You can install CocoaPods with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build DoYouDreamUp 1.0.0+.

To integrate DoYouDreamUp into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
pod 'DoYouDreamUp', '~> 1.0.8'
```

Then, run the following command:

```bash
$ pod install
```

##Misc
### Interface documentation
This sdk is a simple wrapper around the DoYouDreamUp websocket interface, something you'll might need to have a look at the [interface documention](https://github.com/DoYouDreamUp/Servlet-doc).

### Repository organisation
- DoYouDreamUpFMK: project to build the framework. The static **DoYouDreamUp.framework** is generated from the "Framework and doc" scheme.
- DoYouDreamUpFMK_objc: dev integration project with dependancies with **DoYouDreamUpFMK** project - in objc.
- DoYouDreamUpFMK_swift: dev integration project with dependancies with **DoYouDreamUpFMK** project - in swift.
- Examples/DoYouDreamUp_objc_pods: objc example with pod integration
- Examples/DoYouDreamUp_objc_manual: objc example with manual integration
- Examples/DoYouDreamUp_swift: swift example with pod integration
- DoYouDreamUp.framework: last version of the framework generated
- DOC: the local generated documentation

### Debug logs
No logs are displayed by default except errors, to enable it do:
``` objective-c
[DoYouDreamUpManager displayLog:true];
```

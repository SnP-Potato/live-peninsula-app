//
//  NowPlaying.h
//  Dynamic-Notch
//
//  Created by PeterPark on 7/17/25.
//


#import <Cocoa/Cocoa.h>

@interface NowPlaying : NSObject
+ (NowPlaying *)sharedInstance;
@property (retain) NSString *appBundleIdentifier;
@property (retain) NSString *appName;
@property (retain) NSImage *appIcon;
@property (retain) NSString *album;
@property (retain) NSString *artist;
@property (retain) NSString *title;
@property (assign) BOOL playing;
@end

extern NSString *NowPlayingInfoNotification;
extern NSString *NowPlayingStateNotification;


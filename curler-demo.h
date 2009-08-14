//
//  curler-demo.h
//  curler
//
//  Created by Gregory Barchard on 8/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//#import "cMacros.h"
#import <curler/curler.h>

@interface curler_demo : NSObject {
	
	// The properties for the ftp connection
	NSMutableDictionary		*properties;
	
	// The current items in folder on the ftp server
	NSMutableArray			*items;
	
	// The pallette to use
	IBOutlet	NSView		*palette;
	
	// The login view
	IBOutlet	NSView		*loginView;
	
	// The file view
	IBOutlet	NSView		*fileView;
	
	// The table view to show files
	IBOutlet	NSTableView	*tableView;
	
	// The CURL wrapper
	curler		*curl_wrapper;
	
	// The progress indicators
	IBOutlet	NSProgressIndicator	*connectingIndicator;
	
	// The connect/disconnect button
	IBOutlet	NSButton	*connectButton;
	
	// The pop up menu for connection types
	IBOutlet	NSPopUpButton		*connectionTypesButton;
}
@property (readwrite, retain) NSMutableDictionary *properties;
@property (readwrite, retain) curler *curl_wrapper;
@property (readwrite, retain) NSMutableArray *items;

#pragma mark - IBActions
// Attempt to login/disconnect to/from the server
- (IBAction)toggleConnection:(id)sender;

// Attempt to change directory on the server
- (IBAction)changeDirectory:(NSArray *)sender;

#pragma mark - Curl Delegate Methods
// Called when a connection is made
- (void)didConnectToHost:(NSString *)host;

// Called when a disconnect is made
- (void)didDisconnectFromHost:(NSString *)host;

// Called when an error occurs
- (void)didReceiveErrorFromHost:(NSString *)host withResponse:(NSError *)error;

// Called when the connection changes directory
- (void)didChangeDirectory:(NSString *)dir onHost:(NSString *)host;

@end

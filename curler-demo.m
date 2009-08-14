//
//  curler-demo.m
//  curler
//
//  Created by Gregory Barchard on 8/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "curler-demo.h"


@implementation curler_demo

// Synthesize the properties
@synthesize properties;
@synthesize curl_wrapper;
@synthesize items;

// Default initializer
- (id)init {
	
	if(self == [super init]) {
		
		// The properties
		properties = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
					  [NSNumber numberWithInt:21], @"port",
					  @"", @"username",
					  @"", @"host",
					  @"", @"password",
					  [NSNumber numberWithInt:0], @"selectedService", nil];
		
		// The items
		items = [[NSMutableArray alloc] initWithCapacity:0];
		
		// Init the curl wrapper for sftp and ftp communication
		curl_wrapper = [[curler alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	
	[properties release];
	[super dealloc];
}

- (void)finalize {
	
	[properties release];
	[super finalize];
}

#pragma mark - Awake from nib
- (void)awakeFromNib {
	
	// Set the palette to have the login window
	[fileView setHidden:YES];
	[palette addSubview:fileView];
	[palette addSubview:loginView positioned:NSWindowAbove relativeTo:fileView];
}

#pragma mark - IBActions
// Attempt to login/disconnect to/from the server
- (IBAction)toggleConnection:(id)sender {
	
	// If connected
	if([curl_wrapper isConnected]) {
		
		// Disconnect
		[curl_wrapper disconnect];
	} else {
		
		// Construct the url
		NSString *tmp = [NSString stringWithFormat:@"%@://%@:%@", 
						 [[connectionTypesButton titleOfSelectedItem] lowercaseString],
						 [properties objectForKey:@"host"],
						 [properties objectForKey:@"port"]];
		
		// Set the url
		[curl_wrapper setUrl:[NSURL URLWithString:tmp]];
		
		// Set the username
		[curl_wrapper setUsername:[properties objectForKey:@"username"]];
		
		// Set the password
		[curl_wrapper setPassword:[properties objectForKey:@"password"]];
		
		// Set the delegate
		[curl_wrapper setDelegate:self];
		
		// Start the progress indicator
		[connectingIndicator startAnimation:nil];
		
		// Attempt to connect
		[curl_wrapper connect];
	}
}

// Attempt to change directory on the server
- (IBAction)changeDirectory:(NSArray *)sender {
	
	// If a row was clicked in the table view (as oppposed to a table column)
	if(!IsEmpty(sender)) {
		
		// Get the item at the selected index
		NSDictionary *selectedItem = [sender objectAtIndex:0];
		
		// If the select item is a directory, change the directory
		if([[selectedItem objectForKey:@"typeString"] isEqualToString:@"directory"]) {

			// Try to change the CWD
			[curl_wrapper setRelativePath:[NSString stringWithFormat:@"%@/", 
										   [selectedItem objectForKey:@"name"]]];
		}
	}
}

// Called when a connection is made
- (void)didConnectToHost:(NSString *)host {
	NSLog(@"[%@ didConnectToHost:%@]", [self class], host);
	
	// Stop the progress indicator
	[connectingIndicator stopAnimation:nil];
	
	// Set the title of the button to 'Disconnect'
	[connectButton setTitle:@"Disconnect"];
	
	// Add the file view in place of the login view
	[loginView setHidden:YES];
	[fileView setHidden:NO];
	
	// Request the directory listing
	[self setItems:[[curl_wrapper directoryContent] mutableCopy]];
}

// Called when a disconnect is made
- (void)didDisconnectFromHost:(NSString *)host {
	NSLog(@"[%@ didDisconnectFromHost:%@]", [self class], host);
	
	// Set the title of the button to 'Connect'
	[connectButton setTitle:@"Connect"];
	
	// Hide the file view
	[fileView setHidden:YES];
	
	// Show the login view
	[loginView setHidden:NO];
	
	// Clear the items
	[self setItems:[NSArray array]];
}

// Called when an error occurs
- (void)didReceiveErrorFromHost:(NSString *)host withResponse:(NSError *)error {
	NSLog(@"[%@ didReceiveErrorFromHost:%@ withResponse:%@]", [self class], host, error);
}

// Called when the connection changes directory
- (void)didChangeDirectory:(NSString *)dir onHost:(NSString *)host {
	NSLog(@"[%@ didChangeDirectory:%@ onHost:%@]", [self class], dir, host);
	
	// Request the directory listing
	[self setItems:[[curl_wrapper directoryContent] mutableCopy]];
}

@end

// The MIT License
// 
// Copyright (c) 2009 Gregory Barchard
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//
//  curler.h
//  curler
//
//  Created by Gregory Barchard on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WFMCURLDelegateProtocol.h"
#import "cMacros.h"

// Import the curl framework
#include <curl/curl.h>

@interface curler : NSObject {
	
	// The properties
	NSString		*username;
	NSString		*password;
	NSString		*path;
	NSURL			*url;
	
	// Connection data
	NSArray			*directoryContent;
	
	// The curl object
	CURL	*curl;
	
	// The delegate
	id		delegate;
}
@property (readwrite, assign) id delegate;
@property (readwrite, retain) NSString *username;
@property (readwrite, retain) NSString *password;
@property (readwrite, retain) NSString *path;
@property (readwrite, retain) NSURL *url;
@property (readwrite, retain) NSArray *directoryContent;

// Init with a valid NSURL
- (id)initWithURL:(NSURL *)aURL;

// Init with url, username, and password
- (id)initWithURL:(NSURL *)aURL username:(NSString *)aUsername andPassword:(NSString *)aPassword;

#pragma mark - Connection methods
// Connect to the host
- (void)connect;

// Disconnect from the host
- (void)disconnect;

// Connection status
- (BOOL)isConnected;

// Refresh the directory contents
- (void)refreshDirectoryContent;

#pragma mark - Utility methods
// Parse directory data 
- (NSArray *)parseDirectoryData:(NSData *)data;

// Convert data to string
- (NSString *)dataToString:(NSData *)data;

// Parse directory items into an array
- (NSArray *)parseDirectoryString:(NSString *)str;

// Parse directory entry to dictionary
- (NSDictionary *)parseDirectoryEntry:(NSString *)entry;

// Return the permissions from string
- (NSUInteger)integerPermissionsFromString:(NSString *)str;

// Seperate the string by newlines
- (NSArray *)seperateStringWithNewlines:(NSString *)str;

#pragma mark - Private response handlers
// Handler for curl responses
size_t _curlResponseHandler(void *buffer, size_t size, size_t nmemb, void *stream);

@end

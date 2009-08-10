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
//  curler.m
//  curler
//
//  Created by Gregory Barchard on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "curler.h"


@implementation curler
// Synthesize the properties
@synthesize delegate;
@synthesize username;
@synthesize password;
@synthesize path;
@synthesize url;
@synthesize directoryContent;

// Init
- (id)init {
	
	// Call the super class' implementation
	if(self == [super init]) {
		
	}
	
	// Return self
	return self;
}

// Init with a valid NSURL
- (id)initWithURL:(NSURL *)aURL {
	
	// Call the super class' implementation
	if(self == [super init]) {
		
		// Set the properties
		[self setUrl:aURL];
		
		curl = nil;
	}
	
	// Return self
	return self;
}

// Init with url, username, and password
- (id)initWithURL:(NSURL *)aURL username:(NSString *)aUsername andPassword:(NSString *)aPassword {
	
	// Call the initializer
	if(self == [self initWithURL:aURL]) {
		
		// Set the properties
		[self setUsername:aUsername];
		[self setPassword:aPassword];
	}
	
	// Return self
	return self;
}

// Clean up
- (void)dealloc {
	
	// If the connection is still active
	if([self isConnected]) {
		
		// Clean up the connection
		[self disconnect];
	}
	
	// Clean up the properties
	[url release];
	[username release];
	[password release];
	[directoryContent release];
	
	// Call the super class' implementation
	[super dealloc];
}

// Clean up
- (void)finalize {
	
	// If the connection is still active
	if([self isConnected]) {
		
		// Clean up the connection
		[self disconnect];
	}
	
	// Clean up the properties
	[url release];
	[username release];
	[password release];
	[directoryContent release];
	
	// Call the super class' implementation
	[super finalize];
}

// Connect to the host
- (void)connect {
	
	// Init the connection
	curl = curl_easy_init();
	
	// The response for the connection
	CURLcode response;
	
	// The data from the response
	NSMutableData *data = [NSMutableData data];
	
	//
	// Set the connection options
	//
	
	// Set the  url
	curl_easy_setopt(curl, CURLOPT_URL, [[url absoluteString] UTF8String]);
	
	// Set the username and password
	if([url user] == nil || [url password] == nil) {
		
		// Format the username and password
		NSString *tmp = [NSString stringWithFormat:@"%@:%@", username, password];
		
		// Update the curl
		curl_easy_setopt(curl, CURLOPT_USERPWD, [tmp UTF8String]);
	}
	
	//
	// Set the callbacks
	//
	
	// The callback to call when there is data to be written
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, _curlResponseHandler);
	
	// The pointer to pass to the callback
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, data);
	
	// Try to perform the connection
	response = curl_easy_perform(curl);
	
	// If we can notify the delegate of the error
	if(response != CURLE_OK && [delegate respondsToSelector:@selector(didReceiveErrorFromHost:withResponse:)]) {
		
		// The string of the response
		NSString *str_response = [NSString stringWithFormat:@"%s", curl_easy_strerror(response)];
		
		// Then perform the notification
		[delegate didReceiveErrorFromHost:[url host] 
							 withResponse:[NSError errorWithDomain:[url absoluteString]
															  code:response
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:str_response, @"CURL_RESPONSE", nil]]];
	} else {
		
		// If we can notify the delegate of the response
		if([delegate respondsToSelector:@selector(didConnectToHost:)]) {
			
			// Then perform the notification
			[delegate didConnectToHost:[url host]];
		}
		
		// Parse the data from the response
		
		// Set the directory contents
		[self setDirectoryContent:[self parseDirectoryData:data]];
	}
}

// Disconnect from the host
- (void)disconnect {
	
	// If the connection is still active
	if(curl) {
		
		// Clean up the connection
		curl_easy_cleanup(curl);
		
		// If we can notify the delegate of the response
		if([delegate respondsToSelector:@selector(didDisconnectFromHost:)]) {
			
			// Then perform the notification
			[delegate didDisconnectFromHost:[url host]];
		}
	}
}

// Connection status
- (BOOL)isConnected {
	
	// Return true if the curl obj exists
	return (curl != nil);
}

// Get the directory contents
- (void)refreshDirectoryContent {
	
	// The result to return
	/*NSMutableArray *result = [NSMutableArray array];
	 
	 // The response for the connection
	 CURLcode response;
	 
	 // Clear the data
	 [wfm_data setData:[NSData data]];
	 
	 // Create the command list
	 struct curl_slist *commands = nil;
	 
	 // Add the command to list the current directory contents
	 commands = curl_slist_append(commands, "NLST");
	 
	 // Assign the commands to the curl object
	 curl_easy_setopt(curl, CURLOPT_QUOTE, commands);
	 
	 //
	 // Set the callbacks
	 //
	 
	 // The callback to call when there is data to be written
	 curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, _curlResponseHandler);
	 
	 // The pointer to pass to the callback
	 curl_easy_setopt(curl, CURLOPT_WRITEDATA, &wfm_data);
	 
	 // Try to perform the command
	 response = curl_easy_perform(curl);
	 
	 // If we can notify the delegate of the error
	 if(response != CURLE_OK && [delegate respondsToSelector:@selector(didReceiveErrorFromHost:withResponse:)]) {
	 
	 // The string of the response
	 NSString *str_response = [NSString stringWithFormat:@"%s", curl_easy_strerror(response)];
	 
	 // Then perform the notification
	 [delegate didReceiveErrorFromHost:[url host] 
	 withResponse:[NSError errorWithDomain:[url absoluteString]
	 code:response
	 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:str_response, @"CURL_RESPONSE", nil]]];
	 }
	 
	 // Clean up the commands
	 curl_slist_free_all(commands);
	 commands = nil;*/
	
	// Return the result
	//return result;
}

#pragma mark - Utility methods
// Parse directory data 
- (NSArray *)parseDirectoryData:(NSData *)data {
	
	// Convert the data to string
	NSString *str = [self dataToString:data];
	
	// Parse the string
	return [self parseDirectoryString:str];
}

// Convert data to string
- (NSString *)dataToString:(NSData *)data {
	
	// Create an autoreleased string to return
	return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

// Parse directory items into an array
- (NSArray *)parseDirectoryString:(NSString *)str {
	
	// The result to return
	NSMutableArray *result = [NSMutableArray array];
	
	// First break the string up into individual items
	NSArray *items = [self seperateStringWithNewlines:str];
	
	// Loop over each entry 
	for(NSString *item in items) {
		
		// If the item isn't empty
		if(!IsEmpty(item)) {
			
			// Parse the item and add it to the result
			[result addObject:[self parseDirectoryEntry:item]];
		}
		
	}
	
	// Return the result
	return result;
}

// Parse directory entry to dictionary
- (NSDictionary *)parseDirectoryEntry:(NSString *)entry {
	
	// The result
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	// A scanner to use to get the number of files
	NSScanner *scanner = [NSScanner scannerWithString:entry];
	
	// Get the permissions portion
	NSString *tmp;
	
	// Scan the permissions portion
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
	
	// GUIDE: (source: http://www.linux.ucla.edu/guides/unixbasics.php3)
	// Sample "ls -l /bin/ls" output: -rwxr-xr-x 1 root root 29980 Apr 23 1998 /bin/ls
	//      - First ten characters are the file's permissions. First is file type, '-' for normal, 'd' for directory, 'l' for symlink, etc. 
	//      - Three sets of three characters of "rwx", or Read, Write, Execute permission - first for owner, then group owner, then everyone. 
	//      - Then we have number of links to file, owner of the file, group owner of file, file size, date it was last modified, and the file's name.
	
	// Get if the entry is a file, folder or symlink
	NSString *type = [tmp substringToIndex:1];
	
	// If the type is -
	if([type isEqualToString:@"-"]) {
		
		// It is a file
		[result setObject:@"file" forKey:@"typeString"];
		[result setObject:[NSNumber numberWithInt:0] forKey:@"typeNumber"];
		
	} else if([type isEqualToString:@"d"]) {
		
		// It is a directory
		[result setObject:@"directory" forKey:@"typeString"];
		[result setObject:[NSNumber numberWithInt:1] forKey:@"typeNumber"];
		
	} else {
		
		// It is a symlink
		[result setObject:@"symlink" forKey:@"typeString"];
		[result setObject:[NSNumber numberWithInt:2] forKey:@"typeNumber"];
	}
	
	// The range to use for the permissions
	// Source: http://www.zzee.com/solutions/unix-permissions.shtml
	
	// The permissions
	NSString *permissionsStr = [tmp substringWithRange:NSMakeRange(1, [tmp length] - 1)];
	
	// The permissions in int form
	NSUInteger permissionsInt = [self integerPermissionsFromString:tmp];
	
	// Set the permissions
	[result setObject:permissionsStr forKey:@"permissionsString"];
	[result setObject:[NSNumber numberWithInt:permissionsInt] forKey:@"permissionsNumber"];
	
	// Scan the number of files linking
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
	[result setObject:[NSNumber numberWithInt:[tmp intValue]] forKey:@"numberOfLinkingFiles"];
	
	// Scan for the owner
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
	[result setObject:tmp forKey:@"owner"];
	
	// Scan for the group
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
	[result setObject:tmp forKey:@"group"];
	
	// Scan for the size
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
	[result setObject:tmp forKey:@"size"];
	
	// Scan for the modification date
	NSMutableString *date_string = [NSMutableString string];
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
	[date_string appendString:tmp];
	
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
	[date_string appendFormat:@" %@", tmp];
	
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
	[date_string appendFormat:@" %@", tmp];
	
	[result setObject:[NSDate dateWithNaturalLanguageString:date_string] forKey:@"modificationDate"];
	
	// Scan for the name
	
	// If the entry is a symbolic link
	if([type isEqualToString:@"l"]) {
		
		// The symlinks look like www -> public_html
		[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
		[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tmp];
	}
	
	// Scan the rest of the characters until the newline
	[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&tmp];
	[result setObject:tmp forKey:@"name"];
	
	// Return the result
	return result;
}

// Return the permissions from string
- (NSUInteger)integerPermissionsFromString:(NSString *)str {
	
	// The permissions in int form
	NSUInteger result = 0;
	NSUInteger i;
	
	// Loop over each grouping (owner, group, and world)
	for(i = 0; i < 3; i++) {
		
		// The range is going to shift for each group but always be 3 long
		NSRange range = NSMakeRange(1 + 3*i, 3);
		
		// The permissions substring
		NSString *permissionsSubstring = [str substringWithRange:range];
		
		// Multiplication factor
		NSUInteger factor = pow(10, (2 - i));
		
		// Determine the permissions - read
		if([permissionsSubstring characterAtIndex:0] == 'r') {
			
			// Update the permissions
			result += factor*4;
		}
		
		// Determine the permissions - write
		if([permissionsSubstring characterAtIndex:1] == 'w') {
			
			// Update the permissions
			result += factor*2;
		}
		
		// Determine the permissions - execute
		if([permissionsSubstring characterAtIndex:2] == 'x') {
			
			// Update the permissions
			result += factor;
		}
	}
	
	// Return the result
	return result;
}

// Seperate the string by newlines
- (NSArray *)seperateStringWithNewlines:(NSString *)str {
	
	// Return the string seperated with new lines
	return (str ? [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] : [NSArray array]);
}

#pragma mark - Private response handlers
// Handler for curl responses
size_t _curlResponseHandler(void *buffer, size_t size, size_t nmemb, void *stream) {
	
	// Set the data	
	NSMutableData *data = (NSMutableData *)stream;
	[data appendBytes:buffer length:(size*nmemb)];
	
	// Return the number of bytes processed = num of bytes * size of a byte
	return size*nmemb;
}
@end

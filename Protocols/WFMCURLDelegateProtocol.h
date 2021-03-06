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

/*
 *  WFMCURLDelegateProtocol.h
 *  curler
 *
 *  Created by Gregory Barchard on 8/10/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

@protocol WFMCURLDelegateProtocol <NSObject>

// Called when a connection is made
- (void)didConnectToHost:(NSString *)host;

// Called when a disconnect is made
- (void)didDisconnectFromHost:(NSString *)host;

// Called when an error occurs
- (void)didReceiveErrorFromHost:(NSString *)host withResponse:(NSError *)error;

// Called when the connection changes directory
- (void)didChangeDirectory:(NSString *)dir onHost:(NSString *)host;
@end
// main.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDApplication.h"

int main(int argc, const char *argv[]) {
    CDApplication *application = [CDApplication sharedApplication];
    [application setDelegate:NSApp];
    [application run];
}

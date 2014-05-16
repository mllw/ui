/* 28 february 2014 */

/*
I wanted to avoid invoking Objective-C directly, preferring to do everything directly with the API. However, there are some things that simply cannot be done too well; for those situations, there's this. It does use the Objective-C runtime, eschewing the actual Objective-C part of this being an Objective-C file.

The main culprits are:
- data types listed as being defined in nonexistent headers
- 32-bit/64-bit type differences that are more than just a different typedef
- wrong documentation
though this is not always the case.
*/

#include "objc_darwin.h"

#include <stdlib.h>

#include <Foundation/NSGeometry.h>
#include <AppKit/NSKeyValueBinding.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSGraphics.h>
#include <AppKit/NSBitmapImageRep.h>
#include <AppKit/NSCell.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSTrackingArea.h>

/*
These are all the selectors and class IDs used by the functions below.
*/

static id c_NSEvent;				/* makeDummyEvent() */
static SEL s_newEvent;
static id c_NSBitmapImageRep;	/* drawImage() */
static SEL s_alloc;
static SEL s_initWithBitmapDataPlanes;
static SEL s_drawInRect;
static SEL s_release;
static SEL s_locationInWindow;		/* getTranslatedEventPoint() */
static SEL s_convertPointFromView;
static id c_NSFont;
static SEL s_setFont;				/* objc_setFont() */
static SEL s_systemFontOfSize;
static SEL s_systemFontSizeForControlSize;
static id c_NSTrackingArea;
static SEL s_bounds;
static SEL s_initTrackingArea;

void initBleh()
{
	c_NSEvent = objc_getClass("NSEvent");
	s_newEvent = sel_getUid("otherEventWithType:location:modifierFlags:timestamp:windowNumber:context:subtype:data1:data2:");
	c_NSBitmapImageRep = objc_getClass("NSBitmapImageRep");
	s_alloc = sel_getUid("alloc");
	s_initWithBitmapDataPlanes = sel_getUid("initWithBitmapDataPlanes:pixelsWide:pixelsHigh:bitsPerSample:samplesPerPixel:hasAlpha:isPlanar:colorSpaceName:bitmapFormat:bytesPerRow:bitsPerPixel:");
	s_drawInRect = sel_getUid("drawInRect:fromRect:operation:fraction:respectFlipped:hints:");
	s_release = sel_getUid("release");
	s_locationInWindow = sel_getUid("locationInWindow");
	s_convertPointFromView = sel_getUid("convertPoint:fromView:");
	c_NSFont = objc_getClass("NSFont");
	s_setFont = sel_getUid("setFont:");
	s_systemFontOfSize = sel_getUid("systemFontOfSize:");
	s_systemFontSizeForControlSize = sel_getUid("systemFontSizeForControlSize:");
	c_NSTrackingArea = objc_getClass("NSTrackingArea");
	s_bounds = sel_getUid("bounds");
	s_initTrackingArea = sel_getUid("initWithRect:options:owner:userInfo:");
}

/*
See uitask_darwin.go: we need to synthesize a NSEvent so -[NSApplication stop:] will work. We cannot simply init the default NSEvent though (it throws an exception) so we must do it "the right way". This involves a very convoluted initializer; we'll just do it here to keep things clean on the Go side (this will only be run once anyway, on program exit).
*/

id makeDummyEvent()
{
	return objc_msgSend(c_NSEvent, s_newEvent,
		(NSUInteger) NSApplicationDefined,			/* otherEventWithType: */
		NSMakePoint(0, 0),						/* location: */
		(NSUInteger) 0,							/* modifierFlags: */
		(double) 0,							/* timestamp: */
		(NSInteger) 0,							/* windowNumber: */
		nil,									/* context: */
		(short) 0,								/* subtype: */
		(NSInteger) 0,							/* data1: */
		(NSInteger) 0);							/* data2: */
}

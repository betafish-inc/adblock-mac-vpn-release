//
//  PFMoveApplication.h, version 1.25
//  LetsMove
//
//  Created by Andy Kim at Potion Factory LLC on 9/17/09
//
//  The contents of this file are dedicated to the public domain.

/*
 AdBlock VPN Changelog

 Normally this framework will automatically check if app is located within the Applications folder,
 then present an `NSAlert` prompting user with an option to move to Application folder.
 Updated functionality to remove `NSAlert` presentation and expose `MoveToApplicationsFolderIfNecessary` method in the header.
 This is so we can check if app is within the application folder outside of this framework, and conditionally present our own custom UI to perform the move.

 * Added `PFMoveToApplicationsFolderIfNecessary` to header file.
 * Removed `NSAlert` confirmation from `PFMoveToApplicationsFolderIfNecessary` method.
 * Removed unused strings related to the `NSAlert`
 * Removed unused method `IsInDownloadsFolder` (this was used to show alternative strings in the NSAlert)
 */

#ifdef __cplusplus
extern "C" {
#endif
	
#import <Foundation/Foundation.h>

/**
 Moves the running application to ~/Applications or /Applications if the former does not exist.
 After the move, it relaunches app from the new location.
 DOES NOT work for sandboxed applications.*/
void PFMoveToApplicationsFolderIfNecessary(void);

/// Returns YES if file at path specified is located within an NSApplicationDirectory
/// @param path Filepath to a file to check
BOOL PFIsInApplicationsFolder(NSString *path);

/**
 Check whether an app move is currently in progress.
 Returns YES if LetsMove is currently in-progress trying to move the app to the Applications folder, or NO otherwise.
 This can be used to work around a crash with apps that terminate after last window is closed.
 See https://github.com/potionfactory/LetsMove/issues/64 for details. */
BOOL PFMoveIsInProgress(void);

#ifdef __cplusplus
}
#endif

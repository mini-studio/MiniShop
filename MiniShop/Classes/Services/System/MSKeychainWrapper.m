//
//  MSKeychainWrapper.m
//  MiniShop
//
//  Created by Wuquancheng on 13-10-13.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSKeychainWrapper.h"
#import <Security/Security.h>

static const UInt8 kKeychainItemIdentifier[]    = "com.apple.dts.KeychainUI\0";

@interface MSKeychainWrapper ()
//The following two methods translate dictionaries between the format used by
// the view controller (NSString *) and the Keychain Services API:
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;
// Method used to write data to the keychain:
- (void)writeToKeychain;

@end

@implementation MSKeychainWrapper

- (id)init
{
    if ((self = [super init])) {
        
        OSStatus keychainErr = noErr;
        // Set up the keychain search dictionary:
        self.genericPasswordQuery = [[NSMutableDictionary alloc] init];
        // This keychain item is a generic password.
        [self.genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword  forKey:(__bridge id)kSecClass];
        // The kSecAttrGeneric attribute is used to store a unique string that is used
        // to easily identify and find this keychain item. The string is first
        // converted to an NSData object:
        NSData *keychainItemID = [NSData dataWithBytes:kKeychainItemIdentifier length:strlen((const char *)kKeychainItemIdentifier)];
        [self.genericPasswordQuery setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
        // Return the attributes of the first match only:
        [self.genericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        // Return the attributes of the keychain item (the password is
        //  acquired in the secItemFormatToDictionary: method):
        [self.genericPasswordQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
        
        //Initialize the dictionary used to hold return data from the keychain:
        NSMutableDictionary *outDictionary = nil;
        // If the keychain item exists, return the attributes of the item:
        keychainErr = SecItemCopyMatching((__bridge CFDictionaryRef)self.genericPasswordQuery, (void *)&outDictionary);
        if (keychainErr == noErr) {
            // Convert the data dictionary into the format used by the view controller:
            self.keychainData = [self secItemFormatToDictionary:outDictionary];
        } else if (keychainErr == errSecItemNotFound) {
            // Put default values into the keychain if no matching
            // keychain item is found:
            [self resetKeychainItem];
        } else {
            // Any other error is unexpected.
            NSAssert(NO, @"Serious error.\n");
        }
    }
    return self;
}

- (void)setObject:(id)inObject forKey:(id)key
{
    if (inObject == nil) return;
    id currentObject = [_keychainData objectForKey:key];
    if (![currentObject isEqual:inObject])
    {
        [_keychainData setObject:inObject forKey:key];
        [self writeToKeychain];
    }
}

- (id)objectForKey:(id)key
{
    return [_keychainData objectForKey:key];
}

- (void)resetKeychainItem
{
    if (!_keychainData) //Allocate the keychainData dictionary if it doesn't exist yet.
    {
        self.keychainData = [[NSMutableDictionary alloc] init];
    }
    else if (_keychainData)
    {
        // Format the data in the keychainData dictionary into the format needed for a query
        //  and put it into tmpDictionary:
        NSMutableDictionary *tmpDictionary = [self dictionaryToSecItemFormat:_keychainData];
        // Delete the keychain item in preparation for resetting the values:
        NSAssert(SecItemDelete(CFBridgingRetain(tmpDictionary)) == noErr, @"Problem deleting current keychain item." );
    }
    
    // Default generic data for Keychain Item:
    [_keychainData setObject:@"Item label" forKey:(__bridge id)kSecAttrLabel];
    [_keychainData setObject:@"Item description" forKey:(__bridge id)kSecAttrDescription];
    [_keychainData setObject:@"Account" forKey:(__bridge id)kSecAttrAccount];
    [_keychainData setObject:@"Service" forKey:(__bridge id)kSecAttrService];
    [_keychainData setObject:@"Your comment here." forKey:(__bridge id)kSecAttrComment];
    [_keychainData setObject:@"password" forKey:(__bridge id)kSecValueData];
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
{
    // This method must be called with a properly populated dictionary
    // containing all the right key/value pairs for the keychain item.
    
    // Create a return dictionary populated with the attributes:
    NSMutableDictionary *returnDictionary = [NSMutableDictionary
                                             dictionaryWithDictionary:dictionaryToConvert];
    
    // To acquire the password data from the keychain item,
    // first add the search key and class attribute required to obtain the password:
    [returnDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    // Then call Keychain Services to get the password:
    NSData *passwordData = NULL;
    OSStatus keychainError = noErr; //
    keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary,(void *)&passwordData);
    if (keychainError == noErr)
    {
        // Remove the kSecReturnData key; we don't need it anymore:
        [returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];
        
        // Convert the password to an NSString and add it to the return dictionary:
        NSString *password = [[NSString alloc] initWithBytes:[passwordData bytes]
                                                       length:[passwordData length] encoding:NSUTF8StringEncoding];
        [returnDictionary setObject:password forKey:(__bridge id)kSecValueData];
    }
    // Don't do anything if nothing is found.
    else if (keychainError == errSecItemNotFound) {
        NSAssert(NO, @"Nothing was found in the keychain.\n");
    }
    // Any other error is unexpected.
    else
    {
        NSAssert(NO, @"Serious error.\n");
    }
    
    return returnDictionary;
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
    // This method must be called with a properly populated dictionary
    // containing all the right key/value pairs for a keychain item search.
    
    // Create the return dictionary:
    NSMutableDictionary *returnDictionary =
    [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    
    // Add the keychain item class and the generic attribute:
    NSData *keychainItemID = [NSData dataWithBytes:kKeychainItemIdentifier
                                            length:strlen((const char *)kKeychainItemIdentifier)];
    [returnDictionary setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    // Convert the password NSString to NSData to fit the API paradigm:
    NSString *passwordString = [dictionaryToConvert objectForKey:(__bridge id)kSecValueData];
    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding]
                         forKey:(__bridge id)kSecValueData];
    return returnDictionary;
}

- (void)writeToKeychain
{
    NSDictionary *attributes = nil;
    NSMutableDictionary *updateItem = nil;
    
    // If the keychain item already exists, modify it:
    if (SecItemCopyMatching((__bridge CFDictionaryRef)_genericPasswordQuery, (void *)&attributes) == noErr)
    {
        // First, get the attributes returned from the keychain and add them to the
        // dictionary that controls the update:
        updateItem = [NSMutableDictionary dictionaryWithDictionary:attributes];
        
        // Second, get the class value from the generic password query dictionary and
        // add it to the updateItem dictionary:
        [updateItem setObject:[_genericPasswordQuery objectForKey:(__bridge id)kSecClass]  forKey:(__bridge id)kSecClass];
        
        // Finally, set up the dictionary that contains new values for the attributes:
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:_keychainData];
        //Remove the class--it's not a keychain attribute:
        [tempCheck removeObjectForKey:(__bridge id)kSecClass];
        
        // You can update only a single keychain item at a time.
        NSAssert(SecItemUpdate((CFDictionaryRef)CFBridgingRetain(updateItem), (CFDictionaryRef)CFBridgingRetain(tempCheck)) == noErr,
                 @"Couldn't update the Keychain Item." );
    }
    else
    {
        // No previous item found; add the new item.
        // The new value was added to the keychainData dictionary in the mySetObject routine,
        //  and the other values were added to the keychainData dictionary previously.
        
        // No pointer to the newly-added items is needed, so pass NULL for the second parameter:
        CFTypeRef result;
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:_keychainData], &result);
        NSAssert( status == noErr, @"Couldn't add the Keychain Item." );
    }
}

@end

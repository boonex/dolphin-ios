//
//  LoginController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/19/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "LoginController.h"
#import "HomeController.h"
#import "AboutController.h"
#import "Dolphinusers.h"
#import "Designer.h"

@interface LoginController () <FBSDKLoginButtonDelegate>

@end

@implementation LoginController

- (id)initWithUserObject:(BxUser*)anUser {
	
	if ((self = [super initWithNibName:@"LoginView" bundle:nil withUser:anUser])) {
		
	}
	return self;
	
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	    
    self.navigationItem.title = user.strSite;
    
    textDomain.text = user.strSite;
    textUsername.text = user.strUsername;
    textPassword.text = user.rememberPassword ? user.strPwdHash : @"";
	
    NSString *sSiteUrlCorrected = [user.connector getXmlRpcUrlForSite:user.strSite];
    
    NSLog(@"SITE - %@", sSiteUrlCorrected);
    
    NSString *sAboutText = [NSString stringWithFormat:NSLocalizedString(@"Terms And Privacy", @"Terms & Privacy Links"), sSiteUrlCorrected, sSiteUrlCorrected];
	[htmlTerms loadHTMLString:sAboutText baseURL:nil];
    htmlTerms.opaque = NO;
    htmlTerms.backgroundColor = [UIColor clearColor];
    
	[Designer applyStylesForTextEdit:textDomain];
	[Designer applyStylesForTextEdit:textUsername];
	[Designer applyStylesForTextEdit:textPassword];
    [Designer applyStylesForButton:buttonLogin];
		
	textDomain.placeholder = NSLocalizedString(@"Site URL", @"Site URL field name");
	textUsername.placeholder = NSLocalizedString(@"Username", @"Username field name");
	textPassword.placeholder = NSLocalizedString(@"Password", @"Password field name");
	[buttonLogin setTitle:NSLocalizedString(@"Login", @"Login button title") forState:UIControlStateNormal];
    
	[Designer applyStylesForScreen:self.view];
	[Designer applyStylesForContainer:viewContainer];
    [Designer applyStylesForContainer:viewContainerFacebook];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (user.strPwdHash.length > 0 && YES == user.rememberPassword) {
        [self actionLogin:nil];
    } else {
        // check login and password
        NSArray *myArray = [NSArray arrayWithObjects:@"facebook_connect", @"supported", [NSArray array], @"Module", nil];
        [self addProgressIndicator];
        [user.connector execAsyncMethod:@"dolphin.service" withParams:myArray withSelector:@selector(callbackFacebookSupported:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
    }
}

- (void)dealloc {
    
    [viewFacebookLogin release];
    
	[textDomain release];
	[textUsername release];
	[textPassword release];
    [buttonLogin release];
    [htmlTerms release];
		
    [viewContainerFacebook release];
    [viewContainer release];
    [viewScroll release];
    
	[super dealloc];
}

/**************************************************************************************************************
 CUSTOM FUNCTIONS
 **************************************************************************************************************/

#pragma mark - Custom Funtions

/**
 * generate MD5 hash from gives string
 */ 
- (NSString*)md5:(NSString*)str {
	char buff[128];
	unsigned char md[CC_MD5_DIGEST_LENGTH];	
	
	bzero(md, CC_MD5_DIGEST_LENGTH);
	[str getCString:buff maxLength:128 encoding:NSASCIIStringEncoding];
	CC_MD5((const void *)buff, strlen(buff), md); 
	
	bzero(buff,128);
	for (int i=0; i<CC_MD5_DIGEST_LENGTH; ++i)
	{
		int x = md[i];
		sprintf(buff, "%s%02x", buff, x);
	}
	
	NSString *stringPasswordMD5 = [NSString stringWithCString:buff encoding:NSASCIIStringEncoding];
	return stringPasswordMD5;
}

- (void)addProgressIndicator
{
    [super addProgressIndicator];
    buttonLogin.enabled = NO;
}

- (void)removeProgressIndicator
{
    [super removeProgressIndicator];
    buttonLogin.enabled = YES;
}

- (void)createFacebookButton {
    
    if (viewFacebookLogin != nil)
        return;
        
    viewFacebookLogin = [[FBSDKLoginButton alloc] init];
  
    viewFacebookLogin.delegate = self;
    
    viewFacebookLogin.readPermissions = @[@"public_profile", @"email", @"user_friends"];

    viewFacebookLogin.center = CGPointMake(viewContainerFacebook.frame.size.width/2, viewContainerFacebook.frame.size.height/2);
    
    viewFacebookLogin.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [viewContainerFacebook addSubview:viewFacebookLogin];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * login action - user press login/save button
 */
- (void)actionLoginWithFacebookUser:(id) userFacebook token:(NSString*)sToken {

	// hide keyboard
	[textPassword resignFirstResponder];
	[textUsername resignFirstResponder];
	[textDomain resignFirstResponder];

    NSLog(@"Facebook profile: %@", userFacebook);
    
	NSArray *myArray = [NSArray arrayWithObjects:@"facebook_connect", @"login", [NSArray arrayWithObjects:userFacebook, sToken, nil], @"Module", nil];
	
    user.strUsername = @"";
    user.strPwdHash = @"";
    
	[self addProgressIndicator];
	
	[user.connector execAsyncMethod:@"dolphin.service" withParams:myArray withSelector:@selector(callbackLogin4:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

/**
 * login action - user press login/save button
 */
- (IBAction)actionLogin:(id)sender {
    
    
	NSString *stringDomain = nil != textDomain ? textDomain.text : user.strSite;
	NSString *stringUsername = nil != textUsername ? textUsername.text : user.strUsername;
	NSString *stringPassword = nil != textPassword ? textPassword.text : (user.rememberPassword ? user.strPwdHash : @"");

	// check inputed values 
	if (stringUsername.length == 0 || stringPassword.length == 0 || stringDomain.length == 0)
	{
        [self showErrorAlert:NSLocalizedString(@"Username, Password or Domain can not be empty", @"Not all fields are filled on Login/Add Site pages error message")];
		return;
	}
	
	// hide keyboard	
	[textPassword resignFirstResponder];
	[textUsername resignFirstResponder];
	[textDomain resignFirstResponder];
	
	// check login and password	 
	NSArray *myArray = [NSArray arrayWithObjects:stringUsername, stringPassword, nil];
	
	
    user.strUsername = stringUsername;
	user.rememberPassword = YES;
		
	[self addProgressIndicator];
	
	NSLog(@"dolphin.login4 (%@, %@)", stringUsername, stringPassword);
	[user.connector execAsyncMethod:@"dolphin.login4" withParams:myArray withSelector:@selector(callbackLogin4:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

/**
 * callback function on login
 */
- (void)callbackLogin4:(id)idData {
    
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
    
    NSLog(@"Login4 responce: %@ (%@)", resp, [resp class]);
    
    if ([resp isKindOfClass:[NSMutableDictionary class]] && nil != [resp valueForKey:@"error"]) {
        
        Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
        [app logoutFB];
        
        [self removeProgressIndicator];
        [self showErrorAlert:[resp valueForKey:@"error"]];
        
    }
    else if([resp isKindOfClass:[NSError class]] || ([resp isKindOfClass:[NSMutableDictionary class]] && nil != [resp valueForKey:@"faultString"]))
	{
        [self removeProgressIndicator];
        [self addProgressIndicator];
		
        NSLog(@"Old protocol is detected, trying with old method call...");
        
        NSString *stringPassword = textPassword.text;
        NSString *stringPasswordMD5 = 32 == stringPassword.length ? stringPassword : [self md5:stringPassword];
        
        user.strPwdHash = stringPasswordMD5;
        
        NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, nil];
        
        NSLog(@"dolphin.login2 (%@, %@)", user.strUsername, user.strPwdHash);
        [user.connector execAsyncMethod:@"dolphin.login2" withParams:myArray withSelector:@selector(callbackLogin2:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
        
	}
    else
    {
        if ([resp isKindOfClass:[NSMutableDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)resp;
            
            NSString *sPwdHash = [dict valueForKey:@"member_pwd_hash"];
            NSString *sUsername = [dict valueForKey:@"member_username"];
            
            if (sUsername != nil)
                user.strUsername = sUsername;
            
            if (sPwdHash != nil)
                user.strPwdHash = sPwdHash;
        }
        
        [self callbackLogin:idData];
    }
}

/**
 * callback function on login 
 */
- (void)callbackLogin2:(id)idData {	
	
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
    
    NSLog(@"Login2 responce: %@ (%@)", resp, [resp class]);
    
	// if error occured or returned members' id is 0 - show "login failed" popup 
	if([resp isKindOfClass:[NSError class]] || ([resp isKindOfClass:[NSMutableDictionary class]] && nil != [resp valueForKey:@"faultString"]))
	{		
        [self removeProgressIndicator];
        [self addProgressIndicator];
		
        NSLog(@"Old protocol is detected, trying with old method call...");
        
        NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, nil];
        
        NSLog(@"dolphin.login (%@, %@)", user.strUsername, user.strPwdHash);
        [user.connector execAsyncMethod:@"dolphin.login" withParams:myArray withSelector:@selector(callbackLogin:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	}
    else
    {
        [self callbackLogin:idData];
    }
}
/**
 * callback function on login 
 */
- (void)callbackLogin:(id)idData {
	
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
	
	[self removeProgressIndicator];
	
    NSLog(@"Login responce: %@ (%@)", resp, [resp class]);
    
	// if error occured or returned members' id is 0 - show "login failed" popup 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self responce:resp];
		return;
	}

    int iMemberId;
    int iProtocolVer = 1;
    if ([resp isKindOfClass:[NSMutableDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)resp;        
        NSString *sMemberId = (NSString *)[dict valueForKey:@"member_id"];
        NSString *sProtocolVer = (NSString *)[dict valueForKey:@"protocol_ver"];
        iMemberId = [sMemberId intValue];
        iProtocolVer = [sProtocolVer intValue];
    } else {
        iMemberId = [resp intValue];
    }
    
    NSLog(@"member:%d     protocol:%d", iMemberId, iProtocolVer);
    
    if(0 == iMemberId)
	{
		// login failed
        [self showErrorAlert:NSLocalizedString(@"Login failed", @"Login failed error text")];
		return;
	}

	user.intId = iMemberId;
	user.rememberPassword = YES;
    user.intProtocolVer = iProtocolVer;
        
     
	DolphinUsers *users = [DolphinUsers sharedDolphinUsers];	
	
	if (nil == user) {		
		[users addUser:user];
	}
	
	[users saveUsers];
	
    [resp release];
    
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
    [app login:user];
}

/**
 * callback function on login
 */
- (void)callbackFacebookSupported:(id)idData {
    
    [self removeProgressIndicator];
    
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
    
    NSLog(@"facebook supported responce: %@ (%@)", resp, [resp class]);
    
	if (![resp isKindOfClass:[NSString class]] || 1 != [resp intValue])
        return;
	   
    viewContainerFacebook.hidden = NO;
    
    [self createFacebookButton];
}


/**********************************************************************************************************************
 DELEGATES: UITextField
 **********************************************************************************************************************/

#pragma mark - UITextField Delegates

/**
 * when user press return button jump to next field or hide keyboard in login form 
 */
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == textDomain) {
        [textUsername becomeFirstResponder];
    }	
    if (theTextField == textUsername) {		
        [textPassword becomeFirstResponder];
    }
    else if (theTextField == textPassword) {
        [textPassword resignFirstResponder];
    }
	
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)theTextField {
	return true;
}


/*********************************************************************************************************
 DELEGATES: UIWebView
 *********************************************************************************************************/

#pragma mark - Delegates

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType; {
    NSURL *requestURL = [[request URL] retain];
    if (([[requestURL scheme] isEqualToString:@"http"] || [[requestURL scheme] isEqualToString:@"https"] || [[requestURL scheme] isEqualToString:@"mailto"])
        && (navigationType == UIWebViewNavigationTypeLinkClicked)) {
        return ![[UIApplication sharedApplication] openURL:[requestURL autorelease]];
    }
    [requestURL release];
    return YES;
}


/**********************************************************************************************************************
 DELEGATES: FB
 **********************************************************************************************************************/

#pragma mark - FBSDKLoginButtonDelegate


- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
    if (error != nil) {
        [BxConnector showErrorAlertWithDelegate:self responce:error];
        return;
    }

    if (result.isCancelled) {
        [BxConnector showErrorAlertWithDelegate:self];
        return;
    }

    LoginController *loginController = self;
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=name,email,first_name,last_name,gender" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            if (error) {
                [BxConnector showErrorAlertWithDelegate:self responce:error];
                return;
            }
            
            [loginController actionLoginWithFacebookUser:result token:[FBSDKAccessToken currentAccessToken].tokenString];
         }];
    }
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}


@end
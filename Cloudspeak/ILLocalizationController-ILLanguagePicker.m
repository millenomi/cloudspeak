//
//  ILLocalizationController-ILLanguagePicker.m
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILLocalizationController-ILLanguagePicker.h"

static NSArray* ILIdentifierComponentsForPreferredLanguages() {
	static NSArray* it = nil; if (!it) {
		NSArray* langs = [NSLocale preferredLanguages];
		
		NSMutableArray* a = [NSMutableArray arrayWithCapacity:[langs count]];
		for (NSString* lang in langs) {
			[a addObject:[NSLocale componentsFromLocaleIdentifier:lang]];
		}
		
		it = [a copy];
	}
	
	return it;
}

NSInteger ILLanguageMatchDegree(NSString* candidate, NSString* match) {
	return ILIdentifierComponentsMatchDegree([NSLocale componentsFromLocaleIdentifier:candidate], [NSLocale componentsFromLocaleIdentifier:match]);
}

enum {
	kILIdentifierComponentsVariantAndLanguageMatch = 800,
	kILIdentifierComponentsRegionMatch = 500,
	kILIdentifierComponentsLanguageMatch = 300,
};

NSInteger ILIdentifierComponentsMatchDegree(NSDictionary* candidate, NSDictionary* match) {
	// MATCH DEGREES
	// given match == zh_TW-Hant
	// zh_TW-Hant --> kILIdentifierComponentsPerfectMatch
	// zh-Hant --> kILIdentifierComponentScriptAndLanguageMatch
	// zh_TW --> kILIdentifierComponentRegionMatch
	// zh --> kILIdentifierComponentLanguageMatch
	// it --> kILIdentifierComponentNoMatch
	
	NSString* candidateLanguage = [candidate objectForKey:NSLocaleLanguageCode],
		* matchLanguage = [match objectForKey:NSLocaleLanguageCode];
	NSString* candidateCountry = [candidate objectForKey:NSLocaleCountryCode],
		* matchCountry = [match objectForKey:NSLocaleCountryCode];
	// UGLY HACK WARNING
	NSString* candidateScript = [([candidate objectForKey:NSLocaleVariantCode] ?: [candidate objectForKey:NSLocaleScriptCode]) uppercaseString],
		* matchScript = [([match objectForKey:NSLocaleVariantCode] ?: [match objectForKey:NSLocaleScriptCode]) uppercaseString];
	
	BOOL languageMatches = (!candidateLanguage && !matchLanguage) || (matchLanguage && [candidateLanguage isEqual:matchLanguage]);
	BOOL countryMatches = (!candidateCountry && !matchCountry) || (matchCountry && [candidateCountry isEqual:matchCountry]);
	BOOL scriptMatches = (!candidateScript && !matchScript) || (matchScript && [candidateScript isEqual:matchScript]);
	
	if (!languageMatches)
		return kILIdentifierComponentsNoMatch;
	
	if (countryMatches && scriptMatches)
		return kILIdentifierComponentsPerfectMatch;
	else if (scriptMatches)
		return kILIdentifierComponentsVariantAndLanguageMatch;
	else if (countryMatches)
		return kILIdentifierComponentsRegionMatch;
	else
		return kILIdentifierComponentsLanguageMatch;
	
#undef ILIdentifierComponentsMatching
}

@implementation ILLocalizationController (ILLanguagePicker)

- (NSInteger) indexOfPreferredLanguageAmongLanguages:(NSArray*) langs;
{
	NSArray* preferredComps = ILIdentifierComponentsForPreferredLanguages();
	
	for (NSDictionary* preference in preferredComps) {		
		NSInteger i = 0;
		NSInteger bestMatch = NSNotFound;
		NSInteger bestMatchDegree = kILIdentifierComponentsNoMatch;

		for (NSString* lang in langs) {
			NSDictionary* components = [NSLocale componentsFromLocaleIdentifier:lang];
			
			NSInteger matchDegree = ILIdentifierComponentsMatchDegree(components, preference);
			
			if (matchDegree == kILIdentifierComponentsPerfectMatch)
				return i;
			
			if (matchDegree > bestMatchDegree)
				bestMatch = i;

			i++;
		}
		
		if (bestMatch != NSNotFound && bestMatchDegree > kILIdentifierComponentsNoMatch)
			return bestMatch;
	}
	
	return NSNotFound;
}

@end

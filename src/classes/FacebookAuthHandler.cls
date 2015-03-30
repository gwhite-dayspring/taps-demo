global class FacebookAuthHandler implements Auth.RegistrationHandler{
global boolean canCreateUser(Auth.UserData data) {
    if(data.email != null && data.email != ''){
        return true;
    } else {
		return false;
    }
}

global User createUser(Id portalId, Auth.UserData data){
	if(!canCreateUser(data)) {
		//Returning null or throwing an exception fails the SSO flow
		throw new FacebookAuthException('Cannot create user');
		return null;
	}
	if(data.attributeMap.containsKey('sfdc_networkid')) {
		//We have a community id, so create a user with community access
		List<Contact> existingContact = [Select id, email, firstName, lastName from contact where email = :data.email];
		Contact c = new Contact();
system.debug(data);
        if(existingContact.size() == 0 ){
            c.email = data.email;
            c.firstName = data.firstName;
            c.lastName = data.lastName;
            insert(c);
        } else if(existingContact.size() > 1) { 
			throw new FacebookAuthException('Non unique contact email');
    	} else {
            c = existingContact[0];
        }
		
        List<User> existingUser = [Select id, email, name from user where email = :data.email];
        if(existingUser.size()>0){
			throw new FacebookAuthException('There is a user with this email already');
        }
        User u = new User();
		Profile p = [SELECT Id FROM profile WHERE name='Customer Community User'];
        String tempUsername = data.email+'.commuser';
        List<user> existingUsername = [Select id from user where username =:tempUsername];
        if(existingUsername.size()>0){
			throw new FacebookAuthException('There is already a user with this username');
        }
		u.username = tempUsername;
		u.email = data.email;
		u.lastName = data.lastName;
		u.firstName = data.firstName;
		String alias = data.email;
		//Alias must be 8 characters or less
		if(alias.length() > 8) {
			alias = alias.substring(0, 8);
		}
		u.alias = alias;
        u.communitynickname = u.username;
		u.languagelocalekey = UserInfo.getLocale();
		u.localesidkey = UserInfo.getLocale();
		u.emailEncodingKey = 'UTF-8';
		u.timeZoneSidKey = 'America/Los_Angeles';
		u.profileId = p.Id;
		u.contactId = c.Id;
		return u;
	} else {
		//This is not a community, so create a regular standard user
		User u = new User();
		Profile p = [SELECT Id FROM profile WHERE name='Customer Community User'];
        String tempUsername = data.email+'.noncommuser';
        List<user> existingUser = [Select id from user where username =:tempUsername];
        if(existingUser.size()>0){
			throw new FacebookAuthException('Non unique username');
        }
		u.username = tempUsername;
		u.email = data.email;
		u.lastName = data.lastName;
		u.firstName = data.firstName;
		String alias = data.email;
system.debug(data);
		//Alias must be 8 characters or less
		if(alias.length() > 8) {
			alias = alias.substring(0, 8);
		}
		u.alias = alias;
        u.communitynickname = u.username;
		u.languagelocalekey = UserInfo.getLocale();
		u.localesidkey = UserInfo.getLocale();
		u.emailEncodingKey = 'UTF-8';
		u.timeZoneSidKey = 'America/Los_Angeles';
		u.profileId = p.Id;
		return u;
	}
}

global void updateUser(Id userId, Id portalId, Auth.UserData data){
	User u = new User(id=userId);
	u.email = data.email;
	u.lastName = data.lastName;
	u.firstName = data.firstName;
	update(u);
}
}
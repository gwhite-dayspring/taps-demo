/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public with sharing class CommunitiesSelfRegController {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    
    public CommunitiesSelfRegController() {}
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {
    
           // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    
		Profile p = [SELECT Id FROM profile WHERE name='Customer Community User'];
        String profileId = p.id;    
        
        Account a = new Account();
        Contact c = new Contact();
        List<Contact> existingContact = [Select id, email, firstName, lastName from contact where email = :email];
        if(existingContact.size() == 0 ){
            //assign owner to a user with a role.
            User sysadmin = [Select id from User where alias = 'sysadmin'];
            a.OwnerId = sysadmin.id;
            a.name = lastName +' Household';
            a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
            insert a;
            c.email = email;
            c.firstName = firstName;
            c.lastName = lastName;
            c.AccountId = a.id;
            insert c;
        } else if(existingContact.size() > 0) { 
			throw new SelfRegException('Non unique contact email');
            return null;
    	}
        
        String accountId = a.id;
        String userName = email;

        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = communityNickname;
        //Have to use this function to add a password to the user but creates an excess contact
        String userId = Site.createPortalUser(u, accountId, password);
        
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}
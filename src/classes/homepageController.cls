public class homepageController {
	private String currentUserProfileImage;
	private User currentUser;
    private List<User> popularUsers;
    private List<CollaborationGroup> popularGroups;
    private List<ConnectAPI.Topic> trendingTopics;
    private Id commId;
    
    public homepageController(){
        Id userId = UserInfo.getUserId();
        this.commId = Network.getNetworkId();
        this.currentUser = [select id, Name, FullPhotoUrl from User where Id = :userId];
        this.popularGroups = [select id, name, smallPhotoURL, MemberCount from CollaborationGroup Order By MemberCount DESC Limit 3];
        this.popularUsers = findPopularUsers();
        this.trendingTopics = findTrendingTopics();
    }
    
    private List<ConnectAPI.Topic> findTrendingTopics(){
        List<ConnectAPI.Topic> ret = new List<ConnectAPI.Topic>();
        ConnectApi.TopicPage topicPage = ConnectApi.Topics.getTopics(this.commId, ConnectApi.TopicSort.PopularDesc);
        if( topicPage.topics.size() > 3){
        	ret.add(topicPage.topics[0]);
            ret.add(topicPage.topics[1]);
            ret.add(topicPage.topics[2]);    
        } else {
            ret = topicPage.topics;
        }
        return ret;
    }
    
    private List<User> findPopularUsers(){
        List<User> ret = new List<User>();
        List<AggregateResult> rawPopularUsers = [select parentId
                                    from EntitySubscription 
                                    group by parentId
                                    order by count(subscriberId) DESC];
        
        for( AggregateResult popularUser : rawPopularUsers) {
            if(ret.size() == 3){break;}
            Id parentId = (Id)popularUser.get('parentId');
            List<User> tempUserList = [Select id, name, smallPhotoURL from User where id = :parentId];
            if(tempUserList.size() == 1){ret.add(tempUserList[0]);}
        }
        return ret;
    }
    
    public String getCurrentUserProfileImage(){
        return this.currentUser.fullPhotoUrl;
    }
    
    public User getCurrentUser(){
        return this.currentUser;
    }
    
    public List<CollaborationGroup> getPopularGroups(){
        return this.popularGroups;
    }
    
    public List<User> getPopularUsers(){
        return this.popularUsers;
    }
    
    public List<ConnectApi.Topic> getTrendingTopics(){
        return this.trendingTopics;
    }
    
    public Topic getMVCNTips(){
        return [Select id from Topic where name = 'MVCNTips'];
    }
    public Topic getMVCNInfoGroup(){
        return [Select id from Topic where name = 'MVCN Info Group'];
    }
        
}
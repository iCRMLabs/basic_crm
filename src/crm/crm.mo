import Error "mo:base/Error";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Time "mo:base/Time";

actor class CRM(_name : Text, _creator: Principal) {
    
    private stable var partnerEntries: [(Text, Text)] = [];
    private stable var leadEntries: [(Text, [Text])] = [];
    private stable var leadStatusEntries: [(Text, Text)] = [];
    private stable var opportunityEntries: [(Text, Text)] = [];
    private stable var opportunityDetailEntries: [(Text, [Text])] = [];
    private stable var accountEntries: [(Text, Text)] = [];
    private stable var accountDetailEntries: [(Text, [Text])] = [];
    private stable var contactEntries: [(Text, [Text])] = [];
    private stable var contactDetailEntries: [(Text, [Text])] = [];
    private stable var dealEntries: [(Text, Text)] = [];
    private stable var dealDetailEntries: [(Text, [Text])] = [];
    //private stable var partnerEntries: [(Text, Text)] = [];

    private stable var partnerCount: Nat = 0;
    private stable var leadCount: Nat = 0;

    private let partners : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(partnerEntries.vals(), 10, Text.equal, Text.hash);

    private let leads : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(leadEntries.vals(), 10, Text.equal, Text.hash);
    private let leadStatus : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(leadStatusEntries.vals(), 10, Text.equal, Text.hash);

    private let accounts : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(accountEntries.vals(), 10, Text.equal, Text.hash);
    private let accountDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(accountDetailEntries.vals(), 10, Text.equal, Text.hash);

    private let contacts : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(contactEntries.vals(), 10, Text.equal, Text.hash);
    private let contactDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(contactDetailEntries.vals(), 10, Text.equal, Text.hash);

    private let opportunities : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(opportunityEntries.vals(), 10, Text.equal, Text.hash);
    private let opportunityDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(opportunityDetailEntries.vals(), 10, Text.equal, Text.hash);

    

    private let deals : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(dealEntries.vals(), 10, Text.equal, Text.hash);
    private let dealDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(dealDetailEntries.vals(), 10, Text.equal, Text.hash);



    public shared func getPartner(pid : Text) : async ?Text {
        return partners.get(pid);
    };

    public shared func getOpportunityByLead(lid : Text) : async ?Text {
        return opportunities.get(lid);
    };

    public shared func getOpportunityDetails(oid : Text) : async ?[Text] {
        return opportunityDetails.get(oid);
    };

    public shared func getLead(lid : Text) : async ?[Text] {
        return leads.get(lid);
    };

    public shared func getLeadStatus(lid : Text) : async ?Text {
        return leadStatus.get(lid);
    };

    public shared func getDealDetails(did : Text) : async ?[Text] {
        return dealDetails.get(did);
    };

    

    public shared query func getName() : async Text {
        return _name;
    };

    public shared query func getCreator() : async Principal {
        return _creator;
    };

    

    public func createPartner(data: Text): async Text {
        var owner = await getCreator();
        let new_pid = Principal.toText(owner) # "__" # Nat.toText(partnerCount);
        partners.put(new_pid, data);
        return new_pid;
    };

    public func createLead(data: [Text]): async Text {
        
        var owner = await getCreator();
        let new_lid = Principal.toText(owner) # "__" # Nat.toText(leadCount);
        leads.put(new_lid, data);
        leadStatus.put(new_lid, "waiting");
        return new_lid;
    };

    public func createOpportunityFromLead(data: [Text], lid: Text): async ?Text {
        
        var ld = Option.get(leadStatus.get(lid), "");
        if (ld != "waiting"){
            return null;
        };
        var oid_new = lid # "__op"; 
        var opp = Option.get(opportunities.get(lid), "");
        var oppDt = Option.get(opportunityDetails.get(oid_new), []);
        if (opp != "" or oppDt.size() == 0){
            return null;
        };
        
        opportunities.put(lid, oid_new);
        opportunityDetails.put(oid_new, data);
        let _res = leadStatus.replace(lid, "oppty");
        

        
        return ?oid_new;
    };

    public func createDeal(data: [Text], oid: Text): async ?Text {
        var oppExists = false;
        var op = Option.get(opportunityDetails.get(oid), []);
        if (op.size() != 0){
            oppExists := true;
        };
        if (not oppExists){
            return null;
        };
        var ds = Option.get(deals.get(oid), "");
        if (ds != ""){
            return null;
        };
        var did_new = oid # "__dl";
        deals.put(oid, did_new);
        dealDetails.put(did_new, data); 
       
        return ?did_new;
    };

    

    system func preupgrade() {
        partnerEntries := Iter.toArray(partners.entries());
        opportunityEntries := Iter.toArray(opportunities.entries());
        opportunityDetailEntries := Iter.toArray(opportunityDetails.entries());
        leadEntries := Iter.toArray(leads.entries());
        leadStatusEntries := Iter.toArray(leadStatus.entries());
        accountEntries := Iter.toArray(accounts.entries());
        accountDetailEntries := Iter.toArray(accountDetails.entries());
        contactEntries := Iter.toArray(contacts.entries());
        contactDetailEntries := Iter.toArray(contactDetails.entries());
        dealEntries := Iter.toArray(deals.entries());
        dealDetailEntries := Iter.toArray(dealDetails.entries());
       
    };

    system func postupgrade() {
        partnerEntries := [];
        opportunityEntries := [];
        opportunityDetailEntries := [];
        dealEntries := [];
        dealDetailEntries := [];
        leadEntries := [];
        leadStatusEntries := [];
        accountEntries := [];
        accountDetailEntries := [];
        contactEntries := [];
        contactDetailEntries := [];
    };

};
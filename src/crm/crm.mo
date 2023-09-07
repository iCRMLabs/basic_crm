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
    
    private stable var partnerEntries: [(Text, [Text])] = [];
    private stable var leadEntries: [(Text, [Text])] = [];
    private stable var leadStatusEntries: [(Text, Text)] = [];
    private stable var opportunityEntries: [(Text, Text)] = [];
    private stable var opportunityDetailEntries: [(Text, [Text])] = [];
    private stable var accountEntries: [(Text, Text)] = [];
    private stable var accountDetailEntries: [(Text, [Text])] = [];
    private stable var contactEntries: [(Text, Text)] = [];
    private stable var contactDetailEntries: [(Text, [Text])] = [];
    private stable var dealEntries: [(Text, Text)] = [];
    private stable var dealDetailEntries: [(Text, [Text])] = [];

    private stable var partnerCount: Nat = 0;
    private stable var leadCount: Nat = 0;

    private let partners : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(partnerEntries.vals(), 10, Text.equal, Text.hash);

    private let leads : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(leadEntries.vals(), 10, Text.equal, Text.hash);
    private let leadStatus : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(leadStatusEntries.vals(), 10, Text.equal, Text.hash);

    private let accounts : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(accountEntries.vals(), 10, Text.equal, Text.hash);
    private let accountDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(accountDetailEntries.vals(), 10, Text.equal, Text.hash);

    private let contacts : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(contactEntries.vals(), 10, Text.equal, Text.hash);
    private let contactDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(contactDetailEntries.vals(), 10, Text.equal, Text.hash);

    private let opportunities : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(opportunityEntries.vals(), 10, Text.equal, Text.hash);
    private let opportunityDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(opportunityDetailEntries.vals(), 10, Text.equal, Text.hash);

    

    private let deals : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(dealEntries.vals(), 10, Text.equal, Text.hash);
    private let dealDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(dealDetailEntries.vals(), 10, Text.equal, Text.hash);



    public shared func getPartner(pid : Text) : async ?[Text] {
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

    

    public func createPartner(data: [Text]): async Text {
        var owner = await getCreator();
        let new_pid = Principal.toText(owner) # "__" # Nat.toText(partnerCount);
        partners.put(new_pid, data);
        return new_pid;
    };

    public func updatePartner(data: [Text], pid: Text): async Bool {
        var pt = Option.get(partners.get(pid), []);
        if (pt.size() == 0){
            return false;
        };
        
        let _res = partners.replace(pid, data);
        
        return true;
    };

    public func createLead(data: [Text]): async Text {
        
        var owner = await getCreator();
        let new_lid = Principal.toText(owner) # "__" # Nat.toText(leadCount);
        leads.put(new_lid, data);
        leadStatus.put(new_lid, "waiting");
        return new_lid;
    };

    public func updateLead(data: [Text], lid: Text): async Bool {
        var ld = Option.get(leads.get(lid), []);
        if (ld.size() == 0){
            return false;
        };
        
        let _res = leads.replace(lid, data);
        
        return true;
    };

    public func createOpportunityFromLead(data: [Text], lid: Text): async ?Text {
        
        var ld = Option.get(leadStatus.get(lid), "");
        if (ld != "waiting"){
            return null;
        };
        var oid_new = lid # "__op"; 
        var opp = Option.get(opportunities.get(lid), "");
        var oppDt = Option.get(opportunityDetails.get(oid_new), []);
        if (opp != "" or oppDt.size() != 0){
            return null;
        };
        
        opportunities.put(lid, oid_new);
        opportunityDetails.put(oid_new, data);
        let _res = leadStatus.replace(lid, "oppty");
        

        
        return ?oid_new;
    };


    public func updateOpportunity(data: [Text], oid: Text): async Bool {
        
        var op = Option.get(opportunityDetails.get(oid), []);
        if (op.size() == 0){
            return false;
        };
         
       
        
        let _res = opportunityDetails.replace(oid, data);
         
       
        return true;
    };


    // deletes an opportunity and erases all dependencies recursively
    public func deleteOpportunity(lid: Text): async Bool {
        
        var ld = Option.get(leadStatus.get(lid), "");
        if (ld == ""){
            return false;
        };
        var oid = lid # "__op"; 
        var opp = Option.get(opportunities.get(lid), "");
        var oppDt = Option.get(opportunityDetails.get(oid), []);
        if (opp == "" or oppDt.size() == 0){
            return false;
        };
        var cid = lid # "__co";
        var aid = lid # "__ac";
        var did = oid # "__dl";
        var _res = opportunities.remove(lid);
        var _res2 = opportunityDetails.remove(oid);
        var _res3 = leadStatus.replace(lid, "lost");
        var _res4 = contacts.remove(oid);
        var _res5 = contactDetails.remove(cid);
        var _res6 = accounts.remove(oid);
        var _res7 = accountDetails.remove(aid);
        var _res8 = deals.remove(oid);
        var _res9 = dealDetails.remove(did); 
        
        return true;
    };

    public func createContactFromOpportunity(data: [Text], lid: Text): async ?Text {
        var oid = lid # "__op";
        var ld = Option.get(leadStatus.get(lid), "");
        if (ld != "oppty"){
            return null;
        };

        var op = Option.get(opportunities.get(oid), "");
        if (op == ""){
            return null;
        };

        var cid_new = lid # "__co"; 
        var con = Option.get(contacts.get(oid), "");
        var conDt = Option.get(contactDetails.get(cid_new), []);
        if (con != "" or conDt.size() != 0){
            return null;
        };
        
        contacts.put(oid, cid_new);
        contactDetails.put(cid_new, data);
        let _res = leadStatus.replace(lid, "cntct");
        

        
        return ?cid_new;
    };

    public func updateContact(data: [Text], cid: Text): async Bool {
    
        var ct = Option.get(contactDetails.get(cid), []);
        if (ct.size() == 0){
            return false;
        };

        
        
        
        let _res = contactDetails.replace(cid, data);
        
        

        
        return true;
    };

    public func deleteContact(lid: Text): async Bool {
        var oid = lid # "__op";
        var cid = lid # "__co";
        var ld = Option.get(leadStatus.get(lid), "");
        if (ld == ""){
            return false;
        };
        
        var opp = Option.get(opportunities.get(lid), "");
        var oppDt = Option.get(opportunityDetails.get(oid), []);
        if (opp == "" or oppDt.size() == 0){
            return false;
        };

        var ct = Option.get(contactDetails.get(cid), []);
        if (ct.size() == 0){
            return false;
        };

        var _res = contacts.remove(oid);
        var _res2 = contactDetails.remove(cid);
        var _res3 = leadStatus.replace(lid, "oppty");
        
        

        
        return true;
    };

    public func createAccountFromOpportunity(data: [Text], lid: Text): async ?Text {
        var oid = lid # "__op";
        var ld = Option.get(leadStatus.get(lid), "");
        if (ld != "cntct"){
            return null;
        };

        var op = Option.get(opportunities.get(oid), "");
        if (op == ""){
            return null;
        };
        var cid = lid # "__co";
        var aid_new = lid # "__ac"; 
        var acc = Option.get(accounts.get(cid), "");
        var accDt = Option.get(accountDetails.get(aid_new), []);
        if (acc != "" or accDt.size() != 0){
            return null;
        };
        
        accounts.put(cid, aid_new);
        accountDetails.put(aid_new, data);
        let _res = leadStatus.replace(lid, "cntct+");
        

        
        return ?aid_new;
    };

    public func updateAccount(data: [Text], aid: Text): async Bool {
    
        var ac = Option.get(accountDetails.get(aid), []);
        if (ac.size() == 0){
            return false;
        };

        
        
        
        let _res = accountDetails.replace(aid, data);
        
        

        
        return true;
    };


    // Must be deleted before contact. But both are to be deleted in pairs.
    public func deleteAccount(lid: Text): async Bool {
        var oid = lid # "__op";
        var aid = lid # "__ac";
        var ld = Option.get(leadStatus.get(lid), "");
        if (ld == ""){
            return false;
        };
        
        var opp = Option.get(opportunities.get(lid), "");
        var oppDt = Option.get(opportunityDetails.get(oid), []);
        if (opp == "" or oppDt.size() == 0){
            return false;
        };

        var ac = Option.get(accountDetails.get(aid), []);
        if (ac.size() == 0){
            return false;
        };

        var _res = accounts.remove(oid);
        var _res2 = accountDetails.remove(aid);
        var _res3 = leadStatus.replace(lid, "cntct");
        
        

        
        return true;
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

    public func updateDeal(data: [Text], did: Text): async Bool {
        
        var dl = Option.get(dealDetails.get(did), []);
        if (dl.size() != 0){
            return false;
        };
       
        
        let _res = dealDetails.replace(did, data); 
       
        return true;
    };    

    // Deletes a child deal
    public func deleteDeal(oid: Text): async Bool {
        
        var did = oid # "__dl";
        
        var _res = deals.remove(oid);
        var _res2 = dealDetails.remove(did);
        
        
        

        
        return true;
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
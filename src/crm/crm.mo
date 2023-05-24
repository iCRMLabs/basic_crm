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
    private stable var opportunityEntries: [(Text, [Text])] = [];
    private stable var opportunityDetailEntries: [(Text, [Text])] = [];
    private stable var leadEntries: [(Text, [Text])] = [];
    private stable var leadDetailEntries: [(Text, [Text])] = [];
    private stable var dealEntries: [(Text, [Text])] = [];
    private stable var dealDetailEntries: [(Text, [Text])] = [];
    //private stable var partnerEntries: [(Text, Text)] = [];

    private stable var partnerCount: Nat = 0;

    private let partners : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(partnerEntries.vals(), 10, Text.equal, Text.hash);

    private let opportunities : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(opportunityEntries.vals(), 10, Text.equal, Text.hash);
    private let opportunityDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(opportunityDetailEntries.vals(), 10, Text.equal, Text.hash);

    private let leads : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(leadEntries.vals(), 10, Text.equal, Text.hash);
    private let leadDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(leadDetailEntries.vals(), 10, Text.equal, Text.hash);

    private let deals : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(dealEntries.vals(), 10, Text.equal, Text.hash);
    private let dealDetails : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(dealDetailEntries.vals(), 10, Text.equal, Text.hash);



    public shared func getPartner(pid : Text) : async ?Text {
        return partners.get(pid);
    };

    public shared func getOpportunities(pid : Text) : async ?[Text] {
        return opportunities.get(pid);
    };

    public shared func getLeads(oid : Text) : async ?[Text] {
        return leads.get(oid);
    };

    public shared func getDeals(oid : Text) : async ?[Text] {
        return deals.get(oid);
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

    public func createOpportunity(data: [Text], pid: Text): async ?Text {
        var partnerExists = false;
        var ptnr = Option.get(partners.get(pid), "");
        if (ptnr != ""){
            partnerExists := true;
        };
        if (not partnerExists){
            return null;
        };
        var opps = Option.get(opportunities.get(pid), []);
        var oid_new = pid # "__" # Nat.toText(opps.size() + 1); 
        if (opps.size() == 0){
            
            opportunities.put(pid, Array.make(oid_new));
        }
        else {
            opps := Array.append(opps, Array.make(oid_new));
            let _res = opportunities.replace(pid, opps);
        };

        opportunityDetails.put(oid_new, data);
        return ?oid_new;
    };

    public func createLead(data: [Text], oid: Text): async ?Text {
        var oppExists = false;
        var op = Option.get(opportunityDetails.get(oid), []);
        if (op.size() != 0){
            oppExists := true;
        };
        if (not oppExists){
            return null;
        };
        var ls = Option.get(leads.get(oid), []);
        var lid_new = oid # "__" # Nat.toText(ls.size() + 1); 
        if (ls.size() == 0){
            
            leads.put(oid, Array.make(lid_new));
        }
        else {
            ls := Array.append(ls, Array.make(lid_new));
            let _res = leads.replace(oid, ls);
        };

        leadDetails.put(lid_new, data);
        return ?lid_new;
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
        var ds = Option.get(deals.get(oid), []);
        var did_new = oid # "__" # Nat.toText(ds.size() + 1); 
        if (ds.size() == 0){
            
            deals.put(oid, Array.make(did_new));
        }
        else {
            ds := Array.append(ds, Array.make(did_new));
            let _res = deals.replace(oid, ds);
        };

        dealDetails.put(did_new, data);
        return ?did_new;
    };

    

    system func preupgrade() {
        partnerEntries := Iter.toArray(partners.entries());
        opportunityEntries := Iter.toArray(opportunities.entries());
        opportunityDetailEntries := Iter.toArray(opportunityDetails.entries());
        leadEntries := Iter.toArray(leads.entries());
        leadDetailEntries := Iter.toArray(leadDetails.entries());
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
        leadDetailEntries := [];
        
    };

};
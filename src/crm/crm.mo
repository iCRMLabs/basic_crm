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
    private stable var leadEntries: [(Text, [Text])] = [];
    private stable var dealEntries: [(Text, [Text])] = [];
    //private stable var partnerEntries: [(Text, Text)] = [];

    private stable var partnerCount: Nat = 0;

    private let partners : HashMap.HashMap<Text, Text> = HashMap.fromIter<Text, Text>(partnerEntries.vals(), 10, Text.equal, Text.hash);
    private let opportunities : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(opportunityEntries.vals(), 10, Text.equal, Text.hash);
    private let leads : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(leadEntries.vals(), 10, Text.equal, Text.hash);
    private let deals : HashMap.HashMap<Text, [Text]> = HashMap.fromIter<Text, [Text]>(dealEntries.vals(), 10, Text.equal, Text.hash);
   


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

    

    system func preupgrade() {
        partnerEntries := Iter.toArray(partners.entries());
        opportunityEntries := Iter.toArray(opportunities.entries());
        leadEntries := Iter.toArray(leads.entries());
        dealEntries := Iter.toArray(deals.entries());
       
    };

    system func postupgrade() {
        partnerEntries := [];
        opportunityEntries := [];
        dealEntries := [];
        leadEntries := [];
        
    };

};
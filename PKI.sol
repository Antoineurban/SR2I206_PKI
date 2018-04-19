pragma solidity ^0.4.0;

contract BaseRegistry {

    uint public creationTime = now;
    
    Record[] public records;
    Signature[] public signatures;
    Revocation[] public revocations;
    
    // This struct keeps all data for a Record.
    struct Record {
        // Keeps the address of this record creator.
        address issuerID;
        // Keeps the time when this record was created.
        uint time;
        //versionNumber 
        uint versionNumber;
        //
        address clientID;
        string data;
        //
        string datahash;
    }
    struct Signature {
        address signer;
        uint recordID;
        uint end_time;
    }
    
    struct Revocation {
        uint signatureID;
        uint revokID;
    }


    modifier onlyOwner {
        if (msg.sender != issuerID) throw;
        _;
    }

    // This is the function that inserts a record. 
    function register(uint versionNumber, address clientID, string data, string datahash) returns (uint recordID) {
        recordID= records.length++;
        Record record = records[recordID];
        record.issuerID= msg.sender;
        record.time= now;
        record.versionNumber = versionNumber;
        recod.clientID= clientID;
        record.data = data;
        record.datahash= datahash;
        
    }
    
    // Updates the values of the given record.
    function sign(uint recordID, uint end_time) returns (uint signatureID) {
        // Only the owner can update his record.
        if (records[recordID].issuerID == msg.sender) {
            signatureID = signatures.length++;
            Signature signature = signatures[signatureID];
            signature.signer= msg.sender;
            signature.recordID = recordID;
            signature.end_time= end_time;
        }
    }

    // revocation of a given record
    function revok(uint signatureID) returns (uint revokID) {
        if (signatures[signatureID].signer == msg.sender) {
            revokID= revocation.length++;
            Revocation revocation= revocations[revocationID];
            revocation.signatureID = signatureID:
            revocation.revokID= revokID;
        }
    }

    // Tells whether a given recordID is registered.
    function isRegistered(uint recordID) returns(bool) {
        return records[key].time != 0;
    }


    function getRecord(uint recordID) returns(address issuerID, uint time) {
        Record record = records[recordID];
        owner = record.issuerID;
        time = record.time;
    }
    
    function validityCheck(uint recordID) returns(bool validity) {
        if (signatures[recordID)
        validity= 
        ...
    }


    function kill() onlyOwner {
        suicide(owner);
    }
}

contract is BaseRegistry {}

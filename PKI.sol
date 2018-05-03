pragma solidity ^0.4.0;

contract PKI {
    
    address owner;
    
    mapping (uint => Entity) public entities;
    mapping (uint => Certificate) public registry;
    mapping (uint => Signature) public signings;
    mapping (uint => bool) public crl;
    uint nEntities;
    uint nCertificates;
    uint nSignatures;
    
    struct Entity {
        address identity;
        bytes32 publicKey;
        uint level;
    }

    struct Certificate {
        address issuer;
        string data;
        string hash;
    }

    struct Signature {
        address owner;  // Owner of the signature
        uint certId;  // Id of the cerficate
        uint expiry;
    }

    constructor() public {
        owner = msg.sender;
    }
    
    // Add a trusted entity. Owner of the PKI only
    function register(address trustedEntity, bytes32 publicKey)
        public returns (uint entityId) {
        
        if (msg.sender == owner) {
            entityId = nEntities++;
            entities[entityId] = Entity(trustedEntity, publicKey, 1);
        } else {
            bool found = false;
            for (uint i=0; i < nEntities; i++) {
                if (msg.sender == entities[i].identity) {
                    entityId = nEntities++;
                    found = true;
                    entities[entityId] =
                        Entity(trustedEntity, publicKey, entities[i].level + 1);
                }
            }
            require(found);
        }
    }

    // A non trusted entity publishes its certificate
    function append(string data, string hash) public returns (uint certId) {
        certId = nCertificates++;
        registry[certId] = Certificate(msg.sender, data, hash);    
    }

    // A trusted entity signs a certificate (expiry is time in seconds)
    function sign(uint certId, uint expiry) public returns (uint signId) {
        for (uint i=0; i < nEntities; i++) {
            if (entities[i].identity == msg.sender) {
                signId = nSignatures++;
                signings[signId] = Signature(msg.sender, certId, now + expiry);
                crl[signId] = false;
                break;
            }
        }
    }

    // A trusted entity revokes a signature
    function revoke(uint signId) public {
        for (uint i=0; i < nEntities; i++) {
            if (entities[i].identity == msg.sender) {
                crl[signId] = true;
                break;
            }
        }
    }

    function isSignatureValid(uint signId) public view returns (bool state) {
        return !crl[signId] && now <= signings[signId].expiry;
    }

    function isCertificateValid(uint certId) public view returns (bool state) {
        for (uint i=0; i < nSignatures; i++) {
            if (signings[i].certId == certId) {
                if (isSignatureValid(i)) {
                    return true; // Else try for another signature
                }
            }
        }
        return false;
    }

}
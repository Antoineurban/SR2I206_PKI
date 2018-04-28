pragma solidity ^0.4.0;

contract PKI {

    mapping (uint => Certificate) public registry;
    mapping (uint => Signature) public signings;
    mapping (uint => bool) public crl;
    uint nCertificates;
    uint nSignatures;

    struct Certificate {
        address issuer;
        bytes32 publicKey;
        string data;
        string hash;
    }

    struct Signature {
        address owner;  // Owner of the signature
        uint certId;  // Id of the cerficate
        uint expiry;
    }

    constructor() public { }

    // Add a certificate
    function register(address issuer, bytes32 publicKey, string data,
                      string hash) public returns (uint certId) {
        certId = nCertificates++;
        registry[certId] = Certificate(issuer, publicKey, data, hash);
    }

    // Sign a certificate (expiry is time in seconds)
    function sign(uint certId, uint expiry) public returns (uint signId) {
        // TODO: should be PKI owner only
        signId = nSignatures++;
        signings[signId] = Signature(msg.sender, certId, now + expiry);
        crl[signId] = false;
    }

    // Revoke a signature
    function revoke(uint signId) public {
        crl[signId] = true;
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

// SPDX-License-Identifier: GPL 3.0
pragma solidity ^0.8.24;
contract Records {
    
    event NewRecord(address sender, string message); //event records new files added
    event IncomingFlags(address wer, string ssss); // records all the flags
    event TweetEvent(string[] pinnu, address abhi); // records the files
    event VerifiedRecord(address verifier, address user, string CID); // all the verified records
    event FileReported(address reporter, string CID, bool flag); // all the reported files
    event FileFlagged(address verifier, string CID, bool decision); // all the flagged filesa
    event FilePermanentlyFlagged(string CID); // all the permanantly flagged files
    event tweetedited(string newtweet, uint indexat); // all the edited files

    mapping(address => uint[]) public CheckRecord; // Check for existing file records
    mapping(address => string[]) public Record; // Store the file CID
    mapping(address => bool) public registeredUsers; // registered users
    mapping(address => bool) public registeredVerifiers; // regestered verifiers
    mapping(address => string[]) public verifiedFiles; // List of verified files by user
    mapping(string => bool) reportedfile; // used to report a files
    mapping(string => bool) public permanentlyFlaggedFiles; // List of permanently flagged files
    mapping(address => string[]) public addressstringmapping; // this will store the address and the number of files that they have reported
    mapping(string => address) public listofreportedfiles; //since every cid is unique and for fetching reporter
    mapping(address => address[]) public togetheuseradd; // will return the user address using a function
    mapping(string => bool) verifiedrecords; // holds the verified records
    mapping(uint => mapping(string => mapping(bool => bool))) flaggedfiles; // holds the cid of all the flagged files
    mapping(address => bool) isAdmin; // currently not in use will be used in the future
    mapping(address => bool) reporterList; // list of the reporters
    mapping(uint => string) cidcheck; // used to check for the cid


    address public owner; // address of the contract deployer
    address payable public receiver; // this is same as the contract deployer

    uint public users;
    uint public verifier;
    
    address[] public verifierslist; // list of verifiers
    address[] registeredUsersList; // registered user list
   
    uint reportercount;
   
    uint cidcount;

    constructor() {
        // will be used to set the owner and the reciver , admin
        owner = msg.sender;
        receiver = payable(msg.sender);
        isAdmin[msg.sender] = true; // Set contract owner as admin
    }

    // acess modifier
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }
    modifier onlyverfier(address vr){
        require(registeredVerifiers[vr]);
        _;
    }

    // user registration and verifier registration
    function registerAsVerifier(address verifierAddress) external  onlyOwner {
        require(
            !registeredVerifiers[verifierAddress],
            "You have already registered as a verifier."
        );
        registeredVerifiers[verifierAddress] = true;
        verifierslist.push(verifierAddress);
        verifier++;
    }

    // function to upload the files
    function postTweet(string memory message, address user) external  payable {
        require(msg.value == 0.03 ether, "Incorrect amount of ether sent.");
        bool depositSuccess = depositUsingTransfer(receiver, msg.value);
        require(depositSuccess, "Failed to deposit ether to verifier.");
        registeredUsers[user] = true;
        uint count = 1;
        Record[user].push(message);
        CheckRecord[user].push(count);
        emit NewRecord(user, message);

    }

    // function to change the edited files
    function editTweet(
        string memory message,
        string memory old_CID,
        address user,
        uint index
    ) external  onlyverfier(msg.sender) returns (string memory) {
        require(CheckRecord[user].length > index, "Invalid index provided.");
        require(msg.sender == user, "Access denied.");
        require(!reportedfile[old_CID], "YOU CANT EDIT A REPORTED FILE");
        uint k = getDataIndex(user, old_CID);
        if (
            keccak256(bytes(verifiedFiles[user][k])) ==
            keccak256(bytes(old_CID))
        ) {
            verifiedFiles[user][k] = message;
        }
        Record[user][index] = message;
        emit tweetedited(message, index);

        return "Your tweet has been edited.";
    }

    // function to return the tweets be carful and uses a lot of gas(user has to pay)
    function getTweets(address user) public  returns (string[] memory) {
        require(registeredUsers[user], "User must be registered.");
        string[] memory userTweets = Record[user];
        emit TweetEvent(userTweets, user);
        return userTweets;
    }

    //FUNCTION USED BY VERIFIERS TO VERIFIY THE RECORDS
    function verifyRecords(
        address verifierAddress,
        address user,
        string memory CID
    ) external   onlyverfier(msg.sender) returns (string memory)  {
        require(registeredUsers[user], "User must be registered.");
        require(
            registeredVerifiers[verifierAddress],
            "Verifier must be registered."
        );
        require(!verifiedrecords[CID], "This file has already been verified.");
        require(
            checkforsametweet(user, CID),
            "The record you are trying to verify does not exist"
        );
        require(!reportedfile[CID], "YOU CANT VERIFY A REPORTED FILE");
        verifiedrecords[CID] = true;
        verifiedFiles[user].push(CID);
        emit VerifiedRecord(verifierAddress, user, CID);
        return "File has been verified.";
    }

   // function used to report a file
    function reportFile(
        string memory CID,
        address reporter,
        address user
    ) external  returns (string memory) {
        require(
            registeredUsers[reporter] || registeredVerifiers[reporter],
            "Reporter must be a registered user or verifier."
        );
        require(
            reportedfile[CID] == false,
            "this file has already been reported"
        );
        require(reporter != user, "you cant report your own file");
        reportedfile[CID] = true;
        addressstringmapping[reporter].push(CID);
        listofreportedfiles[CID] = reporter;
        togetheuseradd[reporter].push(user);

        return "The file has been reported.";
    }

    // function used to flag a file
    function flagFile(
        string memory CID,
        address verifierAddress,
        bool decision
    ) external onlyverfier(msg.sender) returns (string memory) {
        // cahrege users
        require(
            registeredVerifiers[verifierAddress],
            "Verifier must be registered."
        );
        require(reportedfile[CID], "this file was not reported yet");
        address reporter = fetchreporter(CID);
        address user = getAddressForMatchingTweets(reporter, CID);
        if (decision) {
            // Move the flagged file to permanently flagged list
            permanentlyFlaggedFiles[CID] = true;
            deleteStringFromArrayverifiedFiles(user, CID);
            deleteStringFromArrayRecord(user, CID);
            emit FilePermanentlyFlagged(CID);
            return "file has been flagged permanently";
        } else {
            reportedfile[CID] = false;
            deleteStringValue(reporter, CID);
            return "The file is legit";
        }
    }

    function depositUsingTransfer(  // function to transfer eth
        address payable to,
        uint256 amount
    ) internal returns (bool) {
        to.transfer(amount);
        return true;
    }

    // returns how many records does a address has
    function sizeofrecords(address ac) public view returns (uint) {
        return Record[ac].length;
    }

    function checkforsametweet(
        address user,
        string memory CID
    ) private view returns (bool) {
        uint g = Record[user].length;
        uint ki = 0;

        // Loop unrolling
        for (; ki + 3 < g; ki += 4) {
            if (keccak256(bytes(Record[user][ki])) == keccak256(bytes(CID))) {
                return true;
            }
            if (
                keccak256(bytes(Record[user][ki + 1])) == keccak256(bytes(CID))
            ) {
                return true;
            }
            if (
                keccak256(bytes(Record[user][ki + 2])) == keccak256(bytes(CID))
            ) {
                return true;
            }
            if (
                keccak256(bytes(Record[user][ki + 3])) == keccak256(bytes(CID))
            ) {
                return true;
            }
        }

        // Process remaining iterations (if any)
        if (ki < g) {
            if (keccak256(bytes(Record[user][ki])) == keccak256(bytes(CID))) {
                return true;
            }
            ki++;
        }

        if (ki < g) {
            if (keccak256(bytes(Record[user][ki])) == keccak256(bytes(CID))) {
                return true;
            }
            ki++;
        }

        if (ki < g) {
            if (keccak256(bytes(Record[user][ki])) == keccak256(bytes(CID))) {
                return true;
            }
            ki++;
        }

        return false;
    }

    function getDataIndex(
        address user,
        string memory CID
    ) private view returns (uint) {
        string[] storage dataArray = Record[user];
        uint256 length = dataArray.length;

        // Unroll the loop in increments of 4
        for (uint256 i = 0; i < length; i += 4) {
            if (keccak256(bytes(dataArray[i])) == keccak256(bytes(CID))) {
                return i;
            }
            if (
                i + 1 < length &&
                keccak256(bytes(dataArray[i + 1])) == keccak256(bytes(CID))
            ) {
                return i + 1;
            }
            if (
                i + 2 < length &&
                keccak256(bytes(dataArray[i + 2])) == keccak256(bytes(CID))
            ) {
                return i + 2;
            }
            if (
                i + 3 < length &&
                keccak256(bytes(dataArray[i + 3])) == keccak256(bytes(CID))
            ) {
                return i + 3;
            }
        }

        // If the data is not found, return a large value;
        return
            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    }

   
    // gives the address of the reporter
    function fetchreporter(string memory CID) public view returns (address) {
        return listofreportedfiles[CID];
    }

    // will delete the verified files
    function deleteStringverifiedfiles(
        address addr,
        string memory stringToDelete
    ) public {
        string[] storage strings = verifiedFiles[addr];
        uint length = strings.length;
        uint newIndex = 0;

        string[] memory newStrings = new string[](length);

        for (uint i = 0; i < length; i++) {
            if (
                keccak256(bytes(strings[i])) != keccak256(bytes(stringToDelete))
            ) {
                newStrings[newIndex] = strings[i];
                newIndex++;
            }
        }

        // Resize the newStrings array to the correct length
        assembly {
            mstore(newStrings, newIndex)
        }

        // Update the verifiedFiles mapping with the new array
        verifiedFiles[addr] = newStrings;
    }


    //checks for the cid and then returns the index
    function getAddressForMatchingTweets(
        address reporter,
        string memory searchString
    ) private returns (address) {
        address[] memory addresses = togetheuseradd[reporter];

        for (uint i = 0; i < addresses.length; i++) {
            address user = addresses[i];
            string[] memory userTweets = getTweets(user);

            // Check if the returned tweets contain the matching string
            for (uint j = 0; j < userTweets.length; j++) {
                if (
                    keccak256(bytes(userTweets[j])) ==
                    keccak256(bytes(searchString))
                ) {
                    return user;
                }
            }
        }

        // Return a null address if no matching tweets found
        return address(0);
    }

   
    // obj writing functions to delete certain things
    function deleteStringFromArrayRecord(
        address addr,
        string memory valueToDelete
    ) private {
        // pass the address of the user not reporter
        string[] storage strings = Record[addr];
        uint length = strings.length;
        uint indexToDelete = length;

        // Loop unrolling
        for (uint i = 0; i < length; i += 4) {
            if (
                keccak256(bytes(strings[i])) == keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i;
                break;
            }
            if (
                keccak256(bytes(strings[i + 1])) ==
                keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i + 1;
                break;
            }
            if (
                keccak256(bytes(strings[i + 2])) ==
                keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i + 2;
                break;
            }
            if (
                keccak256(bytes(strings[i + 3])) ==
                keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i + 3;
                break;
            }
        }

        require(indexToDelete < length, "String not found in the array.");

        // Move the last element to the index being deleted
        strings[indexToDelete] = strings[length - 1];

        // Remove the last element
        strings.pop();
        // Update the mapping with the modified array
        Record[addr] = strings;
    }

    // function for verifiedFiles deleting
    function deleteStringFromArrayverifiedFiles(
        address addr,
        string memory valueToDelete
    ) private {
        // pass address of user not the reporter
        string[] storage strings = verifiedFiles[addr];
        uint length = strings.length;
        uint indexToDelete = length;

        // Loop unrolling
        for (uint i = 0; i < length; i += 4) {
            if (
                keccak256(bytes(strings[i])) == keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i;
                break;
            }
            if (
                keccak256(bytes(strings[i + 1])) ==
                keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i + 1;
                break;
            }
            if (
                keccak256(bytes(strings[i + 2])) ==
                keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i + 2;
                break;
            }
            if (
                keccak256(bytes(strings[i + 3])) ==
                keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i + 3;
                break;
            }
        }

        require(indexToDelete < length, "String not found in the array.");

        // Move the last element to the index being deleted
        strings[indexToDelete] = strings[length - 1];

        // Remove the last element
        strings.pop();
        // Update the mapping with the modified array
        verifiedFiles[addr] = strings;
    }

    function deleteStringValue(
        address addr,
        string memory valueToDelete
    ) private {
        string[] storage strings = addressstringmapping[addr];
        uint length = strings.length;
        uint indexToDelete = length;

        // Loop unrolling
        for (uint i = 0; i < length; i += 4) {
            if (
                keccak256(bytes(strings[i])) == keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i;
                break;
            }
            if (
                keccak256(bytes(strings[i + 1])) ==
                keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i + 1;
                break;
            }
            if (
                keccak256(bytes(strings[i + 2])) ==
                keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i + 2;
                break;
            }
            if (
                keccak256(bytes(strings[i + 3])) ==
                keccak256(bytes(valueToDelete))
            ) {
                indexToDelete = i + 3;
                break;
            }
        }

        require(indexToDelete < length, "String not found in the array.");

        // Move the last element to the index being deleted
        strings[indexToDelete] = strings[length - 1];

        // Remove the last element
        strings.pop();

        // Update the mapping with the modified array
        addressstringmapping[addr] = strings;
    }



}

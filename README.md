# Records Smart Contract

## Overview
The Tweet Records Smart Contract is a decentralized application (DApp) deployed on the Ethereum blockchain. It allows users to post, edit, report, verify, and flag tweets, which are stored as files on the blockchain. Verifiers play a crucial role in verifying the authenticity of tweets, while users can interact with the contract to manage their tweets.

## Features
- Users can post new tweets.
- Users can edit their previously posted tweets.
- Verifiers can register and verify the authenticity of tweets.
- Users can report tweets for review by verifiers.
- Verifiers can flag reported tweets as legitimate or permanently flagged.

## Contract Details
- **Language**: Solidity
- **Compiler Version**: 0.8.24
- **License**: GNU General Public License v3.0
- **SPDX-License-Identifier**: GPL-3.0

## Modifiers

### 1. onlyOwner
- **Description**: Restricts access to functions to only the contract owner.
- **Usage**: Applied to functions that should only be callable by the contract owner.

### 2. onlyverfier
- **Description**: Restricts access to functions to only registered verifiers.
- **Parameters**:
  - `vr`: The address of the verifier.
- **Usage**: Applied to functions that should only be callable by registered verifiers.

## Events

### 1. NewRecord
- **Description**: Records new files added.
- **Parameters**:
  - `sender`: The address of the sender.
  - `message`: The message of the tweet.

### 2. IncomingFlags
- **Description**: Records all the flags.
- **Parameters**:
  - `wer`: The address of the flagger.
  - `ssss`: The flag message.

### 3. TweetEvent
- **Description**: Records the files (tweets).
- **Parameters**:
  - `pinnu`: An array of strings representing the tweets.
  - `abhi`: The address of the user.

### 4. VerifiedRecord
- **Description**: Records all the verified records.
- **Parameters**:
  - `verifier`: The address of the verifier.
  - `user`: The address of the user.
  - `CID`: The CID of the verified record.

### 5. FileReported
- **Description**: Records all the reported files.
- **Parameters**:
  - `reporter`: The address of the reporter.
  - `CID`: The CID of the reported file.
  - `flag`: Boolean indicating whether the file was flagged.

### 6. FileFlagged
- **Description**: Records all the flagged files.
- **Parameters**:
  - `verifier`: The address of the verifier.
  - `CID`: The CID of the flagged file.
  - `decision`: Boolean indicating the decision on the flag.

### 7. FilePermanentlyFlagged
- **Description**: Records all the permanently flagged files.
- **Parameters**:
  - `CID`: The CID of the permanently flagged file.

### 8. tweetedited
- **Description**: Records all the edited files (tweets).
- **Parameters**:
  - `newtweet`: The edited tweet message.
  - `indexat`: The index of the tweet.

## Other Variables

### 1. CheckRecord
- **Type**: Mapping
- **Description**: Check for existing file records.

### 2. Record
- **Type**: Mapping
- **Description**: Store the file CID.

### 3. registeredUsers
- **Type**: Mapping
- **Description**: Tracks registered users.

### 4. registeredVerifiers
- **Type**: Mapping
- **Description**: Tracks registered verifiers.

### 5. verifiedFiles
- **Type**: Mapping
- **Description**: List of verified files by user.

### 6. reportedfile
- **Type**: Mapping
- **Description**: Used to report files.

### 7. permanentlyFlaggedFiles
- **Type**: Mapping
- **Description**: List of permanently flagged files.

### 8. addressstringmapping
- **Type**: Mapping
- **Description**: Stores the address and the number of files reported.

### 9. listofreportedfiles
- **Type**: Mapping
- **Description**: Stores the reporter for each CID.

### 10. togetheuseradd
- **Type**: Mapping
- **Description**: Returns the user address using a function.

### 11. verifiedrecords
- **Type**: Mapping
- **Description**: Holds the verified records.

### 12. flaggedfiles
- **Type**: Mapping
- **Description**: Holds the CID of all the flagged files.

### 13. isAdmin
- **Type**: Mapping
- **Description**: Currently not in use, will be used in the future.

### 14. reporterList
- **Type**: Mapping
- **Description**: List of reporters.

### 15. cidcheck
- **Type**: Mapping
- **Description**: Used to check for the CID.

### 16. owner
- **Type**: Address
- **Description**: Address of the contract deployer.

### 17. receiver
- **Type**: Payable Address
- **Description**: Same as the contract deployer.

### 18. users
- **Type**: Unsigned Integer
- **Description**: Total number of registered users.

### 19. verifier
- **Type**: Unsigned Integer
- **Description**: Total number of registered verifiers.

### 20. verifierslist
- **Type**: Array of Addresses
- **Description**: List of verifiers.

### 21. registeredUsersList
- **Type**: Array of Addresses
- **Description**: Registered user list.

### 22. reportercount
- **Type**: Unsigned Integer
- **Description**: Number of reporters.

### 23. cidcount
- **Type**: Unsigned Integer
- **Description**: Number of CIDs.



## Callable Functions

### 1. postTweet
- **Description**: Allows users to post a new tweet.
- **Parameters**:
  - `message`: The content of the tweet.
  - `user`: The address of the user posting the tweet.
- **Modifier**: `onlyOwner`

### 2. editTweet
- **Description**: Enables users to edit their previously posted tweets.
- **Parameters**:
  - `message`: The new content of the tweet.
  - `old_CID`: The CID (Content Identifier) of the tweet to be edited.
  - `user`: The address of the user editing the tweet.
  - `index`: The index of the tweet in the user's tweet list.
- **Modifier**: `onlyverfier`

### 3. getTweets
- **Description**: Retrieves a user's own tweets.
- **Parameters**:
  - `user`: The address of the user whose tweets are to be retrieved.

### 4. reportFile
- **Description**: Allows users or verifiers to report a tweet.
- **Parameters**:
  - `CID`: The CID (Content Identifier) of the tweet being reported.
  - `reporter`: The address of the user or verifier reporting the tweet.
  - `user`: The address of the user who posted the tweet.

### 5. flagFile
- **Description**: Enables verifiers to flag reported tweets.
- **Parameters**:
  - `CID`: The CID (Content Identifier) of the tweet being flagged.
  - `verifierAddress`: The address of the verifier flagging the tweet.
  - `decision`: A boolean indicating whether to flag the tweet as legitimate or permanently flagged.
- **Modifier**: `onlyverfier`

### 6. registerAsVerifier
- **Description**: Registers a new verifier (callable by the contract owner).
- **Parameters**:
  - `verifierAddress`: The address of the verifier being registered.
- **Modifier**: `onlyOwner`

### 7. verifyRecords
- **Description**: Allows verifiers to verify the authenticity of tweets.
- **Parameters**:
  - `verifierAddress`: The address of the verifier verifying the tweet.
  - `user`: The address of the user who posted the tweet.
  - `CID`: The CID (Content Identifier) of the tweet being verified.
- **Modifier**: `onlyverfier`

## Internal Functions

### 1. depositUsingTransfer
- **Description**: Function to transfer ether.
- **Parameters**:
  - `to`: The address to which the ether is being transferred.
  - `amount`: The amount of ether being transferred.

### 2. sizeofrecords
- **Description**: Returns how many records an address has.
- **Parameters**:
  - `ac`: The address for which the number of records is to be determined.

### 3. checkforsametweet
- **Description**: Checks if a user has a tweet with the same CID.
- **Parameters**:
  - `user`: The address of the user.
  - `CID`: The CID (Content Identifier) of the tweet.
### 4. getDataIndex
- **Description**: Returns the index of a tweet in a user's tweet list.
- **Parameters**:
  - `user`: The address of the user.
  - `CID`: The CID (Content Identifier) of the tweet.

### 5. fetchreporter
- **Description**: Returns the address of the reporter who reported a tweet.
- **Parameters**:
  - `CID`: The CID (Content Identifier) of the tweet.

### 6. getAddressForMatchingTweets
- **Description**: Returns the address of the user who posted a tweet matching a given CID.
- **Parameters**:
  - `reporter`: The address of the reporter who reported the tweet.
  - `searchString`: The CID (Content Identifier) of the tweet.

### 7. deleteStringverifiedfiles
- **Description**: Deletes a specific string from the `verifiedFiles` mapping.
- **Parameters**:
  - `addr`: The address for which the string is to be deleted.
  - `stringToDelete`: The string to be deleted.

### 8. deleteStringFromArrayRecord
- **Description**: Deletes a specific string from the `Record` mapping.
- **Parameters**:
  - `addr`: The address for which the string is to be deleted.
  - `valueToDelete`: The string to be deleted.

### 9. deleteStringFromArrayverifiedFiles
- **Description**: Deletes a specific string from the `verifiedFiles` mapping.
- **Parameters**:
  - `addr`: The address for which the string is to be deleted.
  - `valueToDelete`: The string to be deleted.

### 10. deleteStringValue
- **Description**: Deletes a specific string from a mapping.
- **Parameters**:
  - `addr`: The address for which the string is to be deleted.
  - `valueToDelete`: The string to be deleted.

## Usage
1. Deploy the contract on an Ethereum network.
2. Use the provided functions to interact with the contract:
   - Post tweets.
   - Edit tweets.
   - Verify tweets.
   - Report tweets.
   - Flag tweets.
   - Register as a verifier.

## License
This project is licensed under the terms of the GNU General Public License v3.0. For more details, see the [LICENSE](LICENSE) file.


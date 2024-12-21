// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GroupStudyIncentives {
    
    struct StudyGroup {
        string groupName;
        string description;
        address creator;
        uint256 reward;
        uint256 participantLimit;
        address[] participants;
        bool isActive;
    }

    StudyGroup[] public studyGroups;
    mapping(address => uint256) public userRewards;

    event GroupCreated(
        uint256 groupId,
        string groupName,
        string description,
        address creator,
        uint256 reward,
        uint256 participantLimit
    );

    event ParticipantJoined(
        uint256 groupId,
        address participant
    );

    event RewardClaimed(
        uint256 groupId,
        address participant,
        uint256 reward
    );

    // Create a new study group
    function createGroup(
        string memory groupName,
        string memory description,
        uint256 reward,
        uint256 participantLimit
    ) public payable {
        require(msg.value == reward, "Reward amount must be provided.");
        require(participantLimit > 0, "Participant limit must be greater than zero.");

        address[] memory participants;

        studyGroups.push(StudyGroup({
            groupName: groupName,
            description: description,
            creator: msg.sender,
            reward: reward,
            participantLimit: participantLimit,
            participants: participants,
            isActive: true
        }));

        emit GroupCreated(studyGroups.length - 1, groupName, description, msg.sender, reward, participantLimit);
    }

    // Join a study group
    function joinGroup(uint256 groupId) public {
        StudyGroup storage group = studyGroups[groupId];
        require(group.isActive, "This group is no longer active.");
        require(group.participants.length < group.participantLimit, "This group is full.");

        group.participants.push(msg.sender);

        if (group.participants.length == group.participantLimit) {
            group.isActive = false;
            distributeRewards(groupId);
        }

        emit ParticipantJoined(groupId, msg.sender);
    }

    // Distribute rewards equally among participants
    function distributeRewards(uint256 groupId) internal {
        StudyGroup storage group = studyGroups[groupId];
        uint256 rewardPerParticipant = group.reward / group.participants.length;

        for (uint256 i = 0; i < group.participants.length; i++) {
            userRewards[group.participants[i]] += rewardPerParticipant;
        }
    }

    // Withdraw rewards
    function withdrawRewards() public {
        uint256 amount = userRewards[msg.sender];
        require(amount > 0, "No rewards to withdraw.");

        userRewards[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit RewardClaimed(0, msg.sender, amount); // groupId is optional here
    }

    // Get all study groups
    function getAllGroups() public view returns (StudyGroup[] memory) {
        return studyGroups;
    }
}
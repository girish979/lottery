pragma solidity ^0.5.7;

contract Lottery {

  bool public isLocked = true;

  uint maxParticipants;
  uint minParticipants;
  uint joinedParticipants;
  address organizer;
  
  bool drawFinished = false;
  address[] participants;
  mapping (address => bool) participantsMapping;
  
  uint[] private winnersParticipantIdList;
  address[] private winnersListAddress;
  uint winnersSelected;
  uint totalWinners;
  
  event ChooseWinner(uint _chosenNumber,address winner);
  event RandomNumberGenerated(uint);
  
  
  modifier onlyOwner () {
    require (msg.sender == organizer);
    _;
  }

  modifier onlyUnlocked () {
    require (!isLocked);
    _;
  }
  
  constructor (uint _minPlayers, uint _maxPlayers, uint _totWinners) public {
    organizer = msg.sender; 
    uint _min = _minPlayers; 
    uint _max = _maxPlayers; 
    require(_min < _max && _min >=2 && _max <=100);
    maxParticipants = _max;
    minParticipants = _min;
    joinedParticipants = 0;
    winnersSelected=0;
    totalWinners = _totWinners;
  }
  
  function lockContract () public onlyOwner {
    isLocked = true;
  }
  
  function unlockContract () public onlyOwner {
    isLocked = false;
  }
  
  function joinContest() public {
    require(!drawFinished);
    require(msg.sender != organizer);
    require(joinedParticipants + 1 < maxParticipants);
    require(!participantsMapping[msg.sender]);
    participants.push(msg.sender);
    participantsMapping[msg.sender] = true;
    joinedParticipants ++;
  }
  
  function addParticipant(address _participantAddr) public onlyOwner {
    require(!drawFinished);
    require(_participantAddr != organizer);
    require(joinedParticipants + 1 < maxParticipants);
    require(!participantsMapping[_participantAddr]);
    participants.push(_participantAddr);
    participantsMapping[_participantAddr] = true;
    joinedParticipants ++;
  }
  
  function modifyParticipantLimits (uint _min, uint _max) public onlyOwner {
    require(_min < _max && _min >=2 && _max <=100);
    maxParticipants = _max;
    minParticipants = _min;
  }
  
  function modifyWinnersCount (uint _count) public onlyOwner {
    require(!drawFinished);
    require(_count >= 1);
    totalWinners = _count;
  }
  
  function chooseWinner(uint _chosenNum) internal {
    winnersParticipantIdList.push(_chosenNum);
    winnersListAddress.push(participants[_chosenNum]);
    winnersSelected = winnersSelected+1;
    emit ChooseWinner(_chosenNum,participants[_chosenNum]);
  }
  
  function setWinners(uint[] memory list) public onlyOwner onlyUnlocked{
      require(!drawFinished);
      require(list.length == totalWinners);
      require(joinedParticipants >=minParticipants && joinedParticipants<=maxParticipants);
        for (uint i=0; i<list.length; i++) {
            chooseWinner(list[i]);
        }
      drawFinished=true;
  }

  /*function generateRandomNum() internal{
    require(!drawFinished);
    require(winnersSelected+1 <= totalWinners);
    require(joinedParticipants >=minParticipants && joinedParticipants<=maxParticipants);
    
    //TODO: Select random number
    
    bool validSelction = true;
    do{
        for (uint i=0; i<winnersParticipantIdList.length; i++) {
            if(winnersParticipantIdList[i] == winnersSelected)
                validSelction = false;   
        }
    }while(validSelction == false);

    chooseWinner(winnersSelected); 
  }

  function callDraw() public onlyOwner onlyUnlocked{
    require(!drawFinished);
    for (uint i=0; i<totalWinners; i++) {
        generateRandomNum();
    }
    drawFinished=true;
  }*/

  function getWinnerbyList() public view returns (uint[] memory, address[] memory) {
    return (winnersParticipantIdList , winnersListAddress);
  }
  
  function getParticipants() public view returns (address[] memory) {
      return participants;
  }

  function getParticipantLimits() public view returns (uint, uint) {
      return (maxParticipants, maxParticipants);
  }

  function getWinnersCount() public view returns (uint) {
      return (totalWinners);
  }

  function getJoinedParticipantsCount() public view returns (uint) {
      return (joinedParticipants);
  }

}

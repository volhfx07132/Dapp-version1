pragma solidity >0.4.0 < 0.9.0;
contract Ownable{
    address payable public owner;
    //this modifier
    modifier onlyOwner(){
        require(msg.sender == owner, "Only onwer");
        _;
    }
    //this is contructor
    constructor(){
    owner = payable(msg.sender);
  }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";

contract DEGY_token is ERC721, ERC721Enumerable, ERC721URIStorage {
    address public owner;
    uint currentTokenId=1;
    address public main_contract;
    mapping(address => uint) public stacked;

    struct blockToken {
        uint amount;
        uint pool;
    }



    mapping(address => uint) public investments_by_adr;
    address[] public users;
    uint[] public investments;    
    address[] public users_with_nft;
    address[] public users_with_refund;
    bool ended;


    constructor() ERC721("NoNamePoolNFT", "NNP") {
        owner = msg.sender;
        main_contract = msg.sender;
    }

    function main_owner_set(address to) public {
        require(owner == msg.sender, "not an owner!");
        main_contract = to;
    }

////////////////////////

    function invest_in_DEGY() payable external {
        uint value= msg.value;
        if (investments_by_adr[msg.sender]>0) {
            investments_by_adr[msg.sender]=investments_by_adr[msg.sender]+value;
            uint place=get_user_place_in_arr(msg.sender, users);
            investments[place]=investments[place]+value;
        }
        else {
            users.push(msg.sender);
            investments.push(value);
            investments_by_adr[msg.sender]=value;
        }


    } 


    function get_user_place_in_arr(address user, address[] memory _arr) public pure returns (uint){
        for (uint i = 0; i < _arr.length; i++) {
            if (user==_arr[i]){
                return _arr.length-i;
            }
        }
        return 0;

    }

    function is_used_var_address(address _user, address[] memory _array_users) public pure returns (bool){
        for (uint i = 0; i < _array_users.length; i++) {
            if (_array_users[i]==_user){
                return true;
            }
        }        
        return false;
    }

    function get_user_board() public view returns (address[] memory,uint[] memory){
        uint[] memory R_balance = new uint[](users.length);
        for (uint i = 0; i < users.length; i++) {
            R_balance[i] = investments_by_adr[ users[i]];
        }
        address[] memory used_address = new address[](users.length);
        uint count_used_address = 0;

        uint[] memory new_balance = new uint[](users.length);
        address[] memory new_address = new address[](users.length);
        address minimum_adr = users[0];
        uint minimum_sum = R_balance[0];        

        for (uint i = 0; i < investments.length; i++) {
            for (uint j = 0; j < investments.length; j++) {
                if (is_used_var_address(users[j],used_address)==false){
                    minimum_adr = users[j];
                    minimum_sum = R_balance[j]; 
                }
            }
            for (uint j = 0; j < investments.length; j++) {
                if (is_used_var_address(users[j],used_address)==false){
                    if (R_balance[j]<minimum_sum){
                    minimum_adr = users[j];
                    minimum_sum = R_balance[j];                         
                    }
                }            
        
            }
            used_address[count_used_address]=minimum_adr;
            new_address[count_used_address]=minimum_adr;
            new_balance[count_used_address]=minimum_sum;
            count_used_address=count_used_address+1;       
        }
        return (new_address,new_balance);
        
    }

/////////////////////////
    function send_rewards_nft(uint _count) public {
        uint[] memory new_balance = new uint[](users.length);
        address[] memory new_address = new address[](users.length);        
        (new_address,new_balance)=get_user_board();         
        for (uint j = 0; j < _count; j++) {
            users_with_nft.push(new_address[j]);
            safeMint(new_address[j]);
            payable(msg.sender).transfer(investments_by_adr[new_address[j]]);
            }
        ended = true;
    }


    function get_my_investment_back() public {
        require( ended = true,"Sale not ended!");
        require(get_user_place_in_arr(msg.sender, users_with_nft)==0,"you get NFT already, or get you investment back");
        require(get_user_place_in_arr(msg.sender, users_with_refund)==0,"you get NFT already, or get you investment back");
        payable(msg.sender).transfer(investments_by_adr[msg.sender]);
        users_with_refund.push(msg.sender);
    }
///////////////////////////
    function safeMint(address to) public {
        require(main_contract == msg.sender, "not an owner!");        
        _safeMint(to, currentTokenId);
        currentTokenId=currentTokenId+1;
    }




    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns(string memory) {
        return "https://degy.io/metadata/";
    }

    function _burn(uint tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

  
}
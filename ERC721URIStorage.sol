//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";

abstract contract ERC721URIStorage is ERC721 {
    mapping(uint => string) private _tokenURIs;

    function tokenURI(uint tokenId) public view virtual override returns(string memory) {
	    require(_exists(tokenId), "not minted!");
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if(bytes(base).length == 0) {
            return _tokenURI;
        }

        if(bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "not minted!");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint tokenId) internal virtual override {
        super._burn(tokenId);

        if(bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
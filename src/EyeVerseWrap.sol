// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/erc721a/contracts/ERC721A.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "../node_modules/operator-filter-registry/src/DefaultOperatorFilterer.sol";


contract EyeVerseWrap is ERC721Enumerable, Ownable, DefaultOperatorFilterer {

    using Strings for uint256;
    string public baseURI;
    string public baseExtension = ".json";
    ERC721A oldContract;


    constructor(address _oldContract) ERC721("EyeVerseWrap", "EVW") {
        oldContract = ERC721A(_oldContract);
        //REPLACE THIS WITH MAIN IPFS ID
        setBaseURI("ipfs://QmdS78Kx7z8s9NbpVvrk5wsRGL7RQC84S2qhVCPH7qZiF1/"); 
    }

    modifier checkOwnerShipOld(uint256 _tokenId) {
        require(
            oldContract.ownerOf(_tokenId) == msg.sender,
            "You are not the owner of this NFT"
        );
        _;
    }

    modifier checkOwnerShipNew(uint256 _tokenId) {
        require(
            ownerOf(_tokenId) == msg.sender,
            "You are not the owner of this NFT"
        );
        _;
    }


    // should mint a token and lock the previous one
    // if already minted and contract has it so return it and

    // APPROVE BEFORE THIS (APPROVE OLD CONTRACT TO TAKE THE OLD NFT CALLING APPROVE OF THE OLD CONTRACT)
    function singleMintWrap(uint256 tokenId) public checkOwnerShipOld(tokenId) {
        // If token doesn't exists then mint and transfer
        if (!_exists(tokenId)) {
            oldContract.transferFrom(msg.sender, address(this), tokenId);
            _safeMint(msg.sender, tokenId);
        } 
        // If token exists then take old and give new
        else if (_exists(tokenId)) {
            require(ownerOf(tokenId) == address(this), "Contract doesn't have this token");
            oldContract.transferFrom(msg.sender, address(this), tokenId);
            _transfer(address(this), msg.sender, tokenId);

        }
    }

    function multiplrMintWrap(uint[] memory tokenId) public {
        uint i;
        for(i = 0; i < tokenId.length; i++ ){
        singleMintWrap(tokenId[i]);
        }
    }
    //Take the new NFT and return the Old NFT
    // APPROVE BEFORE THIS (APPROVE THIS CONTRACT TO TAKE THE NEW NFT CALLING APPROVE OF THIS CONTRACT)
    function singleUnwrap(uint _tokenId) public checkOwnerShipNew(_tokenId){
        require(oldContract.ownerOf(_tokenId) == address(this), "Contract doesn't have this token");
        transferFrom(msg.sender, address(this), _tokenId);
        oldContract.safeTransferFrom(address(this), msg.sender, _tokenId);
    }

       function multiplrUnWrap(uint[] memory tokenId) public {
        uint i;
        for(i = 0; i < tokenId.length; i++ ){
        singleUnwrap(tokenId[i]);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function setApprovalForAll(address operator, bool approved)
        public
        override(ERC721, IERC721)
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        override(ERC721, IERC721)
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}

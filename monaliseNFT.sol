// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

contract MonalisaNFT is ERC721,ERC165 {
    
    // event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    // event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    // event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    mapping(address => uint256) internal _balanceOf;
    mapping(uint256 => address) internal _ownerOf;
    mapping(uint256 => address) internal _approvals;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    constructor() {
        _ownerOf[1] = msg.sender;
        _balanceOf[msg.sender] = 1;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "Invalid address");
        return _balanceOf[_owner];
    }

     function ownerOf(uint256 _tokenId) external view returns (address) {
        address owner = _ownerOf[_tokenId];
        require(owner != address(0), "The token does not exists");
        return owner;
     }

     function _isApprovedOrOwner(address _owner, address _spender, uint256 _tokenId) internal view returns(bool) {
        return _owner == _spender 
            || _spender == _approvals[_tokenId]
            || isApprovedForAll[_owner][_spender];
     }
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
       _transferFrom(_from,_to,_tokenId);
    }
   
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(_from == _ownerOf[_tokenId], "from != owner");
        require(_to != address(0), "Invalid address"); 

        // Verificar se o msg.sender possui autorização para transferir o NFT
        require(msg.sender == _ownerOf[_tokenId],"You do not have permissionss");
        // require(_isApprovedOrOwner(_ownerOf[_tokenId], msg.sender, _tokenId),"You do not have permission");

        // Transferência
        _balanceOf[_from]--;
        _balanceOf[_to]++;
        _ownerOf[_tokenId] = _to;  

        emit Transfer(_from, _to, _tokenId);

        delete _approvals[_tokenId];
        emit Approval(_from, address(0), _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _transferFrom(_from,_to,_tokenId);

        require(_to.code.length == 0 || 
        ERC721TokenReceiver(_to).onERC721Received(msg.sender,_from,_tokenId,"")
        == ERC721TokenReceiver.onERC721Received.selector,
        "unsafe recipient");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable {
        _transferFrom(_from,_to,_tokenId);
        require(_to.code.length == 0 || 
        ERC721TokenReceiver(_to).onERC721Received(msg.sender,_from,_tokenId,data)
        == ERC721TokenReceiver.onERC721Received.selector);        
    }

     function approve(address _approved, uint256 _tokenId) external payable {
        address owner = _ownerOf[_tokenId];
        require(owner == msg.sender
                || isApprovedForAll[owner][msg.sender], "Not authorized");   
        _approvals[_tokenId] = _approved;   
        emit Approval(owner, _approved, _tokenId);
    }

   function getApproved(uint256 _tokenId) external view returns (address) {
        require(_ownerOf[_tokenId] != address(0), "token does not exists");  
        return _approvals[_tokenId];
   }

    function setApprovalForAll(address _operator, bool _approved) external {
        isApprovedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return interfaceID == type(ERC721).interfaceId;
            
    }
}

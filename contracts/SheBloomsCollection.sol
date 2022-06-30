// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/*********************************************************************************************

   .-'''-. .---.  .---.     .-''-.                                           
  / _     \|   |  |_ _|   .'_ _   \                                          
 (`' )/`--'|   |  ( ' )  / ( ` )   '                                         
(_ o _).   |   '-(_{;}_). (_ o _)  |                                         
 (_,_). '. |      (_,_) |  (_,_)___|                                         
.---.  \  :| _ _--.   | '  \   .---.                                         
\    `-'  ||( ' ) |   |  \  `-'    /                                         
 \       / (_{;}_)|   |   \       /                                          
  `-...-'  '(_,_) '---'    `'-..-'                                           
 _______     .---.       ,-----.        ,-----.    ,---.    ,---.   .-'''-.  
\  ____  \   | ,_|     .'  .-,  '.    .'  .-,  '.  |    \  /    |  / _     \ 
| |    \ | ,-./  )    / ,-.|  \ _ \  / ,-.|  \ _ \ |  ,  \/  ,  | (`' )/`--' 
| |____/ / \  '_ '`) ;  \  '_ /  | :;  \  '_ /  | :|  |\_   /|  |(_ o _).    
|   _ _ '.  > (_)  ) |  _`,/ \ _/  ||  _`,/ \ _/  ||  _( )_/ |  | (_,_). '.  
|  ( ' )  \(  .  .-' : (  '\_/ \   ;: (  '\_/ \   ;| (_ o _) |  |.---.  \  : 
| (_{;}_) | `-'`-'|___\ `"/  \  ) /  \ `"/  \  ) / |  (_,_)  |  |\    `-'  | 
|  (_,_)  /  |        \'. \_/``".'    '. \_/``".'  |  |      |  | \       /  
/_______.'   `--------`  '-----'        '-----'    '--'      '--'  `-...-'   
                                                                                                                                                                                                        
**********************************************************************************************
 DEVELOPER James Iacabucci
 ARTIST Kelley Art Botanica
*********************************************************************************************/

contract SheBloomsCollection is ERC721A, Ownable, ReentrancyGuard {
    using Strings for uint256;

    bytes32 public goldListMerkleRoot;
    mapping(address => bool) public goldListClaimed;

    bytes32 public freeListMerkleRoot;
    mapping(address => bool) public freeListClaimed;

    string public uriPrefix = "";
    string public uriSuffix = ".json";
    string public hiddenMetadataUri;

    uint256 public cost;
    uint256 public maxSupply;
    uint256 public mintLimit;
    uint256 public maxMintAmountPerTx;

    bool public paused = true;
    bool public revealed = false;
    bool public released = false;
    bool public freeListMintEnabled = false;
    bool public goldListMintEnabled = false;
    bool public preSaleMintEnabled = false;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _cost,
        uint256 _maxSupply,
        uint256 _maxMintAmountPerTx,
        string memory _hiddenMetadataUri
    ) ERC721A(_tokenName, _tokenSymbol) {
        setCost(_cost);
        maxSupply = _maxSupply;
        mintLimit = _maxSupply;
        setMaxMintAmountPerTx(_maxMintAmountPerTx);
        setHiddenMetadataUri(_hiddenMetadataUri);
    }

    modifier mintCompliance(uint256 _mintAmount) {
        uint256 newSupply = totalSupply() + _mintAmount;
        require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "You can not mint this many items");
        require(newSupply <= maxSupply && newSupply <= mintLimit, "This purchase exeeds the maximum number of NFTS allowed for this sale");
        _;
    }

    modifier mintPriceCompliance(uint256 _mintAmount) {
        require(msg.value >= cost * _mintAmount, "You did not send enough ETH to complete this purchase");
        _;
    }

    function freeListMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable mintCompliance(_mintAmount) {
        // Verify Free List requirements
        require(freeListMintEnabled, "The Free Mint sale is not open!");
        require(!freeListClaimed[_msgSender()], "Your address has already claimed its Free List NFT!");
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        require(MerkleProof.verify(_merkleProof, freeListMerkleRoot, leaf), "This is an invalid Free List proof!");

        freeListClaimed[_msgSender()] = true;
        _safeMint(_msgSender(), _mintAmount);
    }

    function goldListMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)
        public
        payable
        mintCompliance(_mintAmount)
        mintPriceCompliance(_mintAmount)
    {
        // Verify Gold List requirements
        require(goldListMintEnabled, "The Gold List sale is not active!");
        require(!goldListClaimed[_msgSender()], "Your address has already claimed its Gold List NFT!");
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        require(MerkleProof.verify(_merkleProof, goldListMerkleRoot, leaf), "This is an invalid Gold List proof!");

        goldListClaimed[_msgSender()] = true;
        _safeMint(_msgSender(), _mintAmount);
    }

    function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
        require(!paused, "The sale is paused!");
        _safeMint(_msgSender(), _mintAmount);
    }

    function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
        _safeMint(_receiver, _mintAmount);
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = _startTokenId();
        uint256 ownedTokenIndex = 0;
        address latestOwnerAddress;

        while (ownedTokenIndex < ownerTokenCount && currentTokenId < _currentIndex) {
            TokenOwnership memory ownership = _ownerships[currentTokenId];

            if (!ownership.burned) {
                if (ownership.addr != address(0)) {
                    latestOwnerAddress = ownership.addr;
                }

                if (latestOwnerAddress == _owner) {
                    ownedTokenIds[ownedTokenIndex] = currentTokenId;
                    ownedTokenIndex++;
                }
            }
            currentTokenId++;
        }

        return ownedTokenIds;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: the token specified does not exist");

        if (revealed == false) {
            return hiddenMetadataUri;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix)) : "";
    }

    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

    function setMintLimit(uint256 _mintLimit) public onlyOwner {
        mintLimit = _mintLimit;
    }

    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function setReleased(bool _state) public onlyOwner {
        released = _state;
    }

    function setFreeListMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        freeListMerkleRoot = _merkleRoot;
    }

    function setFreeListMintEnabled(bool _state) public onlyOwner {
        freeListMintEnabled = _state;
    }

    function setGoldListMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        goldListMerkleRoot = _merkleRoot;
    }

    function setGoldListMintEnabled(bool _state) public onlyOwner {
        goldListMintEnabled = _state;
    }

    function setPreSaleMintEnabled(bool _state) public onlyOwner {
        preSaleMintEnabled = _state;
    }

    function withdraw() public onlyOwner nonReentrant {
        // Test of spliting up minting fees to various parties
        //(bool hs, ) = payable(0x7081a60B472E61Ec93b81521B77945c10c463670).call{value: (address(this).balance * 30) / 100}("");
        //require(hs);

        // Transfer the remaining contract balance to the owner.
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }
}

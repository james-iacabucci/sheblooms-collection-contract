// SPDX-License-Identifier: MIT LICENSE

pragma solidity >=0.8.9 <0.9.0;

import "./SheBloomsToken.sol";
import "./SheBloomsCollection.sol";

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

contract SheBloomsStaking is Ownable, IERC721Receiver {
    uint256 public totalStaked;
    uint256 public earningRate = 10000;
    bool public paused = false;

    // reference to the collection and token contracts
    SheBloomsCollection nft;
    SheBloomsToken token;

    // struct to store a stake's token, owner, and earning values
    struct Stake {
        uint24 tokenId;
        uint48 timestamp;
        address owner;
    }
    // maps tokenId to stake
    mapping(uint256 => Stake) public vault;

    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
    event Claimed(address owner, uint256 amount);

    constructor(SheBloomsCollection _nft, SheBloomsToken _token) {
        nft = _nft;
        token = _token;
    }

    function setRate(uint256 _rate) public onlyOwner {
        earningRate = _rate;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function stake(uint256[] calldata tokenIds) external {
        require(!paused, "Staking is not active.");
        uint256 tokenId;
        totalStaked += tokenIds.length;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(nft.ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
            require(vault[tokenId].tokenId == 0, "This NFT is already staked");

            nft.transferFrom(msg.sender, address(this), tokenId);
            emit NFTStaked(msg.sender, tokenId, block.timestamp);

            vault[tokenId] = Stake({owner: msg.sender, tokenId: uint24(tokenId), timestamp: uint48(block.timestamp)});
        }
    }

    function claim(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, false);
    }

    function claimForAddress(address account, uint256[] calldata tokenIds) external {
        _claim(account, tokenIds, false);
    }

    function unstake(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, true);
    }

    function _claim(
        address account,
        uint256[] calldata tokenIds,
        bool _unstake
    ) internal {
        uint256 tokenId;
        uint256 stakedAt;
        uint256 earned = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            require(staked.owner == account, "You are not the owner of this NFT");
            stakedAt = staked.timestamp;
            earned += (earningRate * (block.timestamp - stakedAt)) / 1 days;
            vault[tokenId] = Stake({owner: account, tokenId: uint24(tokenId), timestamp: uint48(block.timestamp)});
        }

        if (earned > 0) {
            earned = earned / 10;
            token.mint(account, earned);
        }

        if (_unstake) {
            _unstakeMany(account, tokenIds);
        }

        emit Claimed(account, earned);
    }

    function earningInfo(uint256[] calldata tokenIds) external view returns (uint256) {
        uint256 tokenId;
        uint256 stakedAt;
        uint256 earned = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            // make sure token is staked and owned by user (or admin)
            require(staked.owner == msg.sender, "You are not the owner of this NFT");
            stakedAt = staked.timestamp;
            earned += (earningRate * (block.timestamp - stakedAt)) / 1 days;
        }
        return earned / 10;
    }

    function _unstakeMany(address account, uint256[] calldata tokenIds) internal {
        uint256 tokenId;
        totalStaked -= tokenIds.length;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            require(staked.owner == msg.sender, "not an owner");

            delete vault[tokenId];
            emit NFTUnstaked(account, tokenId, block.timestamp);
            nft.transferFrom(address(this), account, tokenId);
        }
    }

    // should never be used inside of transaction because of gas fee
    function balanceOf(address account) public view returns (uint256) {
        uint256 balance = 0;
        uint256 supply = nft.totalSupply();
        for (uint256 i = 1; i <= supply; i++) {
            if (vault[i].owner == account) {
                balance += 1;
            }
        }
        return balance;
    }

    // should never be used inside of transaction because of gas fee
    function tokensOfOwner(address account) public view returns (uint256[] memory ownerTokens) {
        uint256 supply = nft.totalSupply();
        uint256[] memory tmp = new uint256[](supply);

        uint256 index = 0;
        for (uint256 tokenId = 1; tokenId <= supply; tokenId++) {
            if (vault[tokenId].owner == account) {
                tmp[index] = vault[tokenId].tokenId;
                index += 1;
            }
        }

        uint256[] memory tokens = new uint256[](index);
        for (uint256 i = 0; i < index; i++) {
            tokens[i] = tmp[i];
        }

        return tokens;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot send nfts to Vault directly");
        return IERC721Receiver.onERC721Received.selector;
    }
}

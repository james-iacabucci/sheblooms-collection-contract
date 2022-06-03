// SPDX-License-Identifier: MIT LICENSE

pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

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

contract SheBloomsToken is ERC20, ERC20Burnable, Ownable {
    mapping(address => bool) controllers;

    constructor() ERC20("SheBloomsToken", "BLOOMS") {}

    function mint(address to, uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        _mint(to, amount);
    }

    function burnFrom(address account, uint256 amount) public override {
        if (controllers[msg.sender]) {
            _burn(account, amount);
        } else {
            super.burnFrom(account, amount);
        }
    }

    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
    }

    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
    }
}

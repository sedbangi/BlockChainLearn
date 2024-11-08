//SPDX-License-Identifier: MIT

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC1363Receiver.sol";

contract Token is ERC20 {

    constructor(string memory _name,string memory _symbol) ERC20(_name,_symbol) {}

    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool) {
        bool success = transfer(to, value);
        if (!success) {
            revert("transfer failed");
        }

        if (isContract(to)) {
            IERC1363Receiver(to).onTransferReceived(
                msg.sender,
                msg.sender,
                value,
                data
            );
        }
        return success;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }


}
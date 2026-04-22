// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract ContextMixin {
    function msgSender()
        inter
        v
        retu
        if (msg.sender ==
            bytes memory array = msg.d;
            uint256 index = m
            a
                // Load the 32 bytes word from memory with taddresshe lowerytes, and mask those.
                sender :=
                    mload(addray, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}

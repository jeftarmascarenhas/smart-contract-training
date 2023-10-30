// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract PaginationPattern {
    uint256 ids;

    mapping(uint256 => Item) public data;

    struct Item {
        string name;
        uint256 price;
    }

    function add(Item calldata item) public {
        data[ids] = item;
        ids++;
    }

    function fetchPage(uint256 cursor, uint256 howMany)
    public
    view
    returns (Item[] memory items, uint256 newCursor)
    {
        uint256 length = howMany;
        if (length > ids - cursor) {
            length = ids - cursor;
        }

        items = new Item[](length);
        for (uint256 i = 0; i < length; i++) {
            items[i] = data[cursor + i];
        }

        return (items, cursor + length);
    }
}
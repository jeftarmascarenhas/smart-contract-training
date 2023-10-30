// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ArrayPagination {
    uint256 ids;

    mapping(uint256 => Item) public arr;

    struct Item {
        string name;
        uint256 price;
    }

    function add(Item calldata data) public {
        arr[ids] = data;
        ids++;
    }

    function fetchPage(uint256 cursor, uint256 howMany)
    public
    view
    returns (Item[] memory values, uint256 newCursor)
    {
        uint256 length = howMany;
        if (length > ids - cursor) {
            length = ids - cursor;
        }

        values = new Item[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = arr[cursor + i];
        }

        return (values, cursor + length);
    }
}
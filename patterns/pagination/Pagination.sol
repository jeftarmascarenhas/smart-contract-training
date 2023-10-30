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

    function fetchPage(uint256 cursor, uint256 pageSize)
    public
    view
    returns (
        Item[] memory items,
        uint256 newCursor
    ) {
        // No vídeo não tem esse trecho de código mais ele valida o tamanho que será retornado.
        uint256 length = pageSize;
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
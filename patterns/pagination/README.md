# Pattern Cursor Pagination Solidity

Cursor-based paging works by using a unique, sequential key that indicates from which record the data will be returned.

This smart contract has many features like:
- Cursor Pagination pattern with solidity
- Create memory array from mapping

See how to make this smart contract [click here](https://www.youtube.com/@nftchoose)

<hr />

A paginação baseada em cursor funciona por uma chave única e sequencial que indica a partir de que 
registro os dados serão retornados.

Este contrato inteligente tem muitos recursos como:
- Padrão de paginação utilizando cursor com solidity

Veja como fazer este smart contract [click here](https://www.youtube.com/@nftchoose)

## Cursor Pattern Pagination

```javascript
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
```
# How to create a Context Wallet Smart Contract

Provides information about the current execution context and avoid access `msg.sender` and
`msg.data` directly.

See how to make this smart contract [click here](https://www.youtube.com/@nftchoose)

<hr />

Fornece informações sobre o contexto de execução atual e evita o acesso direto ao `msg.sender` e `msg.data`.

Veja como fazer este smart contract [click here](https://www.youtube.com/@nftchoose)

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/*
    Jeftar Mascarenhas
    twitter: @jeftar
    github: github.com/jeftarmascarenhas
    linkedin: linkedin.com/in/jeftarmascarenhas/
    site: jeftar.com.br
    youtube: youtube.com/@nftchoose
*/

contract Context {
    function _msgSender() internal view virtual returns(address) {
        return msg.sender;
    }

    function msgData() internal view virtual returns(bytes calldata) {
        return msg.data;
    }
}
```
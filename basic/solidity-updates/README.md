# User Defined Value Types in Solidity

Solidity v0.8.8 introduces user defined value types as a means to create zero-cost abstractions over an elementary value type that also increases type safety and improves readability.

A problem with primitive value types is that they are not very descriptive: they only specify how the data is stored and not how it should be interpreted.

For example, one may want to use `uint128` to store the price of some object as well as the quantity available. It is quite useful to have stricter type rules to avoid intermingling of the two different concepts. For example, one may want to disallow assigning a quantity to a price or vice versa.

## User Defined Type in Solidity

```javascript
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

/**
 * Definindo tipos de valor personalizados para diferentes propósitos
 */
type USDCamount is uint256;
type DAIamount is uint256;

contract Bank {
    USDCamount public usdcBalance;
    DAIamount public daiBalance;

    /**
     * Função para depositar USDC
     */
    function depositUSDC(USDCamount amount) public {
        usdcBalance = USDCamount.wrap(
            USDCamount.unwrap(usdcBalance) + USDCamount.unwrap(amount)
        );
    }

    /**
     * Função para depositar DAI
     */
    function depositDAI(DAIamount amount) public {
        daiBalance = DAIamount.wrap(
            DAIamount.unwrap(daiBalance) + DAIamount.unwrap(amount)
        );
    }

    /**
     * Função que tenta misturar tipos errados
     * Remova o comentário para ver o error
     */
    function errorDeposit(uint256 amount) public {
        //   usdcBalance = usdcBalance + amount; // Erro de compilação, tipos incompatíveis
    }

    /**
     * Função que converte explicitamente entre tipos - permitido, mas com cautela
     */
    function explicitConversion(
        USDCamount usdcAmount,
        DAIamount etherAmount
    ) public pure returns (uint256) {
        uint256 total = USDCamount.unwrap(usdcAmount) +
            DAIamount.unwrap(etherAmount); // Permitido, mas exige conversão explícita
        return total;
    }
}
```

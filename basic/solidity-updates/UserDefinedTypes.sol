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

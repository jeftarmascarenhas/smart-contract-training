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

abstract contract Context {
    function _msgSender() internal view virtual returns(address) {
        return msg.sender;
    }

    function msgData() internal view virtual returns(bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Módulo de contrato que permite implementar controle de acesso.
 * Esta é uma versão leve que não permite enumerar função 
 * membros, exceto por meios off-chain, acessando os logs de eventos do contrato. 
 */
abstract contract AccessControl is Context {
    bytes32 public constant _DEFAULT_ADMIN = 0x00;

    mapping(bytes32 => mapping(address => bool)) private _roles;

    modifier onlyRole(bytes32 role_) {
        _checkRole(role_);
        _;
    }

    modifier _onlyAdmin() virtual {
        require(_roles[_DEFAULT_ADMIN][_msgSender()], "Only admin");
        _;
    }

    function _grantRole(bytes32 role_, address account_) internal virtual {
        _roles[role_][account_] = true;
    }

    function _checkRole(bytes32 role_) internal view virtual{
      _checkRole(role_, _msgSender());
    }
    
    function _checkRole(bytes32 role_, address account_) internal view virtual{
      if (!hasRole(role_, account_)) {
        revert("AccessControl: account is missing role");
      }
    }
    

    function setRole(bytes32 role_, address account_) public _onlyAdmin {
        _grantRole(role_, account_);
    }
    
    function revokeRole(bytes32 role_, address account_) public _onlyAdmin {
        _roles[role_][account_] = false;
    }
    
    function hasRole(bytes32 role_, address account_) internal view virtual returns(bool) {
        return _roles[role_][account_];
    }
}

contract MyContract is AccessControl {
    bytes32 constant public _USER = keccak256("USER");
    bytes32 constant public _ADMIN = keccak256("ADMIN");

    constructor() {
        _grantRole(_DEFAULT_ADMIN, msg.sender);
    }

    function getUser() external view onlyRole(_USER) returns(string memory) {
        return  "HEY, you are user";
    }
    
    function getAdmin() external view onlyRole(_ADMIN) returns(string memory) {
        return  "HEY, you are admin";
    }
}
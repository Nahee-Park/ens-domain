// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.10;
import {StringUtils} from './libraries/StringUtils.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";

contract Domains {

    // 구조체를 import해서 직접 가져다 쓰갰다는 의미
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // 그 내부의 increment를 사용
    // _tokenIds.increment();

    address payable public domainContractOwner;

    //string 선언
    string public tld;

    // 실제 주인 
    mapping (string => address) public domains;

    // 포인팅 어디로? 
    mapping (string => string) public records;

    // memory는 스코프 끝날 때까지만 갖고 있음, payable을 붙여주면 돈을 쏠 수 있음 
    constructor(string memory _tld) payable{
        console.log("This is my domain contract.");
        // patable한 객체를 내부적으로 만듦
        domainContractOwner = payable (msg.sender);
        tld = _tld;
    }

    function price(string calldata name) public pure returns (uint){
        // 문자열 길이에 따라 돈을 매겨보겠음
        uint length = StringUtils.strlen(name);
        // 조건 안 맞으면 메시지 뿜뿜
        require(length>0,"smaller than 0 string value length");
        // 길이가 짧을수록 레어하므로 가격을 비싸게 !
        if (length == 3){
            return 5 * (10 ** 17); // 0.5 MATIC
        } else if (length ==4) {
            return 3 * (10 ** 17); // 0.3 MATIC
        } else {
            return 1 * (10 ** 17); // 0.1 MATIC
        }
    }

    // calldata를 통해 가스비 절약 
    function register(string calldata name)  public {
        // 등록된 도메인인지 아닌지를 체크
        require(domains[name] ==address(0), "not registered");
        uint _price = price(name);

        // 보안 취약점이 발견되어 쓰지 않는 것을 권고
        // domainContractOwner.transfer(msg.value);

        (bool success, ) = domainContractOwner.call{
            value: msg.value
        }("");

        require(success == true, "something transaction went wrong.");

        // 트랜젝션에 담기는 이더나 코인의 값에 접근 가능 
        require(msg.value >= _price, "not enough MATIC sent");
        domains[name]= msg.sender;
        console.log("%s has registered a domain", msg.sender);
    }

    // 값 수정할 수 없는 순수함수임을 명시 (view), 반환값 있음을 명시해주기
    function getAddress(string calldata name) public view returns (address) {
        return domains[name];
    }

    function setRecord(string calldata _name, string calldata _record) public {
        // domain의 주인만 domain이 가리키게 될 record 수정 가능 (접근 제한 필요) -> require 사용
        // 접근제한자 -> 소유권이 있는 지를 체크해서 넘어감
        require(domains[_name] == msg.sender, "not an owner");
        records[_name] = _record;
    }

    function getRecord(string calldata name) public view returns (string memory){
        return records[name];
    }
}
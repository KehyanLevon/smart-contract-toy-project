//Указание лицензии
// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract Granny {

    // счетчик количества внуков
    uint8 public counter;

    // внесенный бабушкой депозит (в моменте может отличаться от баланса контракта)
    uint256 public bank;

    // адрес бабушки - владельца контракта
    address public owner;

    // структура - объект внук
    struct Grandchild {
        string name;
        uint256 birthday; //https://www.unixtimestamp.com/
        bool alreadyGotMoney;
        bool exist;
    }

    //массив адресов внуков, для того, чтобы иметь возможность
    //получить полный список внуков
    address[] public arrGrandchilds;

    //ассоциативный массив, который связывает адрес внука со структурой данных о нем
    mapping(address => Grandchild) public grandchilds;

    constructor(){
        owner = msg.sender;
        counter = 0;
    }

    function addGrandChild(
        address walletAddress,
        string memory name,
        uint256 birthday
    ) public onlyOwner {
        require(birthday > 0, "Something is wrong with the date of birth!");
        require(
            grandchilds[walletAddress].exist == false,
            "There is already such a grandchild!"
        );
        grandchilds[walletAddress] = (
            Grandchild(name, birthday, false, true)
        );
        arrGrandchilds.push(walletAddress);
        counter++;
        emit NewGrandChild(walletAddress, name, birthday);
    }

    function readGrandChildsArray(uint cursor, uint length) public view returns (address[] memory) {
        address[] memory array = new address[](length);
        uint counter2 = 0;
        for (uint i = cursor; i < cursor+length; i++) {
            array[counter2] = arrGrandchilds[i];
            counter2++;
        }
        return array;
    }

    function withdraw() public {
        address payable walletAddress = payable(msg.sender);

        require(
            grandchilds[walletAddress].exist == true,
            "There is no such grandchild!"
        );
        require(
            block.timestamp > grandchilds[walletAddress].birthday,
            "Birthday hasn't arrived yet!"
        );
        require(
            grandchilds[walletAddress].alreadyGotMoney == false,
            "You have already received money!"
        );
        uint256 amount = bank / counter;
        grandchilds[walletAddress].alreadyGotMoney = true;
        (bool success, ) = walletAddress.call{value: amount}("");
        require(success);
        emit GotMoney(walletAddress);
    }
    
    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Yuo are not the owner");
        _;
    }

    receive() external payable {
        bank += msg.value;
    }
    
    event NewGrandChild(address indexed walletAddress, string name, uint256 birthday);
    event GotMoney(address indexed walletAddress);
}
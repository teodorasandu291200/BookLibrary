// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Owner.sol";

contract BookLibrary is Owner {

    uint public bookCount = 0;
    uint public totalBookCount = 0;
    uint randNonce = 0;

    event NewBook(string name, uint bookId, uint copies,string message);
    event BorrowBook(string name,uint bookId,  uint copies, string  message);
    event ReturnBook(string name,uint bookId, uint copies, string message);


    struct Book {
        string name;
        uint copies;
        bool isAvailable;
        uint ownerCount;
        mapping(uint256 => address) ownersHistory;
    }

    function randMod(string memory _name) internal returns(uint) {
    randNonce++;
    return uint(keccak256(abi.encodePacked(_name))) ;
  }

    uint public bookId;

    uint[] public listOfBookIds;
    mapping(string => uint) public nameToId;
    mapping(string => bool) private isPresent;
    mapping(uint => Book) public books;


    function _addBooks(string memory _name, uint _copies) internal {
        if(!isPresent[_name]) {
            uint _bookId = randMod(_name);
            listOfBookIds.push(_bookId);
            nameToId[_name] = _bookId;
            isPresent[_name] = true;
        }
        Book storage book = books[nameToId[_name]];
        book.name = _name;
        book.copies = _copies;
        bookCount = bookCount + _copies;
        totalBookCount = totalBookCount + _copies;
        book.isAvailable = true;

        emit NewBook(_name, nameToId[_name], _copies,"You have added books,owner");

    }


    function _borrowBook(string memory _name,  uint _copies ) public {
        require(_copies == 1, "You can borrow one copy at a time");
        Book storage book = books[nameToId[_name]];
        require(isPresent[_name] == true, "You are trying to borrow a book that doesn't exist");
        require(book.isAvailable == true, "The book is currently on loan");
        book.copies = book.copies - _copies;
        bookCount = bookCount - _copies;
        book.ownersHistory[nameToId[_name]] = msg.sender;
        book.ownerCount = book.ownerCount + 1;
        if(book.copies == 1) {
            book.isAvailable = false;
        }

        emit BorrowBook(_name,nameToId[_name], _copies,"You have borrowed books");
    }


    function _returnBook(string memory _name, uint _copies) public {
        Book storage book = books[nameToId[_name]];
        require(book.ownersHistory[nameToId[_name]] == msg.sender, "Requester not the same as owner");
        require(bookCount + _copies <= totalBookCount , "Trying to add too many boooks");

        bookCount = bookCount + _copies;
        book.copies = book.copies + _copies;
        book.isAvailable = true;

        emit ReturnBook(_name,nameToId[_name], _copies,"You have returned books");

    }

    function _returnBookArrayLength() public view returns (uint _bookArrayLength) {

        return listOfBookIds.length;

    }

}

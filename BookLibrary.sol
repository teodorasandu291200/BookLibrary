// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Owner.sol";

contract BookLibrary is Owner {

    uint public bookCount = 0;
    uint public numberOfOwners = 0;
    uint private totalBookCount = 0;

    event NewBook(uint bookId, uint copies,string message);
    event BorrowBook(uint bookId,  uint copies, string  message);
    event ReturnBook(uint bookId, uint copies, string message);


    struct Book {
        uint bookId;
        uint copies;
        bool isAvailable;
    }


    struct History {
        uint bookId;
        address owner;
        uint ownerBooks;
    }

    uint public bookId;
    uint public historyId;

    mapping(uint => Book) public books;
    mapping(uint => History) public bookHistory;

//function _addBooks(uint _bookId, uint _copies) internal  

    function _addBooks(uint _bookId, uint _copies) public {
        Book memory book =  Book(_bookId, _copies, true);
        books[_bookId] = book;
        bookCount = bookCount + _copies;
        totalBookCount = totalBookCount + _copies;
        book.copies = book.copies + _copies;
        book.isAvailable = true;



        emit NewBook(bookId++, _copies,"You have added books,owner");

    }


    function _borrowBook(uint _bookId, uint _copies ) public  {
        require(bookId >= 0  && _copies == 1, "You can borrow one copy at a time");
        Book storage book = books[_bookId];
        require(book.isAvailable == true, "The book is currently on loan");
        book.copies = book.copies - _copies;
        bookCount = bookCount - _copies;
        bookHistory[_bookId].owner = msg.sender;
        if(book.copies == 0) {
            book.isAvailable = false;
        }
        _createHistory(_bookId, _copies);


        emit BorrowBook(_bookId, historyId++,"You have borrowed books");
    }


    function _returnBook(uint _bookId, uint _copies) public {
        require(bookHistory[_bookId].owner == msg.sender, "Requester not the same as owner");
        require(bookCount < totalBookCount ,"Trying to return too many books");
        Book storage book = books[_bookId];
        book.copies = book.copies + _copies;
        History memory history = bookHistory[_bookId];
        bookCount = bookCount + _copies;  
        bookHistory[_bookId].ownerBooks =  _copies;
        history.owner = address(0);

        book.isAvailable = true;


        emit ReturnBook(_bookId, _copies,"You have returned books");

    }


    function getAllAvailableBooks() public view returns (uint256[] memory) {
        uint currentNumber = 0;
        for (uint i = 1; i <= bookCount; i++) {
            if (books[i].isAvailable == true) {
                currentNumber++;
            }
        }
        uint256[] memory result = new uint256[](currentNumber);
        currentNumber = 0;
        for (uint i = 1; i <= bookCount; i++) {
            if (books[i].isAvailable == true) {
                result[currentNumber] = i;
                currentNumber++;
            }
        }
        return result;

    }

    function getOwnerHistoryOfBook(uint _bookId) public view returns (address[] memory) {
        address[] memory result = new address[](bookCount);
        for (uint i = 0; i  < numberOfOwners; i ++) {
            result[i] = bookHistory[_bookId].owner;
        }
        return result;
    }

    function _createHistory(uint _bookId, uint _modifiedBookCount) internal { 
        bookHistory[historyId] = History(_bookId,  msg.sender, _modifiedBookCount);
        Book storage book = books[_bookId];
        numberOfOwners++;

    }
}

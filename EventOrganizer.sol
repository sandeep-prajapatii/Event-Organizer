//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract EventHandler{

    struct Event{
        address organizer;
        string name;
        uint eventId;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping (uint => Event) public events;
    //For mapping organizer's address with the Event

    mapping(address => mapping(uint => uint)) public ticket;
    //For mapping buyers address with the 
    //Buyer can also check how many tickets he owns

    uint internal nextId;
    //For keeping the count of the events with quique number

    Event[] internal allEvents;

    modifier doesTicketExist(uint _id){
        require(events[_id].date != 0, "No such Event with this id");
        require(events[_id].date > block.timestamp, "Event has already occured");
        _;
    }

    function createEvent(string memory _name, uint _date, uint _price, uint _ticketCount)payable external{
        require (_date > block.timestamp, "You can organize event only for future date");
        require (_ticketCount > 0, "Tickets can't be zero!");
        events[nextId] = Event(msg.sender, _name, nextId,_date, _price, _ticketCount,_ticketCount );
        allEvents.push(events[nextId]);
        eventsList();
        nextId++;
    }

    function buyTicket(uint _eventId, uint _quantity ) doesTicketExist(_eventId) payable external{      
        Event storage _event = events[_eventId];
        require (msg.value==(_event.price * _quantity), "Amount is not sufficient");
        require (_event.ticketRemain >= _quantity, "Not Enough Tickets Available");
        _event.ticketRemain -= _quantity;
        ticket[msg.sender][_eventId] += _quantity;
    }

    function transferTicket(uint _eventId, uint _quantity, address _to) doesTicketExist(_eventId) external{
        require(ticket[msg.sender][_eventId] >= _quantity, "You dont have enough tickets");
        ticket[msg.sender][_eventId] -= _quantity;
        ticket[_to][_eventId] += _quantity;
    }

    function remainingTickets(uint _eventId)public view returns(uint){
        return events[_eventId].ticketRemain;
    }

    function eventsList() internal {
        for (uint i = 0; i < allEvents.length; i++) {
            for (uint j = i + 1; j < allEvents.length; j++) {
                if (allEvents[j].date > allEvents[i].date) {
                    Event memory temp = allEvents[i];
                    allEvents[i] = allEvents[j];
                    allEvents[j] = temp;
                }
            }
        }
        //This loop is for sorting the Event array in decreasing of time to make it easy to pop

        for (uint i=allEvents.length-1; i>0;i--){
            if(allEvents[i].date < block.timestamp){
                allEvents.pop();
            }
        }
        //Pops all the events whose time period is over
    }

    function showAllEvents()public view returns(Event[] memory){
        require(allEvents.length >= 1, "There are no events");
        return allEvents;
    }
}









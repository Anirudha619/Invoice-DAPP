pragma solidity ^0.4.23;

contract InvoiceDapp {
    struct Invoice {
        address sellerPAN; // assuming sellerPAN as an address of that user
        address buyerPAN;  // assuming buyerPAN as an address of that user
        uint amount;
        string title;
        string date;
        bool paymentStatus; //true when payment is "paid" else payment will be "due"
    }
    
    Invoice[] internal invoices;
    
    mapping (address => uint[]) internal sellers;
    mapping (address => uint[]) internal buyers;
    mapping (address => uint) public balances;
    
    // function to add invoice
    function addInvoice(address fromAddress, uint amount, string title,string date) public {
        Invoice memory inv = Invoice({
            buyerPAN: fromAddress,
            sellerPAN: msg.sender, 
            amount: amount,
            title: title,
            date : date,
            paymentStatus: false
        });
        
        invoices.push(inv);
        sellers[inv.sellerPAN].push(invoices.length - 1);
        buyers[inv.buyerPAN].push(invoices.length - 1);
    }
    
    // function to get a particular Invoice from that invoice ID
    function getInvoice(uint id) public view returns(address, address, uint, string,string, bool) {
        Invoice memory inv = invoices[id];
        return (inv.sellerPAN, inv.buyerPAN, inv.amount, inv.title, inv.date, inv.paymentStatus);
    }
    
     // function to get list of invoice ID from buyersPAN
    function getInvoiceByBuyer(address _buyerPAN) public view returns(uint[]) {
        return buyers[_buyerPAN];
    }

    // function to pay invoice amount
    function pay(uint id) public payable {
        Invoice storage inv = invoices[id];
        
        require(inv.paymentStatus == false);
        require(inv.buyerPAN == msg.sender);
        require(msg.value == inv.amount);
        
        inv.paymentStatus = true;
        balances[inv.sellerPAN] += msg.value;
    }
    
    // function to withdraw amount in balance
    function withdraw() public {
        require(balances[msg.sender] != 0);
        
        uint toWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(toWithdraw);
    }

}
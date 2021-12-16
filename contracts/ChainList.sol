pragma solidity >0.4.0 < 0.9.0;
import "./Ownable.sol";
contract ChainList is Ownable{
  // state variables
  struct Article{
    uint id;
    address payable seller;
    address payable buyer;
    string name;
    string description;
    uint256 price;
  }
  mapping(uint => Article) public articles;
  uint articleCounter = 0;

  function killContract() public onlyOwner{
    selfdestruct(owner);
  }

  // events
  event LogSellArticle(
    uint indexed _id,
    address indexed _seller,
    string _name,
    uint256 _price
  );
  event LogBuyArticle(
    uint indexed _id,
    address indexed _seller,
    address indexed _buyer,
    string _name,
    uint256 _price
  );

  // sell an article
  function sellArticle(string memory _name, string memory _description, uint256 _price) public {
    articleCounter++;
    articles[articleCounter].id = articleCounter;
    articles[articleCounter].seller = payable(msg.sender);
    articles[articleCounter].buyer = payable(0x0);
    articles[articleCounter].name = _name;
    articles[articleCounter].description = _description;
    articles[articleCounter].price = _price;
    emit LogSellArticle(articleCounter, articles[articleCounter].seller, articles[articleCounter].name, articles[articleCounter].price);
  }

  // get an article
  function getNumberOfArticle() public view returns(uint) {
    return articleCounter;
  }

  function getArticlesForSale() public view returns (uint[] memory) {
    // prepare output array
    uint[] memory articleIds = new uint[](articleCounter);

    uint numberOfArticlesForSale = 0;
    // iterate over articles
    for(uint i = 1; i <= articleCounter;  i++) {
      // keep the ID if the article is still for sale
      if(articles[i].buyer == payable(0x0)) {
        articleIds[numberOfArticlesForSale] = articles[i].id;
        numberOfArticlesForSale++;
      }
    }

    // copy the articleIds array into a smaller forSale array
    uint[] memory forSale = new uint[](numberOfArticlesForSale);
    for(uint j = 0; j < numberOfArticlesForSale; j++) {
      forSale[j] = articleIds[j];
    }
    return forSale;
  }
  // buy an article
  function buyArticle(uint _id) payable public {
    // we check whether there is an article for sale
    require(articleCounter > 0);
    require(_id > 0 && _id <= articleCounter);
    Article storage article = articles[_id]; 
    // we check that the article has not been sold yet
    require(article.buyer == payable(0x0));

    // we don't allow the seller to buy his own article
    require(msg.sender != article.seller);

    // we check that the value sent corresponds to the price of the article
    require(msg.value == article.price);

    // keep buyer's information
    article.buyer = payable(msg.sender);

    // the buyer can pay the seller
    article.seller.transfer(msg.value);

    // trigger the event
    emit LogBuyArticle(_id, article.seller, article.buyer, article.name, article.price);
  }
}

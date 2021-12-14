// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "base64-sol/base64.sol";

interface ItonyNft {
  function mint(address _to) external;
}

contract TonyRiosNFT is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(address => bool) private _claimed;

    constructor() ERC721('Antonio', 'ATR') {}

    function safeMint(address to) public onlyOwner {
      if(_claimed[to]) {
        return;
      }
      _claimed[to] = true;
      uint256 tokenId = _tokenIdCounter.current();
      _tokenIdCounter.increment();
      _safeMint(to, tokenId);
              
    }

    // The following functions are overrides required by Solidity.

    /*function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    */

        function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
      require(_exists(tokenId), "ERC721: URI query for nonexistent token");

      return string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"Tony Rios de la abundancia",'
                '"description":"Para que nunca te falte y nunca te enganien",',
                '"image":"ipfs://QmbRFzsy5zQkvetx1b7xzUdn7si7pdHcUnGQgGrvCiL7u1"}'
              )
            )
          )
        )
      );
    }


}



// contract MandalaTokenNftAbundancia is ERC721, ERC721URIStorage, ERC721Enumerable, Ownable {
contract MandalaTokenNftAbundancia is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 PRICE = 0.025 ether;
    address public dev;
    TonyRiosNFT public _tonyNFT;

    mapping (uint256 => uint256[2]) public _referrer;
    mapping (uint256 => uint256) public _parent;
    // indica si un tokenId tiene todos los referidos
    mapping (uint256 => bool) private _filled;
    mapping (uint256 => string) private _detail;

    string[] private _names = ['Fuego', 'Aire', 'Tierra', 'Agua'];
    string[] private _descs = [
      'Con poder de decision y fuerza de voluntad que decide iniciar el camino de la realizacion de tus deseos. Valiente dispuesto a cumplir tus deseos, rompiendo paradigmas, dejando ir miedos y confiando en cada uno de los participantes del telar.',
      'Trasmite su energia y la comparte. Se encarga de comunicar, trasmitir y sentir pasion por el movimiento.',
      'Da estabilidad, motivacion y union. Cimiento del telar a traves de la comunicacion y busqueda de soluciones.',
      'Ve transformados sus deseos en hermosa realidad y se convierte en guia del grupo. Deja fluir y recibe la abundancia multiplicada. Esta posicion es el sosten energetico del circulo.'
    ];

    string[] private _images = [
      // fuego
      'QmWsmyDjbBv2RwmXJuXTEt34ZfxFh3UymGKd6kZibNKigu',
      // aire
      'QmRmcABuGftuygTw9qLbNEMBm41htDmV5A6ATBjRSNzgdt',
      // tierra
      'QmeRNyh7QXYNiJavXishMZDuVXrReGBHrX61A2J1Aaugbg',
      // agua 
      'QmPabcDsZ2B5XiUR12WGj5Hig1D5AYod2qzMYHh1f5Rez2'
    ];

    // Mandala el token de la Abundancia
    constructor(address dev_) ERC721("Mandala", "MDL") {
      _tonyNFT = new TonyRiosNFT();
      dev = dev_;
      _tokenIdCounter.increment();
      _safeMint(msg.sender, _tokenIdCounter.current());
      _tokenIdCounter.increment();

    }

    // status
    // 0 FUEGO
    // 1 AIRE
    // 2 TIERRA
    // 3 AGUA
    function status(uint256 tokenId) public view returns (uint8) {
      require(_exists(tokenId), "La mandala no existe");
      if(_filled[tokenId] == false) {
        return 0;
      }

      uint256 child0 = _referrer[tokenId][0];
      uint256 child1 = _referrer[tokenId][1];

      if(_filled[child0] == false || _filled[child1] == false) {
        return 1;
      }

      uint256 child00 = _referrer[child0][0];
      uint256 child01 = _referrer[child0][1];
      uint256 child10 = _referrer[child1][0];
      uint256 child11 = _referrer[child1][1];
      
      
      if(_filled[child0] && _filled[child1] && (_filled[child00] == false || _filled[child01] == false || _filled[child10] == false || _filled[child11] == false)){
        return 2;
      }
      
      return 3;
    }

    function updateDetail(uint256 tokenId, string memory detail) public {
      require(ownerOf(tokenId) == msg.sender);
      require(bytes(_detail[tokenId]).length == 0, "Messages are writen on stone");
      _detail[tokenId] = detail;
      // TBD: emit event
      // emit DetailChanged(tokenId, detail);
    }

    function mint(uint256 tokenIdReferrer, string memory detail) public payable {
      require(msg.value >= PRICE, "El valor debe ser exacto, 0.025 ETH");
      require(_exists(tokenIdReferrer), "La mandala no existe");
      // solo FUEGO puede invitar personas
      require(_filled[tokenIdReferrer] == false, "Esta rama esta completa");

      // tokenId of the new token
      uint256 tokenId = _tokenIdCounter.current();
      _tokenIdCounter.increment();
      
      if (_referrer[tokenIdReferrer][0] == 0) {
        _referrer[tokenIdReferrer][0] = tokenId;
      } else {
        _filled[tokenIdReferrer] = true;
        _referrer[tokenIdReferrer][1] = tokenId;
      }

      _parent[tokenId] = tokenIdReferrer;
      _safeMint(msg.sender, tokenId);

      _detail[tokenId] = detail;


      uint256 _amountFee = ((PRICE * 10) / 1000);
      uint256 _amountAgua = ((PRICE * 490) / 1000);
      uint256 _amountTierra = ((PRICE * 300) / 1000);
      uint256 _amountAire = PRICE - _amountFee - _amountTierra - _amountAgua;

      uint256 _aguaTokenId = getParent(tokenId, 3);
      
      if (status(_aguaTokenId) == 3) {
        _tonyNFT.safeMint(ownerOf(_aguaTokenId));
      }

      payable(dev).transfer(_amountFee);
      payable(ownerOf(getParent(tokenId, 1))).transfer(_amountAire);
      payable(ownerOf(getParent(tokenId, 2))).transfer(_amountTierra);
      payable(ownerOf(_aguaTokenId)).transfer(_amountAgua);
      payable(msg.sender).transfer(msg.value - PRICE);
      
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    /*
        function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    */

    function getParent(uint256 tokenId, uint256 deepLevel) public view returns (uint256) {
      require(deepLevel < 4, "Deep level must be less than 4");
      
      uint256 parent_ = _parent[tokenId];
      // console.log("deeplevel", deepLevel);
      // console.log("parent of", tokenId, "=>", parent_);
      if (parent_ == 0) {
        return tokenId;
      }
      if (deepLevel == 1) {
        return parent_;
      }

      return getParent(parent_, deepLevel - 1);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    
        // override(ERC721, ERC721URIStorage)
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
      require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

      uint8 _status = status(tokenId);
      return string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',_names[_status],','
                '"description":"',_descs[_status],'",',
                '"image":"ipfs://',_images[_status],'"}'
                        /*
                        '{"name":"',_names[tokenId],'",', // You can add whatever name here
                        '"attributes":"", "image":"',baseHTML,'?token=',Strings.toString(tokenId),'"}'
                        */
              )
            )
          )
        )
      );
    }
}
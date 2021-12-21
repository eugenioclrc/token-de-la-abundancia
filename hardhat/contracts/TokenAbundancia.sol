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

    uint256 immutable PRICE;
    uint256 immutable networkid;
    address public dev;
    TonyRiosNFT public tonyNFT;

    string private _url = '';

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

    event LadderUp(address owner, uint256 tokenId);
    event Join(uint256 tokenIdRef, uint256 tokenId);

    // Mandala el token de la Abundancia
    constructor(address dev_, string memory url_, uint256 price_, uint256 networkid_) ERC721("Mandalas", "MDL") {
      tonyNFT = new TonyRiosNFT();
      dev = dev_;
      _url = url_;
      PRICE = price_;      
      networkid = networkid_;
      _tokenIdCounter.increment();
      _safeMint(msg.sender, _tokenIdCounter.current());
      _detail[_tokenIdCounter.current()] = "Genesis mandala, a ver si esto me saca de los numeros rojos-";
      _tokenIdCounter.increment();
    }

    // status
    // 0 FUEGO
    // 1 AIRE
    // 2 TIERRA
    // 3 AGUA
    function status(uint256 tokenId) public view returns (uint8) {
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

    function mint(uint256 tokenIdReferrer, string memory detail) external payable {
      // para evitar un DoS with (Unexpected) revert
      // https://consensys.github.io/smart-contract-best-practices/known_attacks/#dos-with-unexpected-revert
      // require(tx.origin == msg.sender, "Only EOA are allowed");
      // en vez del require, uso el try catch, si falla la trasnferencia por ser un contrato malicioso, no se rompe nada
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
        emit LadderUp(ownerOf(tokenIdReferrer), tokenIdReferrer);
        _filled[tokenIdReferrer] = true;
        _referrer[tokenIdReferrer][1] = tokenId;
      }
      emit Join(tokenIdReferrer, tokenId);

      _parent[tokenId] = tokenIdReferrer;
      _safeMint(msg.sender, tokenId);

      _detail[tokenId] = detail;


      uint256 _amountFee = ((PRICE * 10) / 1000);
      uint256 _amountAgua = ((PRICE * 490) / 1000);
      uint256 _amountTierra = ((PRICE * 300) / 1000);
      uint256 _amountAire = ((PRICE * 150) / 1000);
      uint256 _amountFuego = PRICE - _amountFee - _amountTierra - _amountAgua - _amountAire;

      uint256 _aguaTokenId = getParent(tokenId, 3);
      
      if (status(_aguaTokenId) == 3) {
        tonyNFT.safeMint(ownerOf(_aguaTokenId));
      }

      // https://ethereum.stackexchange.com/questions/78562/is-it-possible-to-perform-a-try-catch-in-solidity
      // https://ethereum.stackexchange.com/questions/19341/address-send-vs-address-transfer-best-practice-usage
      bool success;
      dev.call{value:_amountFee}("");

      (success, ) = ownerOf(tokenIdReferrer).call{value:_amountFuego}("");
      if(success == false) {
        uint256 _aux = _amountFuego / 3;
        _amountAire += _aux;
        _amountTierra += _aux;
        _amountAgua += _aux;
      }
      (success, ) = ownerOf(getParent(tokenId, 1)).call{value:_amountAire}("");
      if(success == false) {
        uint256 _aux = _amountAire / 2;
        _amountTierra += _aux;
        _amountAgua += _aux;
      }
      (success, ) = ownerOf(getParent(tokenId, 2)).call{value:_amountTierra}("");
      if(success == false) {
        _amountAgua += _amountTierra;
      }
      (success, ) = ownerOf(_aguaTokenId).call{value:_amountAgua}("");
      if(success == false) {
        dev.call{value:_amountAgua}("");      
      }
      uint256 _changeReturn = msg.value - PRICE;
      if (_changeReturn > 0) {
        (success, ) = msg.sender.call{value:_changeReturn}("");
      }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function getParent(uint256 tokenId, uint256 deepLevel) public view returns (uint256) {
      require(deepLevel < 4, "Deep level must be less than 4");
      
      uint256 parent_ = _parent[tokenId];
      // console.log("deeplevel", deepLevel);
      // console.log("parent of", tokenId, "=>", parent_);
      if (parent_ == 0 || deepLevel == 0) {
        return tokenId;
      }
      if (deepLevel == 1) {
        return parent_;
      }

      return getParent(parent_, deepLevel - 1);
    }

    function tokenIdCounter() public view returns (uint256) {
      return _tokenIdCounter.current();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenData(uint256 tokenId)
        public
        view
        returns (uint256 id, uint8 status_, address owner, string memory detail)
    {
      if(_exists(tokenId)) {
        uint8 _status = status(tokenId);
        return (tokenId, _status, ownerOf(tokenId), _detail[tokenId]);
      } else {
        return (0, 0, address(0), "");
      }
    }


    function getTokenNetwork(uint256 id) public view returns ( uint256[] memory) {
      /*
      uint256 parent_ = ;
      
      
      // level 2
      uint256 child00_ = _referrer[child0_][0];
      uint256 child01_ = _referrer[child0_][1];
      uint256 child10_ = _referrer[child1_][0];
      uint256 child11_ = _referrer[child1_][1];

      // level 3
      uint256 child000_ = _referrer[child0_][0];
      uint256 child001_ = _referrer[child0_][1];
      uint256 child010_ = _referrer[child1_][0];
      uint256 child011_ = _referrer[child1_][1];

      uint256 child100_ = _referrer[child0_][0];
      uint256 child101_ = _referrer[child0_][1];
      uint256 child110_ = _referrer[child1_][0];
      uint256 child111_ = _referrer[child1_][1];
      */
      uint256[] memory tokenNetwork_ = new uint256[](16);
      tokenNetwork_[0] = _parent[id];
      tokenNetwork_[1] = id;
      // level 1
      tokenNetwork_[2] = _referrer[id][0];
      tokenNetwork_[3] = _referrer[id][1];
      // level 2
      tokenNetwork_[4] = _referrer[_referrer[id][0]][0];
      tokenNetwork_[5] = _referrer[_referrer[id][0]][1];
      tokenNetwork_[6] = _referrer[_referrer[id][1]][0];
      tokenNetwork_[7] = _referrer[_referrer[id][1]][1];
      // level 3
      tokenNetwork_[8] = _referrer[_referrer[_referrer[id][0]][0]][0];
      tokenNetwork_[9] = _referrer[_referrer[_referrer[id][0]][0]][1];
      tokenNetwork_[10] = _referrer[_referrer[_referrer[id][0]][1]][0];
      tokenNetwork_[11] = _referrer[_referrer[_referrer[id][0]][1]][1];
      tokenNetwork_[12] = _referrer[_referrer[_referrer[id][1]][0]][0];
      tokenNetwork_[13] = _referrer[_referrer[_referrer[id][1]][0]][1];
      tokenNetwork_[14] = _referrer[_referrer[_referrer[id][1]][1]][0];
      tokenNetwork_[15] = _referrer[_referrer[_referrer[id][1]][1]][1];

      return tokenNetwork_;
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
                '"external_url":"',_url,Strings.toString(tokenId),'-',Strings.toString(networkid),'",', 
                '"attributes":[{"trait_type":"State","value":"',_names[_status],'"}],',
                '"image":"ipfs://',_images[_status],'"}'
              )
            )
          )
        )
      );
    }
}

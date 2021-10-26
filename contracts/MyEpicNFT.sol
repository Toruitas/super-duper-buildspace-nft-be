// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// import the helped functions from teh contract we copypastad
import { Base64 } from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
// https://solidity-by-example.org/inheritance/
contract MyEpicNFT is ERC721URIStorage {
    // https://eips.ethereum.org/EIPS/eip-721
    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    // string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    // we split the SVG at the part where it asks for a background color
    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever! 
    string[] firstWords = ["Clear", "Stringy", "Juicy", "Bendy", "Fancy", "Sticky","Tangy","Sweaty","Freezing","Solid","Tan","Curly","Frying","Ubiquitous", "Mendacious","Furtive","Heavy"];
    string[] secondWords = ["Deleted", "Anime", "Mamasan", "Corpo-Rat", "Burrito", "Leggings", "Leaf", "Ninja", "Paranoia","Lady","Robot","Bat","Paper","Lord","Captain","Milkshake","Hut","Box"];
    string[] thirdWords = ["Butler", "Ether", "Solo", "Cup", "Bullet", "Shield","Coaster","Choochoo","Biplane","Tree","Cyclist","Goth","Star","Dog","Kitty","Doll","Sky","Code","Bank","Bubble"];

    string[] colors = ["red","yellow","black","white","blue","green","orange"];
    event NewEpicNFTMinted(address sender, uint256 tokenId);


    // We need to pass the name of our NFTs token and it's symbol.
    constructor() ERC721 ("SquareNFT","SQUARE") {
        console.log("This is my first NFT contract, oh yeah!");
    }

    function random(string memory input) internal pure returns (uint256){
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory){
        // seed the random generator
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId) )));
        // squash the # between 0 and the len of array to avoid going out of bounds
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory){
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory){
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function pickRandomColor(uint256 tokenId) public view returns (string memory){
        uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
        rand = rand % colors.length;
        return colors[rand];
    }


    // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public {
        // Get the current tokenId, this starts at 0
        uint256 newItemId = _tokenIds.current();  // _tokenIds tracks unique identifiers. It's a state variable, which is stored on contract directly.

        // randomly grab a word from each of the three arrays
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));
        string memory randomColor = pickRandomColor(newItemId);

        // concat together image b64, close the <text> and <svg> tags
        string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));
        console.log("\n-----------------");
        console.log(finalSvg);
        console.log("\n-----------------");

        // get all the JSON metadata in place and base64 encode it
        // Shouldn't there be some kind of... dict to json kind of thing available?
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',
                        // set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A square with words.", "image":"data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Prepend data:application/json;base64 to our data. This time for the json
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,",json)
        );
        console.log("\n-----------------");
        console.log(finalTokenUri);
        console.log("\n-----------------");


        // Actually mint the NFT to the sender using msg.sender
        _safeMint(msg.sender, newItemId);
        // mint the NFT w/ ID from above, for user w/ address msg.sender
        // msg.sender is super secure way to get public addy. Can't fake someone else's unless you have their credentials and call the contract on their behalf
        // https://docs.soliditylang.org/en/develop/units-and-global-variables.html#block-and-transaction-properties
        // contracts cannot be called anonymously


        // Set the NFTs data
        // _setTokenURI(newItemId, "https://jsonkeeper.com/b/1OET");
        // _setTokenURI(newItemId, "data:application/json;base64,eyJuYW1lIjoiTElHSFRTUEVFRCBGQUNFIiwiZGVzY3JpcHRpb24iOiJXSE9BQUEiLCJpbWFnZSI6ImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jaUlIQnlaWE5sY25abFFYTndaV04wVW1GMGFXODlJbmhOYVc1WlRXbHVJRzFsWlhRaUlIWnBaWGRDYjNnOUlqQWdNQ0F6TlRBZ016VXdJajRLSUNBZ0lEeHpkSGxzWlQ0dVltRnpaU0I3SUdacGJHdzZJSGRvYVhSbE95Qm1iMjUwTFdaaGJXbHNlVG9nYzJWeWFXWTdJR1p2Ym5RdGMybDZaVG9nTVRSd2VEc2dmVHd2YzNSNWJHVStDaUFnSUNBOGNtVmpkQ0IzYVdSMGFEMGlNVEF3SlNJZ2FHVnBaMmgwUFNJeE1EQWxJaUJtYVd4c1BTSmliR0ZqYXlJZ0x6NEtJQ0FnSUR4MFpYaDBJSGc5SWpVd0pTSWdlVDBpTlRBbElpQmpiR0Z6Y3owaVltRnpaU0lnWkc5dGFXNWhiblF0WW1GelpXeHBibVU5SW0xcFpHUnNaU0lnZEdWNGRDMWhibU5vYjNJOUltMXBaR1JzWlNJK1YyOXZaRTkzYkVaeVpXNWphR1p5ZVR3dmRHVjRkRDRLUEM5emRtYysifQo=");
        // We'll explore TokenURI later. This is not standard what we did!
        // Usually holds metadata like:
        // {
        //     "name": "Spongebob Cowboy Pants",
        //     "description": "A silent hero. A watchful protector.",
        //     "image": "https://i.imgur.com/v7U019j.png"
        // }
        // go here and type in the metadata https://jsonkeeper.com/

        // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);

        // Increment the counter for when the next NFT is minted
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }


}
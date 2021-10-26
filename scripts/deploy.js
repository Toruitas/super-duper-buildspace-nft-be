

const main = async() => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT'); // compiles contract and generates the files in /artifacts
    const nftContract = await nftContractFactory.deploy(); // creates local ETH network just for this contract.
    await nftContract.deployed();  // wait for it to be fake mined and then deployed to blockchian
    console.log("Contract deployed to:", nftContract.address);  // logs contract address


    // can call the contract here and create if we want to! But these will send events to ALL event listeners so everyone gets notified
    // Maybe a good place to update data between deployments?
    // // Call the fn
    // let txn  = await nftContract.makeAnEpicNFT();
    // // wait for it to be mined
    // await txn.wait();
    // console.log("Minted NFT #1")

    // // Mint another for fun
    // txn  = await nftContract.makeAnEpicNFT();
    // // wait for it to be mined
    // await txn.wait();
    // console.log("Minted NFT #2")
};

const runMain = async () => {
    try{
        await main();
        process.exit(0);
    } catch(error){
        console.log(error);
        process.exit(1);
    }
};

runMain();
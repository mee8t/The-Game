 solc = require("solc");

 fs = require("fs");

 Web3= require("web3");

 let web3 = new Web3(new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545"));

 let smart_contract=fs.readFileSync("game.sol").toString();

 console.log(smart_contract);

var input = {
  language: 'Solidity',
  sources: {
    'game.sol':{
      content: smart_contract,  
    },
  },
  settings: {
    outputSelection:{
        "*":{
            "*":["*"],
        },
    },
  },
};
var output = JSON.parse(solc.compile(JSON.stringify(input)));
console.log(output);

ABI = output.contracts["game.sol"]["StonePaperScissors"].abi;
bytecode =output.contracts["game.sol"]["StonePaperScissors"].evm.bytecode.object;
console.log("The abi of smart contract is :",ABI);
console.log("the bytecode of smart is :",bytecode);

contract = new web3.eth.Contract(ABI);

web3.eth.getAccounts().then((accounts)=> {
    console.log("the ganache accounts are : ",accounts)
    defaultAccount = accounts[0];
    console.log("my default account ",defaultAccount)

 contract
.deploy({data: bytecode})
.send({from: defaultAccount,gas:200000 })
.then((instance) => {
    console.log(`Address: ${instance.options.address}`);
  });
});


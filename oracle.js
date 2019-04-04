const axios = require("axios");
var Web3 = require("web3");
const Tx = require("ethereumjs-tx");
const fs = require("fs");
var CONTRACT_ADDRESS = "0x075EeE674dBd8A1F2169d66fc46e1bE1981b313D";
var jsonData = fs.readFileSync("abi.json");
var ContractABI = JSON.parse(jsonData).ABI;
var gasPrice = "20"; //in gwei
var useGasLimit = "500000"; //in gwei

// the palyers and winners should match with participants and contract
const requiredNums = 2;
const minNum = 0;
const maxNum = 5;

var account = "address";
var accountPrivKey = "PrivateKey";

const privateKey = Buffer.from(
  accountPrivKey,
  "hex"
);

const web3 = new Web3(
  new Web3.providers.HttpProvider(
    "https://ropsten.infura.io/v3/0f620274bd2344209bf8b00b6e81bd97"
  )
);

// /var radomOrgUlr = `https://www.random.org/integers/?num={requiredNums}&min={minNum}&max={maxNum}&col=1&base=10&format=plain&rnd=new`
var randomOrgURl = `https://www.random.org/integer-sets/?sets=1&num=${requiredNums}&min=${minNum}&max=${maxNum}&seqnos=off&commas=on&sort=off&order=index&format=plain&rnd=new`;

var contract = new web3.eth.Contract(ContractABI, CONTRACT_ADDRESS, {
  from: account, // default from address
  gasPrice: web3.utils.toHex(web3.utils.toWei(gasPrice, "gwei")) //"20000000000" // default gas price in wei, 20 gwei in this case
});

let estimatedGas;
let nonce;

axios
  .get(randomOrgURl)
  .then(response => {
    
    const selectedNumsStr = response.data.replace(/\s/g,'').trim();
    console.log(selectedNumsStr)
    
    //validate nums
    const selectedNums = selectedNumsStr.split(",");
    const distinctNums = [...new Set(selectedNums)];
    if (distinctNums.length !== requiredNums) {
      console.log(`Not all numbers are distinct: ${selectedNumsStr}`);
      return;
    }

    const inputNums = `[${selectedNumsStr}]`;

    console.log(inputNums);

    const contractFunction = contract.methods.setWinners(distinctNums);
    const functionAbi = contractFunction.encodeABI();
    contractFunction.estimateGas({ from: account }).then(gasAmount => {
      estimatedGas = gasAmount.toString(16);

      console.log("Estimated gas: " + estimatedGas);

      web3.eth.getTransactionCount(account).then(_nonce => {
        nonce = _nonce.toString(16);

        console.log("Nonce: " + nonce);
        const txParams = {
          gasPrice: web3.utils.toHex(web3.utils.toWei(gasPrice, "gwei")),
          gasLimit: web3.utils.toHex(useGasLimit), //estimatedGas,//0x4712388,
          to: CONTRACT_ADDRESS,
          data: functionAbi,
          from: account,
          nonce: "0x" + nonce
        };

        const tx = new Tx(txParams);
        tx.sign(privateKey);

        const serializedTx = tx.serialize();

        web3.eth
          .sendSignedTransaction("0x" + serializedTx.toString("hex"))
          .on("transactionHash", hash => {
            console.log("transactionHash: ", hash);
          })
          .on("confirmation", (confirmationNumber, receipt) => {
            console.log("confirmation: ", confirmationNumber);
          })
          .on("receipt", receipt => {
            // receipt example
            console.log("receipt: ", receipt);
          })
          .on("error", console.error);
      });
    });
  })
  .catch(error => {
    console.log(error);
  });

// using the callback
/*contract.methods
  .getParticipants()
  .call({ from: account }, (error, result) => {
    console.log(result);
  });
*/

// Moralis.initialize("APPLICATION_ID"); // Application id from moralis.io
// Moralis.serverURL = "SERVER_URL"; //Server url from moralis.io
const serverUrl = "https://wynvhxyi5eaa.usemoralis.com:2053/server"; //Server url from moralis.io
const appId = "7EwiEKyfa1MAp3xOXs78SArnOeOyTiPgovlWnsKW"; // Application id from moralis.io
Moralis.start({ serverUrl, appId });

// GYV Chain Contract addresses
const GYV_CONTRACT_ADDRESS = "0xE9b2CDe742a71e489089878ca5161449966E3029";
const GYV_TOKEN_ADDRESS = "0x23799Cb60ca997080d0aD421bfA348b9641C6568";

function getAddressTxt(address) {
    return `${address.substr(0, 4)}...${address.substr(address.length - 4, address.length)}`;
  }

function buildAddrListComponent(user) {
    // add each address to the list
    let addressItems = "";
    if (user.attributes.accounts && user.attributes.accounts.length) {
      addressItems = user.attributes.accounts
        .map(function (account) {
          return `<li>
            <button class="btn-addr btn-remove" type="button" data-addr="${account}">X</button>
            ${getAddressTxt(account)}
          </li>`;
        })
        .join("");
    } else {
      // no linked addreses, add button to link new address
      addressItems = `
      <li>
        <button class="btn-addr" type="button" id="btn-add-addr">+</button>
        Link
      </li>
      `;
    }
  
    return `
      <div>
        <h3>Linked Addresses</h3>
        <ul>
          ${addressItems}
        </ul>
      </div>
    `;
  }

//async function login(type) {
async function login_donor() {
    console.log("login_donor button clicked");

    try {
        //let user = await Moralis.User.current();
        user = await Moralis.authenticate();
        // var user = await Moralis.Web3.authenticate();
        if (user) {
            console.log("in login(); user id: " + user.id)
            renderApp("donor");
        }
    } catch (error) {
        console.log(error);
    }
}

async function donate() {
    let amount = document.getElementById("gyv_amount").value;
    // clear the value
    document.getElementById("gyv_amount").value = null;
    // proceed if > 0
    if (amount <= 0) {
        alert("Please enter a valid donation amount!")
    } else {
        alert("user " +  user.id + " is donating " + amount)
        let weiConv = Math.pow(10, 12);

        // for testing, use _index = 0
        gyvCharityIndex = 0;

        console.log("amount in GYV: " + amount)

        // convert to wei equiv.
        amountConv = weiConv * amount;

        console.log("converted amount: " + amount)

        //let senderAddress = user.attributes.ethAddress;
        //let senderAddress = user.attributes.authData.moralisEth.id;
        let senderAddress = ethereum.selectedAddress;
        console.log("address: " + senderAddress);

        // instantiate the token contract
        let tokenAbi = window.tokenAbi;
        let tokenContract = new web3.eth.Contract(tokenAbi, GYV_TOKEN_ADDRESS);

        // instantiate the primary gyv contract
        let gyvContractAbi = window.contractAbi;
        let gyvContract = new web3.eth.Contract(gyvContractAbi, GYV_CONTRACT_ADDRESS);

        // logging ...
        console.log("token abi: ", tokenAbi)
        console.log("token contract: ", tokenContract)

        // get the user's balance of GYV
        let userTokenBalance = await tokenContract.methods.balanceOf(senderAddress)
            .call(function (err, res) {
                if (err) {
                    console.log("An error occured while retrieving balance", err)
                    return
                }
                console.log("Balance of GYV is: ", res)
            });

        // if there is a positive balance, ensure the donation is less than total funds
        if (userTokenBalance > amountConv) {
            console.log("balance is good: ", userTokenBalance)

            // logging ...
            console.log("gyvContract abi: ", gyvContractAbi)
            console.log("gyvContract: ", gyvContract)

            /*// total supply is only $GYV 1500?
            tokenContract.methods
                .totalSupply()
                .call(function (err, res){
                    if (err) {
                        console.log("An error occurred while getting totalSupply", err)
                        return
                    }
                    console.log("total supply: " + res)
                });*/

            // process the donation
            /*tokenContract.methods
                .donate(gyvCharityIndex, amountConv)
                .send({from: senderAddress}, function (err, res){
                    if (err) {
                        console.log("An error occured while executing the donation", err)
                        return
                    }
                    console.log("Hash of the transaction: " + res)
                });
                */
            tokenContract.methods
                .donate(gyvCharityIndex, amountConv)
                .send({from: senderAddress});


            /*(async function () {
                let starting_balance = await daiToken.methods.balanceOf(receiverAddress).call();
                daiToken.methods.transfer(receiverAddress, "100000000000000000000").send({from: senderAddress}, async function(error, transactonHash) {
                    console.log("Submitted transaction with hash: ", transactonHash)
                    let transactionReceipt = null
                    while (transactionReceipt == null) { // Waiting expectedBlockTime until the transaction is mined
                        transactionReceipt = await web3.eth.getTransactionReceipt(transactonHash);
                        await sleep(expectedBlockTime)
                    }
                    console.log("Got the transaction receipt: ", transactionReceipt)
                    let final_balance = await daiToken.methods.balanceOf(receiverAddress).call();
                    console.log('Starting balance was:', starting_balance);
                    console.log('Ending balance is:', final_balance);
                });
            })();*/
        
        } else {
            alert("Your balance of GYV, is insufficient to donate!")
        }

    }

}

async function renderApp(type) {
    // if successfully logged in, hide "connect" and display "donate"
    document.getElementById("donor_metamask_button").style.display = "none";
    // clear the value
    document.getElementById("connected-gyving").style.display = "block";
    //document.getElementById("simply-connect").style.display = "none";

    console.log("in renderApp(), type: ", type)
    // maybe try this later ...
    //buildAddrListComponent(user)

    // update the user's wallet type
    if(type = "donor") {
        user.set("wallet-type","donor");
        user.save();
    } else {
        user.set("wallet-type","charity");
        user.save();
    }

    window.web3 = await Moralis.enableWeb3();
    //window.contract = new web3.eth.Contract(contractAbi, CONTRACT_ADDRESS);

    // before latest
    //window.web3 = Moralis.enableWeb3();
    //window.web3 = await Moralis.Web3.enable();

    // token Contract
    //tokenAbi = await (await fetch("./MartianMarket.json")).json();
    /*
    let tokenAbi = window.abiOne;
    let tokenContract = new web3.eth.Contract(tokenAbi, GYV_TOKEN_ADDRESS);
    console.log("token abi: ", tokenAbi)
    console.log("token contract: ", tokenContract)
    */

    // gyv Contract
    /*
    let gyvContractAbi = window.abiTwo;
    let gyvContract = new web3.eth.Contract(gyvContractAbi, GYV_CONTRACT_ADDRESS);
    */

    //updateStats();
  }

async function updateStats() {
    let promises = [
      Moralis.Cloud.run("biggestWinners", {}),
      Moralis.Cloud.run("biggestLosers", {}),
      Moralis.Cloud.run("biggestBets", {}),
    ];
    let results = await Promise.all(promises);
  
    processBiggestWinners(results[0]);
    processBiggestLosers(results[1]);
    processBiggestBets(results[2]);
  }

function init() {
    user = Moralis.User.current();
    //const user = await Moralis.User.current();

    if (user) {
        //from before ...let email = await user.get("email");
        //my comment ... document.getElementById("donor_metamask_button").style.display = "none";
        console.log("in init(); already logged in; user id: " + user.id)
        renderApp("init");
    } else {
        console.log("in init(); no user; show connect button")
        document.getElementById("donor_metamask_button").style.display = "block";
        //document.getElementById("app").style.display = "none";
        //document.getElementById("register").style.display = "block";
    }
  }


document.getElementById("donor_metamask_button").onclick = login_donor;
//document.getElementById("charity_metamask_button").onclick = login_charity;
document.getElementById("gyv_button").onclick = donate;

//init();
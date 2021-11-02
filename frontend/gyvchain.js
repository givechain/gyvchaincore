// Moralis.initialize("MORALIS_APPLICATION_ID"); // Application id from moralis.io
// Moralis.serverURL = "MORALIS_SERVER_URL"; //Server url from moralis.io
const serverUrl = "https://w9wwtgzzzig8.usemoralis.com:2053/server"; //Server url from moralis.io
const appId = "9cgNLT5Cd6t7Npfcrx82AMs66cWFJyrJJvfo4KZO"; // Application id from moralis.io
Moralis.start({ serverUrl, appId });

// GYV Chain Contract addresses
const GYV_CONTRACT_ADDRESS = "0x96F407d2DfD6B185d120e6d89171c9146721DF00";

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
    //let campaign = document.getElementById("campaign-selector").element.options[element.selectedIndex].value
    let gyvCharityIndex = document.getElementById("campaign-selector").value
    let amount = document.getElementById("gyv_amount").value;
    // clear the value
    document.getElementById("gyv_amount").value = null;
    // proceed if > 0
    if (amount <= 0) {
        alert("Please enter a valid donation amount!")
    } else {
        console.log("user " +  user.id + " is donating " + amount)
        let weiConv = Math.pow(10, 18);

        // for testing, use _index = 0
        //gyvCharityIndex = 0;

        console.log("amount in GYV: " + amount)

        // convert to wei equiv.
        amountConv = weiConv * amount;

        //console.log("converted amount: " + amountConv)
        console.log("converted amount: " + Moralis.Units.Token(amount, "18"))

        //let senderAddress = user.attributes.ethAddress;
        //let senderAddress = user.attributes.authData.moralisEth.id;
        let senderAddress = ethereum.selectedAddress;
        console.log("address: " + senderAddress);

        // instantiate the token contract
        let contractAbi = window.contractAbi;
        let gyvContract = new web3.eth.Contract(contractAbi, GYV_CONTRACT_ADDRESS);

        // logging ...
        console.log("gyv abi: ", contractAbi)
        console.log("gyv contract: ", gyvContract)

        // get the user's balance of GYV
        let userTokenBalance = await gyvContract.methods.balanceOf(senderAddress)
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

            /*// total supply is only $GYV 1500?
            gyvContract.methods
                .totalSupply()
                .call(function (err, res){
                    if (err) {
                        console.log("An error occurred while getting totalSupply", err)
                        return
                    }
                    console.log("total supply: " + res)
                });*/

            // process the donation
            /*gyvContract.methods
                //.donate(gyvCharityIndex, amountConv)
                //.donate(gyvCharityIndex, web3.eth.toWei(amount, 'ether'))
                .donate(gyvCharityIndex, Moralis.Units.Token(amount, "18"))
                .send({from: senderAddress}, function (error, transactonHash){
                    if (error) {
                        console.log("An error occured while executing the donation", error)
                        return
                    }
                    console.log("Hash of the transaction: " + transactonHash)
                });
                */
            /// *

            // set up some variables for the asyncronous call to the donation
            const expectedBlockTime = 1000;
            const sleep = (milliseconds) => {
                return new Promise(resolve => setTimeout(resolve, milliseconds))
            }
            // donate
            (async function () {
                gyvContract.methods
                  .donate(gyvCharityIndex, Moralis.Units.Token(amount, "18"))
                  .send({from: senderAddress}, async function (error, transactonHash) {
                    if (error) {
                      console.log("An error occured while executing the donation", error)
                      return
                    }

                  console.log("Submitted transaction with hash: ", transactonHash);
                  let transactionReceipt = null;
                  while (transactionReceipt == null) { // Waiting expectedBlockTime until the transaction is mined
                    transactionReceipt = await web3.eth.getTransactionReceipt(transactonHash);
                    await sleep(expectedBlockTime)
                  }
                  console.log("Got the transaction receipt: ", transactionReceipt);
                  document.getElementById("gyving-thankyou").style.display = "block";
                  alert("Thank you for your donation. Your receipt is: " + transactonHash)
                });
            })();

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
    document.getElementById("gyving-thankyou").style.display = "none";

    //"https://kovan.etherscan.io/tx/" + txn

    console.log("in renderApp(), type: ", type)

    // update the user's wallet type
    if(type = "donor") {
        user.set("wallet-type","donor");
        user.save();
    } else {
        user.set("wallet-type","charity");
        user.save();
    }

    // enable Moralis Web3
    window.web3 = await Moralis.enableWeb3();

    updateStats();
  }

async function updateStats() {
    let promises = [
      Moralis.Cloud.run("testDonations", {})//,
      //Moralis.Cloud.run("biggestLosers", {}),
      //Moralis.Cloud.run("biggestBets", {}),
    ];
    let results = await Promise.all(promises);
  
    console.log("testDonations query")
    console.log(results)
    processDonations(results[0]);
    //processCampaigns(results[1]);
    //processTransactions(results[2]);
  }

function addRowToTable(tableId, data) {
    let tableRow = document.createElement("tr");
    data.forEach((element) => {
      let newRow = document.createElement("td");
      newRow.innerHTML = element;
      tableRow.appendChild(newRow);
    });
    document.getElementById(tableId).appendChild(tableRow);
  }
  
function processDonations(data) {
    data.forEach((row) => {
      //addRowToTable("top_donations", [row.campaignId, row.pendingAmount]);
    });
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
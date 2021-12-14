const { expect } = require("chai");

let deployer, alice, evilUser;
let token;

describe("Evil test", function() {
  before(async () => {
    [deployer, alice, bob, evilUser, dev] = await ethers.getSigners();
  })

  it("Should mint genesis NFT", async function() {
    const MandalaTokenNftAbundancia = await ethers.getContractFactory("MandalaTokenNftAbundancia");
    token = await MandalaTokenNftAbundancia.deploy(dev.address);
    await token.deployed();

    expect(await token.balanceOf(deployer.address)).to.eq(1);
    expect(await token.ownerOf(1)).to.eq(deployer.address);
  });

  it("Should try to DoS la mandala", async function() {
    const Exploit = await ethers.getContractFactory("ExploitDoS");
    const exploit = await Exploit.deploy();
    await exploit.deployed();

    let provider = deployer.provider;
    let balance = await provider.getBalance(token.address);
    let balanceInEth = ethers.utils.formatEther(balance)
    
    await exploit.hack(token.address, "1", { value: ethers.utils.parseEther("0.025")});
    await exploit.hack2(token.address, "1", { value: ethers.utils.parseEther("0.025")});

    expect(await token.ownerOf("2")).to.eq(exploit.address);
    expect(await token.ownerOf("3")).to.eq(exploit.address);
    
    await token.connect(alice).mint("2", '', { value: ethers.utils.parseEther("0.5")})
    await token.connect(alice).mint("3", '', { value: ethers.utils.parseEther("0.5")})
    
    let aliceBalance = await provider.getBalance(alice.address);

    expect(await token.ownerOf("4")).to.eq(alice.address);
    expect(await token.ownerOf("5")).to.eq(alice.address);

    const tx = await token.connect(bob).mint("4", '', { value: ethers.utils.parseEther("0.5")})
    await tx.wait();
    let currentAliceBalance = await alice.getBalance();
    expect(currentAliceBalance).to.gt(aliceBalance);

    aliceBalance = await alice.getBalance();
    await token.connect(bob).mint("5", '', { value: ethers.utils.parseEther("0.5")})
    currentAliceBalance = await provider.getBalance(alice.address);
    expect(currentAliceBalance).to.gt(aliceBalance);   
    
  }); 
});

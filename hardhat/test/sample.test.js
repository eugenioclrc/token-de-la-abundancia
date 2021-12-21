const { expect } = require("chai");

let deployer, alice, bob, carlos, dario, esteban, francis, gabriela, hector, ines, jaz, dev;
let token;

describe("Basic test", function() {
  before(async () => {
    [deployer, alice, bob, carlos, dario, esteban, francis, gabriela, hector, ines, jaz, dev] = await ethers.getSigners();
  })

  it("Should mint genesis NFT", async function() {
    

    const MandalaTokenNftAbundancia = await ethers.getContractFactory("MandalaTokenNftAbundancia");
    token = await MandalaTokenNftAbundancia.deploy(dev.address, 'http://127.0.0.1:3000/app/token?token=', ethers.utils.parseEther("0.025"), hre.network.config.chainId);
    await token.deployed();

    expect(await token.balanceOf(deployer.address)).to.eq(1);
    expect(await token.ownerOf(1)).to.eq(deployer.address);
  });

  it("Should send ETH to the mandala/fractal (genesis)", async function() {
    const balanceDeployerBefore = await deployer.getBalance();
    const balanceDevBefore = await dev.getBalance();
    let tx = await token.connect(alice).mint(1, '', { value: ethers.utils.parseEther("0.5")})
    
    
    await tx.wait();
    const balanceDeployerAfter = await deployer.getBalance();
    const balanceDevAfter = await dev.getBalance();

    // 1% gpste dev
    expect(balanceDevAfter.sub(balanceDevBefore)).to.eq(ethers.utils.parseEther("0.025").mul(10).div(1000));
    // 99% go to genesis, no hay mas gente en la "mandala"
    expect(balanceDeployerAfter.sub(balanceDeployerBefore)).to.eq(ethers.utils.parseEther("0.025").mul(990).div(1000));
    expect(await token.balanceOf(deployer.address)).to.eq(1);
    
    expect(await token.balanceOf(alice.address)).to.eq(1);
    expect(await token.ownerOf(2)).to.eq(alice.address);
    expect(await token.status(2)).to.eq(0);
    expect(await token.status(1)).to.eq(0)


    tx = await token.connect(bob).mint(1, '', { value: ethers.utils.parseEther("0.025")})
    await tx.wait();

    expect(await token.ownerOf(3)).to.eq(bob.address);
    expect(await token.status(2)).to.eq(0);
    expect(await token.status(1)).to.eq(1);
    
  });

  it("Should revert si la mandala esta completa", async function() {
    await expect(token.connect(alice).mint(1, '', { value: ethers.utils.parseEther("0.025")})).to.be.revertedWith("Esta rama esta completa");    
  });

  it("Bob es tierra y debe recibir el 20% de 0.025 ETH de carlos y dario", async function() {
    const balanceBobBefore = await bob.getBalance();
    let tx = await token.connect(carlos).mint(2, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    tx = await token.connect(dario).mint(2, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    tx = await token.connect(carlos).mint(3, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    // token genesis es aire por no completar todos los hijos
    expect(await token.status(1)).to.eq(1);
    expect(await token.status(3)).to.eq(0);
    tx = await token.connect(dario).mint(3, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    // token genesis pasa a tierra por completar los hijos
    expect(await token.status(1)).to.eq(2);

    expect(await token.status(3)).to.eq(1);
    expect(await token.status(2)).to.eq(1);

    const balanceBobAfter = await bob.getBalance();
    const expected = ethers.utils.parseEther("0.025").mul(2).mul(200).div(1000);
    expect(balanceBobAfter.sub(balanceBobBefore)).to.eq(expected);
  });

  it("Debe calcular correctamente el estado del token", async function() {
    expect(await token.status(3)).to.eq(1);
    expect(await token.status(2)).to.eq(1);

    // el token 6 es de carlos
    expect(await token.ownerOf(6)).to.eq(carlos.address);

    tx = await token.connect(esteban).mint(6, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    expect(await token.status(3)).to.eq(1);
    tx = await token.connect(esteban).mint(6, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    expect(await token.status(3)).to.eq(1);
    tx = await token.connect(esteban).mint(7, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    tx = await token.connect(esteban).mint(7, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    expect(await token.status(3)).to.eq(2);
    
    tx = await token.connect(esteban).mint(8, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    tx = await token.connect(esteban).mint(8, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    expect(await token.status(3)).to.eq(2);
    tx = await token.connect(esteban).mint(9, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    tx = await token.connect(esteban).mint(9, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    tx = await token.connect(esteban).mint(10, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    tx = await token.connect(esteban).mint(10, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    tx = await token.connect(esteban).mint(11, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();
    tx = await token.connect(esteban).mint(11, '', { value: ethers.utils.parseEther("0.025")});
    await tx.wait();


    // token 3 completo todos sus hijos y esta en su estado final de AGUA
    expect(await token.status(3)).to.eq(3);
    // token 2 no completo todos sus hijos y esta en su estado TIERRA
    expect(await token.status(1)).to.eq(2);

    // expect(await token.status(2)).to.eq(1);

  });

});

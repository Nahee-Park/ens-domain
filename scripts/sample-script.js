// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // 임의의 로컬 지갑 주소를 가져옴  (최대 10개 제공)
  const [owner, owner2]  = await hre.ethers.getSigners();

  // We get the contract to deploy
  const Domains = await hre.ethers.getContractFactory("Domains");
  const domains = await Domains.deploy();

  await domains.deployed();

  console.log("Domains deployed to:", domains.address);
  // 지갑 주소에 접근 가능
  console.log("Domains deployed by", owner.address);

  // 디폴트로 domains.register 하면 owner로 연결됨
  const registerBumJun = await domains.connect(owner2).register("bumjun");
  // 트랜젝션이 처리될 때까지 기다림
  await registerBumJun.wait();
  console.log("Bumjun was registered.");

  const bumjunDomainOwner = await domains.getAddress("bumjun");
  console.log("Owner of bumjun address is ...", bumjunDomainOwner);

  let setBumJunRecordFromNonOwner = await domains.connect(owner2).setRecord("bumjun", "0x123456789");
  setBumJunRecordFromNonOwner.wait();

  const bumjunDomain = await domains.getRecord("bumjun");
  console.log("OK!!!",bumjunDomain)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

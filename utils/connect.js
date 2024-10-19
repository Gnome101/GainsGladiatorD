const LitNodeClient = require("@lit-protocol/lit-node-client").LitNodeClient;
const { LitNetwork, LIT_RPC } = require("@lit-protocol/constants");
const { LitContracts } = require("@lit-protocol/contracts-sdk");
const ethers = require("ethers");
require("dotenv").config(); // Automatically loads environment variables from .env

const {
  createSiweMessage,
  generateAuthSig,
  LitAbility,
  LitActionResource,
  LitPKPResource,
} = require("@lit-protocol/auth-helpers");

const litNodeClient = new LitNodeClient({
  litNetwork: LitNetwork.DatilDev,
  debug: false,
});
await litNodeClient.connect();

console.log(LIT_RPC.CHRONICLE_YELLOWSTONE);
console.log("KEY", process.env.ETHEREUM_PRIVATE_KEY);

const ethersWallet = new ethers.Wallet(
  process.env.ETHEREUM_PRIVATE_KEY, // Replace with your private key
  new ethers.providers.JsonRpcProvider(LIT_RPC.CHRONICLE_YELLOWSTONE)
);

const litContracts = new LitContracts({
  signer: ethersWallet,
  network: LitNetwork.DatilDev,
  debug: false,
});
await litContracts.connect();

const pkpInfo = (await litContracts.pkpNftContractUtils.write.mint()).pkp;

console.log(`Stuff:`, pkpInfo); //Consits of a tokenID, publicKey, ethAddress

const sessionSigs = await litNodeClient.getSessionSigs({
  chain: "ethereum",
  expiration: new Date(Date.now() + 1000 * 60 * 10).toISOString(), // 10 minutes
  resourceAbilityRequests: [
    {
      resource: new LitPKPResource(pkpInfo.tokenId),
      ability: LitAbility.PKPSigning,
    },
    {
      resource: new LitActionResource("*"),
      ability: LitAbility.LitActionExecution,
    },
  ],
  authNeededCallback: async ({ uri, expiration, resourceAbilityRequests }) => {
    const toSign = await createSiweMessage({
      uri,
      expiration,
      resources: resourceAbilityRequests,
      walletAddress: ethersWallet.address,
      nonce: await litNodeClient.getLatestBlockhash(),
      litNodeClient,
    });

    return await generateAuthSig({
      signer: ethersWallet,
      toSign,
    });
  },
});
console.log("-----------------------------------");
console.log(sessionSigs);

const signingResult = await litNodeClient.pkpSign({
  pubKey: pkpInfo.publicKey,
  sessionSigs,
  toSign: ethers.utils.arrayify(
    ethers.utils.keccak256(
      ethers.utils.toUtf8Bytes("The answer to the universe is 42.")
    )
  ),
});

console.log("-----------------------------------");
console.log(signingResult);

const encodedSig = ethers.utils.joinSignature({
  v: signingResult.recid,
  r: `0x${signingResult.r}`,
  s: `0x${signingResult.s}`,
});

const recoveredPubkey = ethers.utils.recoverPublicKey(
  `0x${signingResult.dataSigned}`,
  encodedSig
);
const recoveredAddress = ethers.utils.recoverAddress(
  `0x${signingResult.dataSigned}`,
  encodedSig
);

// console.log(recoveredPubkey, pkpInfo.publicKey); // true
console.log(recoveredAddress === pkpInfo.ethAddress); // true

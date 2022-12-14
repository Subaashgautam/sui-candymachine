import { RawSigner,RpcTxnDataSerializer,Ed25519Keypair,JsonRpcProvider, Network } from '@mysten/sui.js';
import { fromB64 } from '@mysten/bcs';
const provider = new JsonRpcProvider(Network.DEVNET);
const bob = Ed25519Keypair.fromSecretKey(fromB64("oukb7vm4X0BkaEJ/5CB8SJ6ahnZHEszLbK341NeKx30TOI60Anv4dKczNuGdMrsAnFzPl0b+OkE3cQokfjqC2g=="))
describe("whitelist", () => {
    it("Whitelist Mint", async () => {
        const delay = ms => new Promise(resolve => setTimeout(resolve, ms))
        const signer = new RawSigner(bob, provider);
        const moveCallTxn = await signer.executeMoveCall({
            packageObjectId: '0xe13503ccfc7ea759c52a6944dc016bf12a1f2110',
            module: 'candymachine',
            function: 'init_candy',
            typeArguments: [],
            arguments: [
                    "Mokshya Test",
                    "Mokshya Test",
                    "https://mokshya.io/images/",
                    "0xe5d7776a3f85e9db46f0ba0b9f3785972ab23a5d",
                    1000,
                    100,
                    100,
                    100,
                    1000,
                    10000,
                    1000,
                    "Mokshya",
            ],
            gasBudget: 10000,
        });
        const moveCallMintTxn = await signer.executeMoveCall({
            packageObjectId: '0xe13503ccfc7ea759c52a6944dc016bf12a1f2110',
            module: 'candymachine',
            function: 'mint_nft',
            typeArguments: [],
            arguments: [
                "0xd0e553dbb9c694ca7398572744e6a6b4ed2cb818"
            ],
            gasBudget: 10000,
        });
        console.log('moveCallTxn', moveCallMintTxn);
    })
})
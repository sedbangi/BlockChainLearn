package org.example;

import org.web3j.abi.datatypes.Address;
import org.web3j.codegen.TruffleJsonFunctionWrapperGenerator;
import org.web3j.contracts.token.ERC20Interface;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameter;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.Request;
import org.web3j.protocol.core.methods.request.Transaction;
import org.web3j.protocol.core.methods.response.EthCall;
import org.web3j.protocol.core.methods.response.EthChainId;
import org.web3j.protocol.core.methods.response.Web3ClientVersion;
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.Contract;

import java.io.IOException;
import java.math.BigInteger;

import static sun.security.jgss.GSSHeader.TOKEN_ID;

/**
 * Hello world!
 *
 */
public class App {


    private static final String NFT_CONTRACT_ADDRESS = "0x0483B0DFc6c78062B9E999A82ffb795925381415";
    private static final BigInteger TOKEN_ID = BigInteger.valueOf(10); // 查询的 NFT tokenId


    public static void main( String[] args ) throws Exception {
        Web3j web3j = Web3j.build(new HttpService("https://api.securerpc.com/v1"));  // defaults to http://localhost:8545/

        try {
            getOwnerOfNFT(web3j);
            getTokenURI(web3j);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                web3j.shutdown();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private static void getOwnerOfNFT(Web3j web3j) throws Exception {
//        String ownerOfFunction = "0x6352211e"; // ownerOf 方法的函数签名（keccak256("ownerOf(uint256)")）
//        web3j.ethCall(Transaction.,
//                DefaultBlockParameter.valueOf(web3j.ethBlockNumber().send().getBlockNumber()))
//        EthCall response = web3j.ethCall(
////                new org.web3j.protocol.core.methods.request.FunctionCall(
////                        NFT_CONTRACT_ADDRESS,
////                        ownerOfFunction + String.format("%064x", TOKEN_ID),
////                        DefaultBlockParameterName.LATEST
//                )
//        ).send();

//        System.out.println("NFT 持有人地址: " + response.getValue());
    }

    private static void getTokenURI(Web3j web3j) throws Exception {
//        String tokenURIFunction = "0x6c5a49e2"; // tokenURI 方法的函数签名（keccak256("tokenURI(uint256)")）
//        EthCall response = web3j.ethCall(
//                new org.web3j.protocol.core.methods.request.FunctionCall(
//                        NFT_CONTRACT_ADDRESS,
//                        tokenURIFunction + String.format("%064x", TOKEN_ID),
//                        DefaultBlockParameterName.LATEST
//                )
//        ).send();
//
//        System.out.println("Metadata URI for tokenId " + TOKEN_ID + ": " + response.getValue());
    }
}

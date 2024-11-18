package org.example;

import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;

import java.math.BigInteger;

import static sun.security.jgss.GSSHeader.TOKEN_ID;

/**
 * Hello world!
 *
 */
public class App {

    private static final String CONTRACT_ADDRESS = "0x7394287D60ec9d09fD8389e4878eB956548C2ECd";
    private static final BigInteger TOKEN_ID = BigInteger.valueOf(10); // 查询的 NFT tokenId

    //send bundle to contract

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

    }

    private static void getTokenURI(Web3j web3j) throws Exception {

    }
}

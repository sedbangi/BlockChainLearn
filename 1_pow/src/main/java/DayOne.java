import cn.hutool.crypto.digest.DigestUtil;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

import java.security.*;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.Random;

public class DayOne {

    public static void main(String[] args) {

        //--------- test 1 --------
        long startTime = System.currentTimeMillis();

        String nickName = "zhaochenyang";
        int nounce;
        String hashContent = "";

        String prefix = "00000";
        String hashResult = "";

        int count = 0;

        while (!hashResult.startsWith(prefix)) {
            nounce = new Random().nextInt();
            hashContent = nickName + nounce;
            hashResult = DigestUtil.sha256Hex(hashContent);
            count++;
        }
        long endTime = System.currentTimeMillis();

        System.out.println(
                "spendTime: " + (endTime - startTime) +
                        "ms\nHashContent: " + hashContent +
                        "\nHashResult: " + hashResult +
                        "\ncount: " + count +
                        "\nprefix: " + prefix);



        // ------ test 2 ----------
        //generate keyPair by RSA
        KeyPair keyPair;
        try {
             keyPair = RSAKeyPairGenerator();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }

        //sign hashContent with privateKey
        String base64Signature = signature(
                Base64.getEncoder().encodeToString(keyPair.getPrivate().getEncoded()),
                hashContent
        );
        //verify hashContent by Signature with publicKey
        try {
            boolean verifySignature = verifySignature(
                    hashContent,
                    base64Signature,
                    Base64.getEncoder().encodeToString(keyPair.getPublic().getEncoded())
            );
            System.out.printf("验证结果：" + (verifySignature ? "correct" : "wrong"));
        } catch (Exception e) {
            System.out.printf(e.getMessage());
        }
    }

    /**
     * RSAKeyPairGenerator
     * @return  KeyPair
     * @throws NoSuchAlgorithmException
     */
    public static KeyPair RSAKeyPairGenerator() throws NoSuchAlgorithmException {
        Security.addProvider(new BouncyCastleProvider());

        // 生成 RSA 密钥对
        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
        keyPairGenerator.initialize(2048); // 设置密钥大小
        KeyPair keyPair = keyPairGenerator.generateKeyPair();

        RSAPublicKey publicKey = (RSAPublicKey) keyPair.getPublic();
        RSAPrivateKey privateKey = (RSAPrivateKey) keyPair.getPrivate();

        // 输出公钥和私钥
        System.out.println("公钥(Hex): " + byteArrayToHexString(publicKey.getEncoded()));
        System.out.println("私钥(Hex): " + byteArrayToHexString(privateKey.getEncoded()));

        return keyPair;
    }

    /**
     * 数字签名
     * @param base64PrivateKey 私钥以 Base64 编码的字符串形式存在
     * @param data 需要签名的内容
     * @return 数字签名的 Base64 编码的字符串形式
     */
    public static String signature(String base64PrivateKey, String data){
        Security.addProvider(new BouncyCastleProvider());

        // 转换 Base64 编码的私钥为 PrivateKey 对象
        byte[] privateKeyBytes = Base64.getDecoder().decode(base64PrivateKey);
        PKCS8EncodedKeySpec privateKeySpec = new PKCS8EncodedKeySpec(privateKeyBytes);
        try {
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            PrivateKey privateKey = keyFactory.generatePrivate(privateKeySpec);

            // 生成签名
            Signature signature = Signature.getInstance("SHA256withRSA");
            signature.initSign(privateKey);
            signature.update(data.getBytes());
            byte[] digitalSignature = signature.sign();

            // 输出签名
            String base64Signature = Base64.getEncoder().encodeToString(digitalSignature);
            System.out.println("数字签名(base64): " + base64Signature);
            return base64Signature;
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return null;
    }

    /**
     * 验证
     * @param data 内容
     * @param base64Signature 以base64编码的签名
     * @param base64PublicKey 以base64编码的公钥
     * @return 验证是否成功
     * @throws Exception
     */
    public static boolean verifySignature(String data, String base64Signature, String base64PublicKey) throws Exception {
        byte[] publicKeyBytes = Base64.getDecoder().decode(base64PublicKey);
        X509EncodedKeySpec publicKeySpec = new X509EncodedKeySpec(publicKeyBytes);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        PublicKey publicKey = keyFactory.generatePublic(publicKeySpec);

        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initVerify(publicKey);
        signature.update(data.getBytes());

        byte[] signatureBytes = Base64.getDecoder().decode(base64Signature);
        return signature.verify(signatureBytes);
    }

    /**
     * 字节数的转为16进制字符串
     * @param bytes 字节数组
     * @return 16进制字符串
     */
    public static String byteArrayToHexString(byte[] bytes) {
        StringBuilder hexString = new StringBuilder();
        for (byte b : bytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0'); // 确保每个字节都用两位表示
            hexString.append(hex);
        }
        return hexString.toString();
    }


}

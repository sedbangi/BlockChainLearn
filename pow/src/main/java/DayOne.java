import cn.hutool.crypto.digest.DigestUtil;

import java.util.Random;

public class DayOne {
    /**
     * 题目#1
     * 实践 POW， 编写程序（编程语言不限）用自己的昵称 + nonce，不断修改nonce 进行 sha256 Hash 运算：
     * <p>
     * 直到满足 4 个 0 开头的哈希值，打印出花费的时间、Hash 的内容及Hash值。
     * 再次运算直到满足 5 个 0 开头的哈希值，打印出花费的时间、Hash 的内容及Hash值。
     * 提交程序你的 Github 链接
     */
    public static void main(String[] args) {
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
    }
}

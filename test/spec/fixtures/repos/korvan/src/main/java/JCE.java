import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import java.security.AlgorithmParameters;
import java.security.spec.KeySpec;

public class JCE {

    private static final char[] PASSWORD = "abcdefg".toCharArray();

    private static final byte[] SALT =
        {
            (byte)0x4D, (byte)0x9B, (byte)0xC6, (byte)0x53,
            (byte)0x17, (byte)0xAF, (byte)0xE2, (byte)0x08
        };

    private static final int iterations = 65536;

    public static void main(String... args) throws Exception {
        String data = "Test";
        for (String arg : args) {
            data += ":" + arg;
        }

        System.out.println("Encrypting, \"" + data + "\"");

        JCE jce = new JCE();
        byte[] encryptedData = jce.encrypt(data);
        System.out.println("Encrypted: " + new String(encryptedData));

        byte[] decipheredText = jce.decrypt(encryptedData);
        System.out.println("Decrypted: " + new String(decipheredText));
    }

    private byte[] initializationVector;

    private byte[] encrypt(String property) throws Exception {
        Cipher cipher = getCipher(Cipher.ENCRYPT_MODE);
        return cipher.doFinal(property.getBytes());
    }

    private byte[] decrypt(byte[] property) throws Exception {
        Cipher pbeCipher = getCipher(Cipher.DECRYPT_MODE);
        return pbeCipher.doFinal(property);
    }

    private Cipher getCipher(int mode) throws Exception {
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
        KeySpec spec = new PBEKeySpec(PASSWORD, SALT, iterations, 256);
        SecretKey tmp = factory.generateSecret(spec);
        SecretKey key = new SecretKeySpec(tmp.getEncoded(), "AES");

        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        if (this.initializationVector == null) {
            cipher.init(mode, key);
            AlgorithmParameters params = cipher.getParameters();
            this.initializationVector = params.getParameterSpec(IvParameterSpec.class).getIV();
        } else {
            cipher.init(mode, key, new IvParameterSpec(this.initializationVector));
        }

        return cipher;
    }
}

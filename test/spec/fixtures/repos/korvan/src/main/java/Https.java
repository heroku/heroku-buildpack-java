import javax.net.ssl.SSLContext;
import java.io.IOException;
import java.lang.reflect.Constructor;
import java.net.URL;
import java.net.URLStreamHandler;
import java.security.KeyManagementException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.cert.Certificate;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import javax.net.ssl.HttpsURLConnection;
import java.io.InputStream;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.io.BufferedReader;


public class Https {
  public static void main(String... args) throws Exception {

    String urlStr = "https://httpbin.org/get?show_env=1";
    URL url = new URL(urlStr);
    HttpsURLConnection con = (HttpsURLConnection)url.openConnection();
    con.setDoInput(true);
    con.setRequestMethod("GET");

    String response = handleResponse(con);

    System.out.println("Successfully invoked HTTPS service.");
    System.out.println(response);
  }

  private static String handleResponse(HttpsURLConnection con) throws Exception {
    try {
      return readStream(con.getInputStream());
    } catch (Exception e) {
      e.printStackTrace();
      String output = readStream(con.getErrorStream());
      throw new Exception("HTTP " + String.valueOf(con.getResponseCode()) + ": " + e.getMessage());
    }
  }

  private static String readStream(InputStream is) throws Exception {
    BufferedReader reader = new BufferedReader(new InputStreamReader(is));
    String output = "";
    String tmp = reader.readLine();
    while (tmp != null) {
      output += tmp;
      tmp = reader.readLine();
    }
    return output;
  }
}

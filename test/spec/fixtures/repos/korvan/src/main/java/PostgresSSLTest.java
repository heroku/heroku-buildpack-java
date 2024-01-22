import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Properties;

public class PostgresSSLTest {

  public static void main(String[] args) throws Exception {
    PostgresSSLTest pgSsl = new PostgresSSLTest();

    Properties props = pgSsl.loadDefaultProperties();

    System.out.println("sslmode: " + props.getProperty("sslmode", "NULL"));
    System.out.println("ssl: " + props.getProperty("ssl", "NULL"));
    System.out.println("sslfactory: " + props.getProperty("sslfactory", "NULL"));
  }


  public Properties loadDefaultProperties() throws IOException {
    Properties merged = new Properties();

    // If we are loaded by the bootstrap classloader, getClassLoader()
    // may return null. In that case, try to fall back to the system
    // classloader.
    //
    // We should not need to catch SecurityException here as we are
    // accessing either our own classloader, or the system classloader
    // when our classloader is null. The ClassLoader javadoc claims
    // neither case can throw SecurityException.
    ClassLoader cl = getClass().getClassLoader();
    if (cl == null) {
      cl = ClassLoader.getSystemClassLoader();
    }

    // When loading the driver config files we don't want settings found
    // in later files in the classpath to override settings specified in
    // earlier files. To do this we've got to read the returned
    // Enumeration into temporary storage.
    ArrayList<URL> urls = new ArrayList<URL>();
    Enumeration<URL> urlEnum = cl.getResources("org/postgresql/driverconfig.properties");
    while (urlEnum.hasMoreElements()) {
      urls.add(urlEnum.nextElement());
    }

    for (int i = urls.size() - 1; i >= 0; i--) {
      URL url = urls.get(i);

      InputStream is = url.openStream();
      merged.load(is);
      is.close();
    }

    return merged;
  }
}

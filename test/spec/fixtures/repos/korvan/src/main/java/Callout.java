import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;

public class Callout {
    public static void main(final String... args) {
        if (args.length == 0) {
            System.out.println("Provide some URLs");
            System.exit(123);
        }

        for (final String urlArg : args) {
            try {
                final URL url = new URL(urlArg);
                final BufferedReader reader = new BufferedReader(
                        new InputStreamReader(url.openStream()));
                String line;
                while((line = reader.readLine()) != null) {
                    System.out.println(line);
                }
            } catch (MalformedURLException e) {
                e.printStackTrace(System.out);
                System.exit(456);
            } catch (IOException e) {
                e.printStackTrace(System.out);
                System.exit(789);
            }
        }
    }
}

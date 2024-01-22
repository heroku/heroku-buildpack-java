import java.net.InetSocketAddress;
import java.net.Socket;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.SSLContext;


public class SSLTest {

    /* (optionally bind and) just make SSL connection, for testing reach and trust
     * uses default providers, truststore (normally JRE/lib/security/[jsse]cacerts),
     * and keystore (normally none), override with -Djavax.net.ssl.{trust,key}Store*
     */
    public static void main (String[] args) throws Exception {
        if( args.length < 2 ){ System.out.println ("Usage: tohost port [fromaddr [fromport]]"); return; }
        Socket sock = SSLSocketFactory.getDefault().createSocket();
        if( args.length > 2 )
            sock.bind (new InetSocketAddress (args[2], args.length>3? Integer.parseInt(args[3]): 0));
        sock.connect (new InetSocketAddress (args[0], Integer.parseInt(args[1])));
        System.out.println (sock.getInetAddress().getHostName() + " = " + sock.getInetAddress().getHostAddress());
        ((SSLSocket)sock).startHandshake();
        System.out.println ("connect okay " + ((SSLSocket)sock).getSession().getCipherSuite());

        SSLContext context = SSLContext.getDefault();
        SSLSocketFactory sf = context.getSocketFactory();
        String[] cipherSuites = sf.getSupportedCipherSuites();

        System.out.println("CipherSuite:");
        for (String cipher : cipherSuites) {
          System.out.println("  " + cipher);
        }
    }
}

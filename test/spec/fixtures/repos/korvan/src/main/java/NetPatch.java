import java.net.NetworkInterface;
import java.util.Enumeration;

public class NetPatch {
    public static void main(String[] args) throws Exception{
        Enumeration<NetworkInterface> networkInterfaces = NetworkInterface.getNetworkInterfaces();
        while (networkInterfaces.hasMoreElements()) {
            NetworkInterface i = networkInterfaces.nextElement();
            System.out.println(i.toString());
        }
    }
}
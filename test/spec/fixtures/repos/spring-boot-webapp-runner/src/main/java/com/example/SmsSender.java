package com.example;

import java.io.*;
import java.net.*;
import java.sql.*;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.*;

import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.commons.codec.binary.Base64;

class SmsSender {
  public void send(String phoneNumber, String message) {
    String blowerIoUrlStr = System.getenv("BLOWERIO_URL");

    if (null != blowerIoUrlStr) {
      try {
        String data = "to=" + URLEncoder.encode(phoneNumber, "UTF-8") +
          "&message=" + URLEncoder.encode(message, "UTF-8");

        URL blowerIoUrl = new URL(blowerIoUrlStr + "messages");
        final String username = blowerIoUrl.getUserInfo().split(":")[0];
        final String password = blowerIoUrl.getUserInfo().split(":")[1];

        disableCertificateValidation();

        HttpsURLConnection con = (HttpsURLConnection)blowerIoUrl.openConnection();
        con.setRequestMethod("POST");
        con.setDoInput(true);
        con.setDoOutput(true);

        String userpass = username + ":" + password;
        String basicAuth = "Basic " + new String(new Base64().encode(userpass.getBytes()));
        con.setRequestProperty ("Authorization", basicAuth);

        con.addRequestProperty("Accept", "application/json");
        con.getOutputStream().write(data.getBytes("UTF-8"));

        BufferedReader reader = new BufferedReader(new InputStreamReader(con.getInputStream()));

        String tmp = "BLOWERIO Response:\n";
        while((tmp = reader.readLine()) != null) {
            System.out.println(tmp);
        }
      } catch (Exception e) {
        String errMsg = "There was an SMS error: " + e.getMessage();
        e.printStackTrace();
      }
    } else {
      System.out.println("No BlowerIO URL set");
    }
  }

  public void disableCertificateValidation() {
      // Create a trust manager that does not validate certificate chains
      TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
          public X509Certificate[] getAcceptedIssuers() {
              return new X509Certificate[0];
          }

          @Override
          public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {

          }

          @Override
          public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {

          }
      }};

      // Ignore differences between given hostname and certificate hostname
      HostnameVerifier hv = new HostnameVerifier() {
          @Override
          public boolean verify(String hostname, SSLSession session) {
              return true;
          }
      };

      // Install the all-trusting trust manager
      try {
          SSLContext sc = SSLContext.getInstance("SSL");
          sc.init(null, trustAllCerts, new SecureRandom());
          HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
          HttpsURLConnection.setDefaultHostnameVerifier(hv);
      } catch (Exception e) {
          // Do nothing
      }
  }
}

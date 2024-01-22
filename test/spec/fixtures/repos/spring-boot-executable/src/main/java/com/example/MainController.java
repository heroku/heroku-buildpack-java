package com.example;

import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.*;
import org.springframework.stereotype.*;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.URISyntaxException;
import java.sql.*;

import java.net.URLDecoder;
import java.util.*;

@Controller
@EnableAutoConfiguration
public class MainController {

  @RequestMapping("/home")
    String home() {
    return "home";
  }

  @RequestMapping(value="/submit/", method = RequestMethod.POST)
  @ResponseBody
  String submit(@RequestBody String body) {
    System.out.println("body => " + body);
    Map<String,String> records = parseParams(body);

    String inviteeName = records.get("name");
    String inviteeEmail = records.get("email");
    String inviteePhone = records.get("phone");
    String apptDate = records.get("date");
    Boolean sendSms = records.get("send_sms").equals("true");

    try {
      Connection connection = getConnection();

      Statement stmt = connection.createStatement();
      createTables(connection);

      createInvitee(connection, inviteeName, inviteeEmail, inviteePhone);
      createAppointment(connection, inviteeEmail, apptDate, sendSms);
    } catch (Exception e) {
      return "There was an error: " + e.getMessage();
    }

    return "ok";
  }

  private Map<String,String> parseParams(String body) {
    String[] args = body.split("&");

    Map<String,String> records = new HashMap<String,String>();

    for (String arg : args) {
      String[] parts = arg.split("=");
      String key = parts[0];
      String val = parts.length > 1 ? URLDecoder.decode(parts[1]) : null;
      System.out.println(key + " => " + val);
      records.put(key, val);
    }

    return records;
  }

  private void createAppointment(Connection connection, String inviteeId, String date, Boolean sendSms) throws SQLException {
    System.out.println("creating new appt: " + date);
    Statement stmt = connection.createStatement();
    PreparedStatement pstmt = connection.prepareStatement(
        "INSERT INTO appointments (invitee_id, date) VALUES (?,?)");
    pstmt.setString(1, inviteeId);
    pstmt.setString(2, date);
    pstmt.executeUpdate();
  }

  private void createInvitee(Connection connection, String name, String email, String phone) throws SQLException {
    PreparedStatement pstmt = connection.prepareStatement(
        "SELECT name FROM invitees WHERE email=?");
    pstmt.setString(1, email);
    ResultSet rs = pstmt.executeQuery();

    if (!rs.next()) {
      System.out.println("creating new invitee: " + email);
      pstmt = connection.prepareStatement(
          "INSERT INTO invitees (name, email, phone) VALUES (?,?,?)");
      pstmt.setString(1, name);
      pstmt.setString(2, email);
      pstmt.setString(3, phone);
      pstmt.executeUpdate();
    }
  }

  private void createTables(Connection connection) throws SQLException {
    Statement stmt = connection.createStatement();
    stmt.executeUpdate("CREATE TABLE IF NOT EXISTS appointments (" +
      "invitee_id  varchar(250)," +
      "date        varchar(250),"+
      "send_sms    boolean" +
    ")");
    stmt.executeUpdate("CREATE TABLE IF NOT EXISTS invitees (" +
      "name        varchar(250)," +
      "email       varchar(250)," +
      "phone       varchar(250)," +
      "CONSTRAINT  unique_email UNIQUE(email)" +
    ")");
  }

  private Connection getConnection() throws URISyntaxException, SQLException {
    URI dbUri = new URI(System.getenv("DATABASE_URL"));

    String username = dbUri.getUserInfo().split(":")[0];
    String password = dbUri.getUserInfo().split(":")[1];
    String dbUrl = "jdbc:postgresql://" + dbUri.getHost() + dbUri.getPath();

    return DriverManager.getConnection(dbUrl, username, password);
  }

  public static void main(String[] args) throws Exception {
      SpringApplication.run(MainController.class, args);
  }
}

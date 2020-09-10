package com.heroku;

import io.undertow.Undertow;
import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.util.Headers;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DatabaseTestApp {
    public static void main(String[] args) {
        int port = Integer.parseInt(System.getenv("PORT"));
        System.out.printf("Starting on port %d...\n", port);

        final String query = "SELECT 1337 * 42 * 23 / 1138";

        Undertow server = Undertow.builder()
                .addHttpListener(port, "0.0.0.0")
                .setHandler(new HttpHandler() {
                    @Override
                    public void handleRequest(final HttpServerExchange exchange) throws Exception {
                        Class.forName("org.postgresql.Driver");

                        Connection connection = DriverManager.getConnection(System.getenv("JDBC_DATABASE_URL"));
                        Statement statement = connection.createStatement();
                        ResultSet resultSet = statement.executeQuery(query);

                        resultSet.next();
                        String result = resultSet.getString(1);

                        exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
                        exchange.getResponseSender().send(query + " = " + result);
                    }
                }).build();

        server.start();
    }
}

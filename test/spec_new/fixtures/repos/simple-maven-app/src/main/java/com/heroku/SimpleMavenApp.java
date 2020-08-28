package com.heroku;

import io.undertow.Undertow;
import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.util.Headers;

public class SimpleMavenApp {
    public static void main(String[] args) {
        int port = Integer.parseInt(System.getenv("PORT"));
        System.out.printf("Starting on port %d...\n", port);

        Undertow server = Undertow.builder()
                .addHttpListener(port, "0.0.0.0")
                .setHandler(new HttpHandler() {
                    @Override
                    public void handleRequest(final HttpServerExchange exchange) throws Exception {
                        exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
                        exchange.getResponseSender().send("Hello Heroku!");
                    }
                }).build();

        server.start();
    }
}

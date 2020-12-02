package com.heroku;

import com.google.common.hash.Hashing;
import io.undertow.Undertow;
import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.util.Headers;

import java.nio.charset.StandardCharsets;
import java.util.Optional;

public class App {
    public static void main(String[] args) {
        int port = Optional
                .ofNullable(System.getenv("PORT"))
                .map(Integer::parseInt)
                .orElse(8080);

        System.out.printf("Starting on port %d...\n", port);

        Undertow server = Undertow.builder()
                .addHttpListener(port, "0.0.0.0")
                .setHandler(new HttpHandler() {
                    @Override
                    public void handleRequest(final HttpServerExchange exchange) throws Exception {
                        String payloadQueryValue = exchange.getQueryParameters().get("payload").getFirst();

                        String hashedPayloadQueryValue =
                                Hashing.sha256().hashString(payloadQueryValue, StandardCharsets.UTF_8).toString();

                        exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
                        exchange.getResponseSender().send(hashedPayloadQueryValue);
                    }
                }).build();

        server.start();
    }

    public int getBogusValue() {
        return 42;
    }
}

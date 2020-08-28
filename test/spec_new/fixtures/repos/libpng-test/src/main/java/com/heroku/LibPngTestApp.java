package com.heroku;

import io.undertow.Undertow;
import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.util.Headers;

import java.awt.*;
import java.awt.font.FontRenderContext;
import java.awt.font.TextLayout;
import java.awt.image.BufferedImage;

public class LibPngTestApp {
    public static void main(String[] args) {
        int port = Integer.parseInt(System.getenv("PORT"));
        System.out.printf("Starting on port %d...\n", port);

        Undertow server = Undertow.builder()
                .addHttpListener(port, "0.0.0.0")
                .setHandler(new HttpHandler() {
                    @Override
                    public void handleRequest(final HttpServerExchange exchange) throws Exception {
                        BufferedImage img = new BufferedImage(BufferedImage.TYPE_INT_RGB, 10, 10);
                        Graphics2D g2d = img.createGraphics();

                        String string = new String(new int[] { 2835, 2849, 2879, 2876, 2822 }, 0, 5);
                        Font font = new Font("SansSerif", Font.PLAIN, 13);
                        FontRenderContext fontRenderContext = g2d.getFontRenderContext();

                        new TextLayout(string, font, fontRenderContext);

                        exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
                        exchange.getResponseSender().send("Hello Heroku!");
                    }
                }).build();

        server.start();
    }
}

package com.heroku.keith.libpngtest;

public class ErrorInfo {
    public final String url;
    public final String ex;

    public ErrorInfo(StringBuffer stringBuffer, Exception ex) {
        this.url = stringBuffer.toString();
        this.ex = ex.getLocalizedMessage();
    }
}

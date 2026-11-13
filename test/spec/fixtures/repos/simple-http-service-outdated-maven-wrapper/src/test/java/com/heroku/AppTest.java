package com.heroku;

import org.junit.Test;

import static org.junit.Assert.*;

public class AppTest {
    @Test
    public void testBogusValue() {
        assertEquals(42, new App().getBogusValue());
    }
}

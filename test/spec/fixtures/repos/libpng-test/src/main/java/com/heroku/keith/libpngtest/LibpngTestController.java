package com.heroku.keith.libpngtest;

import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.font.FontRenderContext;
import java.awt.font.TextLayout;
import java.awt.image.BufferedImage;

import javax.servlet.http.HttpServletRequest;

import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.HttpStatus;

@RestController
public class LibpngTestController {

	@RequestMapping("/")
	public String test() {
		BufferedImage img = new BufferedImage(BufferedImage.TYPE_INT_RGB, 10, 10);
		Graphics2D g2d = img.createGraphics();
		FontRenderContext frc = g2d.getFontRenderContext();
		Font f = new Font("SansSerif", Font.PLAIN, 13);
		String str = new String(new int[] { 2835, 2849, 2879, 2876, 2822 }, 0, 5);
		new TextLayout(str, f, frc);

		return "All Good!!!";
	}

	@ResponseStatus(HttpStatus.BAD_REQUEST)
	@ExceptionHandler(Exception.class)
	@ResponseBody ErrorInfo
	handleBadRequest(HttpServletRequest req, Exception ex) {
	    return new ErrorInfo(req.getRequestURL(), ex);
	}
}

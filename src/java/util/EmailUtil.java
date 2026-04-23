package util;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

public class EmailUtil {
    
    // ====== CONFIGURATION: CHANGE THESE VALUES ======
    private static final String FROM_EMAIL = "gonzagafernando077@gmail.com";  // YOUR EMAIL
    private static final String FROM_PASSWORD = "njomfunsxxdwmwzo";   // YOUR APP PASSWORD (NOT regular password)
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    // ===============================================
    
    public static boolean sendOTPEmailHTML(String toEmail, String otp) {
        try {
            String subject = "Your OTP Code - SCMS";
            String htmlBody = "<html>" +
                    "<body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>" +
                    "<div style='background-color: white; padding: 30px; border-radius: 8px; max-width: 500px; margin: 0 auto;'>" +
                    "<h2 style='color: #333;'>Email Verification</h2>" +
                    "<p style='color: #666;'>Your OTP verification code is:</p>" +
                    "<div style='background-color: #007bff; color: white; padding: 15px; text-align: center; font-size: 24px; font-weight: bold; border-radius: 5px; letter-spacing: 3px;'>" +
                    otp +
                    "</div>" +
                    "<p style='color: #666; margin-top: 20px;'>This code expires in <strong>10 minutes</strong>.</p>" +
                    "<p style='color: #999; font-size: 12px;'>Do not share this code with anyone.</p>" +
                    "<hr style='border: none; border-top: 1px solid #ddd; margin-top: 30px;'/>" +
                    "<p style='color: #999; font-size: 12px;'>SCMS System</p>" +
                    "</div>" +
                    "</body>" +
                    "</html>";
            
            return sendHtmlEmail(toEmail, subject, htmlBody);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public static boolean sendHtmlEmail(String toEmail, String subject, String htmlBody) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.starttls.required", "true");
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");
            
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, FROM_PASSWORD);
                }
            });
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=utf-8");
            
            Transport.send(message);
            System.out.println("OTP email sent to: " + toEmail);
            return true;
            
        } catch (MessagingException e) {
            System.err.println("Failed to send OTP email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
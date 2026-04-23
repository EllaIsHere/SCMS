package controller;

import util.DBConnection;
import util.EmailUtil;
import java.io.IOException;
import java.sql.*;
import java.util.UUID;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/SendTemporaryPasswordServlet")
public class SendTemporaryPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();

        String email = (String) session.getAttribute("otpEmail");
        String schoolId = (String) session.getAttribute("otpSchoolId");
        Integer roleId = (Integer) session.getAttribute("otpRoleId");
        String hashedPassword = (String) session.getAttribute("otpPassword");
        String firstName = (String) session.getAttribute("otpFirstName");
        String lastName = (String) session.getAttribute("otpLastName");

        String tempPassword = UUID.randomUUID().toString().substring(0, 8);
        String hashedTempPassword = BCrypt.hashpw(tempPassword, BCrypt.gensalt());

        try(Connection conn = DBConnection.getConnection()){

            String sql = "INSERT INTO users (school_id,email,password,role_id,is_verified,access_status,force_change,created_at,full_name) "
                       + "VALUES (?,?,?,?,'Y','Active','Y',SYSDATE,?)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, schoolId);
            ps.setString(2, email);
            ps.setString(3, hashedTempPassword);
            ps.setInt(4, roleId);
            ps.setString(5, firstName + " " + lastName);
            ps.executeUpdate();

        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("email_verified.jsp?error=1");
            return;
        }

        EmailUtil.sendHtmlEmail(
            email,
            "Temporary Password - SCMS",
            "<h2>Your Temporary Password</h2>"
            + "<p>Your temporary password is: <b>" + tempPassword + "</b></p>"
            + "<p>This password expires in 10 minutes and is valid for one sign-in only.</p>"
            + "<p>You'll be prompted to set a permanent password on your first login.</p>"
        );

        session.setAttribute("tempPasswordEmail", email);
        session.removeAttribute("otp");
        session.removeAttribute("otpExpiry");
        session.removeAttribute("otpVerified");

        response.sendRedirect("request_temporary_password.jsp");
    }
}